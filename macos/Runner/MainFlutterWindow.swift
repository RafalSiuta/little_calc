import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private enum WindowSize {
    static let compactWidth: CGFloat = 390
    static let expandedWidth: CGFloat = 803
    static let height: CGFloat = 864
  }

  private var windowChannel: FlutterMethodChannel?

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
}
