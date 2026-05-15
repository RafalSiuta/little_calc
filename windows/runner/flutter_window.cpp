#include "flutter_window.h"

#include <algorithm>
#include <cstdint>
#include <optional>
#include <variant>

#include <dwmapi.h>
#include <flutter_windows.h>

#include "flutter/generated_plugin_registrant.h"

namespace {

enum ACCENT_STATE {
  ACCENT_DISABLED = 0,
  ACCENT_ENABLE_ACRYLICBLURBEHIND = 4,
};

struct ACCENT_POLICY {
  ACCENT_STATE AccentState;
  DWORD AccentFlags;
  DWORD GradientColor;
  DWORD AnimationId;
};

struct WINDOWCOMPOSITIONATTRIBDATA {
  int Attrib;
  PVOID pvData;
  SIZE_T cbData;
};

using SetWindowCompositionAttributeProc =
    BOOL(WINAPI*)(HWND, WINDOWCOMPOSITIONATTRIBDATA*);

constexpr int kWindowCompositionAttributeAccentPolicy = 19;
bool g_is_blur = true;

DWORD AcrylicTintColor(double blur_value) {
  double clamped_blur = std::clamp(blur_value, 0.0, 40.0);
  BYTE alpha = static_cast<BYTE>(40 + (clamped_blur / 40.0) * 120);

  // SetWindowCompositionAttribute expects AABBGGRR.
  return (static_cast<DWORD>(alpha) << 24) | 0x00191919;
}

void ConfigureTransparentDwmFrame(HWND window) {
  MARGINS margins = {-1, -1, -1, -1};
  DwmExtendFrameIntoClientArea(window, &margins);
}

bool ReadBoolArgument(const flutter::EncodableMap& arguments,
                      const char* name,
                      bool fallback) {
  auto it = arguments.find(flutter::EncodableValue(name));
  if (it == arguments.end()) {
    return fallback;
  }

  if (const auto* value = std::get_if<bool>(&it->second)) {
    return *value;
  }

  return fallback;
}

double ReadDoubleArgument(const flutter::EncodableMap& arguments,
                          const char* name,
                          double fallback) {
  auto it = arguments.find(flutter::EncodableValue(name));
  if (it == arguments.end()) {
    return fallback;
  }

  if (const auto* value = std::get_if<double>(&it->second)) {
    return *value;
  }
  if (const auto* value = std::get_if<int32_t>(&it->second)) {
    return static_cast<double>(*value);
  }
  if (const auto* value = std::get_if<int64_t>(&it->second)) {
    return static_cast<double>(*value);
  }

  return fallback;
}

bool ApplyAccentPolicy(HWND window, const ACCENT_POLICY& accent) {
  HMODULE user32_module = GetModuleHandle(L"user32.dll");
  if (!user32_module) {
    return false;
  }

  auto set_window_composition_attribute =
      reinterpret_cast<SetWindowCompositionAttributeProc>(
          GetProcAddress(user32_module, "SetWindowCompositionAttribute"));
  if (!set_window_composition_attribute) {
    return false;
  }

  WINDOWCOMPOSITIONATTRIBDATA data = {
      kWindowCompositionAttributeAccentPolicy,
      const_cast<ACCENT_POLICY*>(&accent),
      sizeof(accent),
  };

  return set_window_composition_attribute(window, &data);
}

bool ApplyNativeWindowBackground(HWND window, bool is_blur, double blur_value) {
  if (is_blur) {
    ACCENT_POLICY accent = {
        ACCENT_ENABLE_ACRYLICBLURBEHIND,
        0,
        AcrylicTintColor(blur_value),
        0,
    };
    return ApplyAccentPolicy(window, accent);
  }

  ACCENT_POLICY accent = {
      ACCENT_DISABLED,
      0,
      0,
      0,
  };
  const bool applied = ApplyAccentPolicy(window, accent);
  ConfigureTransparentDwmFrame(window);
  InvalidateRect(window, nullptr, TRUE);
  return applied;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

void FlutterWindow::SetCalculatorWidth(int width) {
  HWND window = GetHandle();
  if (!window) {
    return;
  }

  RECT rect;
  GetWindowRect(window, &rect);

  HMONITOR monitor = MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST);
  UINT dpi = FlutterDesktopGetDpiForMonitor(monitor);
  double scale_factor = dpi / 96.0;
  int scaled_width = static_cast<int>(width * scale_factor);
  int anchored_left = rect.right - scaled_width;

  SetWindowPos(window, nullptr, anchored_left, rect.top, scaled_width,
               rect.bottom - rect.top, SWP_NOZORDER | SWP_NOACTIVATE);
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  window_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "little_calc/window",
          &flutter::StandardMethodCodec::GetInstance());
  window_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        HWND window = GetHandle();
        if (!window) {
          result->Error("window_unavailable", "Window handle is unavailable.");
          return;
        }

        const std::string& method = call.method_name();
        if (method == "drag") {
          ReleaseCapture();
          SendMessage(window, WM_NCLBUTTONDOWN, HTCAPTION, 0);
          result->Success();
        } else if (method == "minimize") {
          ShowWindow(window, SW_MINIMIZE);
          result->Success();
        } else if (method == "toggleMaximize") {
          result->Success();
        } else if (method == "setCalculatorWidth") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (!arguments) {
            result->Error("bad_args", "Expected width argument.");
            return;
          }

          auto width_it =
              arguments->find(flutter::EncodableValue("width"));
          if (width_it == arguments->end()) {
            result->Error("missing_width", "Expected width argument.");
            return;
          }

          int width = 0;
          if (const auto* int_width =
                  std::get_if<int32_t>(&width_it->second)) {
            width = *int_width;
          } else if (const auto* long_width =
                         std::get_if<int64_t>(&width_it->second)) {
            width = static_cast<int>(*long_width);
          }

          if (width <= 0) {
            result->Error("invalid_width", "Width must be positive.");
            return;
          }

          SetCalculatorWidth(width);
          result->Success();
        } else if (method == "setNativeBlur") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (!arguments) {
            result->Error("bad_args", "Expected blur arguments.");
            return;
          }

          g_is_blur = ReadBoolArgument(*arguments, "enabled", true);
          double blur = ReadDoubleArgument(*arguments, "blur", 0.0);
          bool applied = ApplyNativeWindowBackground(window, g_is_blur, blur);
          if (!applied) {
            result->Error("native_blur_unavailable",
                          "Native window background is unavailable on this Windows host.");
            return;
          }

          result->Success();
        } else if (method == "close") {
          PostMessage(window, WM_CLOSE, 0, 0);
          result->Success();
        } else {
          result->NotImplemented();
        }
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  window_channel_ = nullptr;

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
