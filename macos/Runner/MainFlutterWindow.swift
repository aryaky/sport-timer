import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    super.awakeFromNib()

    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // ---- Borderless / transparent window setup ----
    self.styleMask = [.borderless, .fullSizeContentView]
    self.isMovableByWindowBackground = true
    self.hasShadow = true
    self.isOpaque = false
    self.backgroundColor = NSColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1.0)

    // Make Flutter view transparent
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor

    let size = NSSize(width: 380, height: 480)
    self.setContentSize(size)
    self.minSize = size
    self.maxSize = size
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)
  }
}
