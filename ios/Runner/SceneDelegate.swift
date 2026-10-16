import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var container: NativeAppContainer?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let dependencies = NativeAppContainer()
        container = dependencies
        let window = UIWindow(windowScene: windowScene)
        // Native routing happens before any view or Dart isolate is created.
        window.rootViewController = NativeHostingController(rootView: NativeAppView(container: dependencies))
        window.makeKeyAndVisible()
        self.window = window
    }
}
final class NativeHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // Dismiss without swallowing buttons, category selection, or scrolling.
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var touchedView = touch.view
        while let current = touchedView {
            // Tapping inside an editor must keep its keyboard and cursor behavior.
            if current is UITextField || current is UITextView { return false }
            touchedView = current.superview
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
