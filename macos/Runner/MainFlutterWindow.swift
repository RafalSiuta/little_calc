import Cocoa
import FlutterMacOS

private final class PassthroughVisualEffectView: NSVisualEffectView {
  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil
  }
}

class MainFlutterWindow: NSWindow {
  private enum WindowSize {
    static let compactWidth: CGFloat = 390
    static let expandedWidth: CGFloat = 803
    static let height: CGFloat = 864
  }

  private var windowChannel: FlutterMethodChannel?
  private var nativeBlurView: NSVisualEffectView?

  override var canBecomeKey: Bool {
    return true
  }

  override var canBecomeMain: Bool {
    return true
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()

    configureTransparentWindow()
    configureTransparentFlutterSurface(for: flutterViewController)
    configureWindowChannel(with: flutterViewController)

    let windowFrame = initialWindowFrame()
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    installNativeBlurView(behind: flutterViewController.view)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  private func configureTransparentWindow() {

    styleMask = [.borderless]
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    standardWindowButton(.closeButton)?.isHidden = true
    standardWindowButton(.miniaturizeButton)?.isHidden = true
    standardWindowButton(.zoomButton)?.isHidden = true
    isMovableByWindowBackground = true
    isOpaque = false
    backgroundColor = .clear
    appearance = nil
    hasShadow = false
    minSize = NSSize(width: WindowSize.compactWidth, height: WindowSize.height)
    maxSize = NSSize(width: WindowSize.expandedWidth, height: WindowSize.height)
    collectionBehavior.insert(.fullScreenNone)

    contentView?.wantsLayer = true
    contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    contentView?.alphaValue = 1
  }

  private func configureTransparentFlutterSurface(for flutterViewController: FlutterViewController) {
    flutterViewController.backgroundColor = .clear
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor
    flutterViewController.view.alphaValue = 1
  }

  private func installNativeBlurView(behind flutterView: NSView) {
    guard let frameView = flutterView.superview else {
      return
    }

    let blurView = PassthroughVisualEffectView(frame: flutterView.frame)
    blurView.autoresizingMask = [.width, .height]
    blurView.blendingMode = .behindWindow
    blurView.material = .hudWindow
    blurView.state = .active

    frameView.addSubview(blurView, positioned: .below, relativeTo: flutterView)
    nativeBlurView = blurView
  }

  private func configureWindowChannel(with flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "little_calc/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(
          code: "window_unavailable",
          message: "Window is unavailable.",
          details: nil
        ))
        return
      }

      switch call.method {
      case "drag":
        self.dragWindow()
        result(nil)
      case "minimize":
        self.miniaturize(nil)
        result(nil)
      case "toggleMaximize":
        result(nil)
      case "setCalculatorWidth":
        self.setCalculatorWidth(from: call.arguments, result: result)
      case "setNativeBlur":
        self.setNativeBlur(from: call.arguments, result: result)
      case "close":
        self.close()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    windowChannel = channel
  }

  private func initialWindowFrame() -> NSRect {
    var windowFrame = frame
    windowFrame.origin.y = windowFrame.maxY - WindowSize.height
    windowFrame.size = NSSize(width: WindowSize.compactWidth, height: WindowSize.height)
    return windowFrame
  }

  private func dragWindow() {
    guard let event = NSApp.currentEvent else {
      return
    }

    performDrag(with: event)
  }

  private func setCalculatorWidth(from arguments: Any?, result: FlutterResult) {
    guard
      let arguments = arguments as? [String: Any],
      let widthValue = arguments["width"] as? NSNumber
    else {
      result(FlutterError(
        code: "bad_args",
        message: "Expected width argument.",
        details: nil
      ))
      return
    }

    let width = CGFloat(truncating: widthValue)
    guard width > 0 else {
      result(FlutterError(
        code: "invalid_width",
        message: "Width must be positive.",
        details: nil
      ))
      return
    }

    let clampedWidth = min(max(width, WindowSize.compactWidth), WindowSize.expandedWidth)
    var nextFrame = frame
    nextFrame.origin.x = frame.maxX - clampedWidth
    nextFrame.size.width = clampedWidth
    nextFrame.size.height = WindowSize.height

    setFrame(nextFrame, display: true, animate: true)
    result(nil)
  }

  private func setNativeBlur(from arguments: Any?, result: FlutterResult) {
    guard let arguments = arguments as? [String: Any] else {
      result(FlutterError(
        code: "bad_args",
        message: "Expected blur arguments.",
        details: nil
      ))
      return
    }

    let enabled = boolArgument(in: arguments, named: "enabled", fallback: true)
    let blur = doubleArgument(in: arguments, named: "blur", fallback: 0)
    applyNativeBlur(enabled: enabled, blur: blur)
    result(nil)
  }

  private func applyNativeBlur(enabled: Bool, blur: Double) {
    guard let nativeBlurView = nativeBlurView else {
      return
    }

    let normalizedBlur = normalizedBlurValue(blur)
    nativeBlurView.material = material(for: normalizedBlur)
    nativeBlurView.state = enabled && normalizedBlur > 0 ? .active : .inactive
    nativeBlurView.isHidden = !enabled || normalizedBlur <= 0
  }

  private func normalizedBlurValue(_ blur: Double) -> Double {
    let normalized = blur > 1 ? blur / 40 : blur
    return min(max(normalized, 0), 1)
  }

  private func material(for normalizedBlur: Double) -> NSVisualEffectView.Material {
    if normalizedBlur < 0.34 {
      return .underWindowBackground
    }

    if normalizedBlur < 0.67 {
      return .sidebar
    }

    return .hudWindow
  }

  private func boolArgument(
    in arguments: [String: Any],
    named name: String,
    fallback: Bool
  ) -> Bool {
    if let value = arguments[name] as? Bool {
      return value
    }

    if let value = arguments[name] as? NSNumber {
      return value.boolValue
    }

    return fallback
  }

  private func doubleArgument(
    in arguments: [String: Any],
    named name: String,
    fallback: Double
  ) -> Double {
    if let value = arguments[name] as? Double {
      return value
    }

    if let value = arguments[name] as? NSNumber {
      return value.doubleValue
    }

    return fallback
  }
}
