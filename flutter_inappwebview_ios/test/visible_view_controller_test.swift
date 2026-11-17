import Foundation

final class UIView {
    var window: UIWindow?
    init(window: UIWindow? = nil) { self.window = window }
}

final class UIWindow {
    var rootViewController: UIViewController?
}

class UIViewController {
    var parent: UIViewController?
    var presentedViewController: UIViewController?
    var viewIfLoaded: UIView?
}

final class UINavigationController: UIViewController {
    var visibleViewController: UIViewController?
}

final class UITabBarController: UIViewController {
    var selectedViewController: UIViewController?
}

final class UIApplication {
    var keyWindow: UIWindow?
}

@main
enum VisibleViewControllerRegressionTest {
    static func main() {
        let application = UIApplication()
        let unrelatedWindow = UIWindow()
        let unrelatedController = attachedController(in: unrelatedWindow)
        unrelatedWindow.rootViewController = unrelatedController
        application.keyWindow = unrelatedWindow

        let ownedWindow = UIWindow()
        let registrar = attachedController(in: ownedWindow)
        ownedWindow.rootViewController = registrar
        precondition(application.visibleViewController(presentingFrom: registrar) === registrar)
        precondition(application.visibleViewController(presentingFrom: nil) === unrelatedController)

        // A full-screen presentation removes the presenting view from its window.
        let presented = attachedController(in: ownedWindow)
        registrar.presentedViewController = presented
        registrar.viewIfLoaded?.window = nil
        precondition(application.visibleViewController(presentingFrom: registrar) === presented)

        // Resolve through registrar containers, including presentations above a
        // navigation/tab hierarchy, without consulting the other scene's key window.
        registrar.presentedViewController = nil
        let navigation = UINavigationController()
        let tabs = UITabBarController()
        registrar.parent = navigation
        navigation.parent = tabs
        navigation.visibleViewController = registrar
        tabs.selectedViewController = navigation
        let overlay = attachedController(in: ownedWindow)
        navigation.presentedViewController = overlay
        precondition(application.visibleViewController(presentingFrom: registrar) === overlay)

        // No attached owned controller means no presentation in an unrelated scene.
        overlay.viewIfLoaded?.window = nil
        precondition(application.visibleViewController(presentingFrom: registrar) == nil)
        let unloadedRegistrar = UIViewController()
        precondition(application.visibleViewController(presentingFrom: unloadedRegistrar) == nil)
        print("VisibleViewController production hierarchy regression checks passed")
    }

    private static func attachedController(in window: UIWindow) -> UIViewController {
        let controller = UIViewController()
        controller.viewIfLoaded = UIView(window: window)
        return controller
    }
}
