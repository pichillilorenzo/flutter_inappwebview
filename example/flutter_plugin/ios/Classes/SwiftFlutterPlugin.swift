import Flutter
import UIKit
import WebKit
    
public class SwiftFlutterPlugin: NSObject, Flutter.FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    let frame: CGRect = UIScreen.main.bounds
    let tmpWindow = UIWindow(frame: frame)
    let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "viewController")
    let tmpController = UIViewController()
    let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
    tmpWindow.rootViewController = tmpController
    tmpWindow.windowLevel = UIWindowLevel(baseWindowLevel! + 1)
    tmpWindow.makeKeyAndVisible()
    tmpController.present(vc, animated: true, completion: nil)
    //tmpController.present(nav, animated: true) { () -> Void in }
    result(true)
  }
}

public class testViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var urlField: UITextField!
    @IBOutlet var done: UIButton!
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        print("asdasdasd")
    }
}
