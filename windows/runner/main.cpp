#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <dwmapi.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

enum ACCENT_STATE {
  ACCENT_DISABLED = 0,
  ACCENT_ENABLE_GRADIENT = 1,
  ACCENT_ENABLE_TRANSPARENTGRADIENT = 2,
  ACCENT_ENABLE_BLURBEHIND = 3,
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

void EnableBlur(HWND hwnd) {
  HMODULE user32_module = GetModuleHandle(L"user32.dll");
  if (!user32_module) {
    return;
  }

  auto set_window_composition_attribute =
      reinterpret_cast<SetWindowCompositionAttributeProc>(
          GetProcAddress(user32_module, "SetWindowCompositionAttribute"));
  if (!set_window_composition_attribute) {
    return;
  }

  ACCENT_POLICY accent = {ACCENT_ENABLE_BLURBEHIND, 0, 0, 0};
  WINDOWCOMPOSITIONATTRIBDATA data = {19, &accent, sizeof(accent)};
  set_window_composition_attribute(hwnd, &data);

  MARGINS margins = {-1, -1, -1, -1};
  DwmExtendFrameIntoClientArea(hwnd, &margins);
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(390, 864);
  if (!window.Create(L"little_calc", origin, size)) {
    return EXIT_FAILURE;
  }
  EnableBlur(window.GetHandle());
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
