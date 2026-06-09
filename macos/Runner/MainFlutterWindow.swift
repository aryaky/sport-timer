import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    super.awakeFromNib()

    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Compact fixed-size window
    let size = NSSize(width: 380, height: 500)
    self.setContentSize(size)
    self.minSize = size
    self.maxSize = size
    
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)
  }
}
