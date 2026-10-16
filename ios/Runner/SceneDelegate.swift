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
        NotificationCenter.default.addObserver(self, selector: #selector(addKeyboardDismissButton(_:)),
                                               name: UITextField.textDidBeginEditingNotification, object: nil)
    }

    @objc private func addKeyboardDismissButton(_ notification: Notification) {
        guard let field = notification.object as? UITextField,
              field.isDescendant(of: view) else { return }
        let accessory = KeyboardDismissAccessory(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 72))
        accessory.closeButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        field.inputAccessoryView = accessory
        field.reloadInputViews()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

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

// Transparent accessory keeps only the floating button visible above the keyboard.
private final class KeyboardDismissAccessory: UIView {
    let closeButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        autoresizingMask = [.flexibleWidth]
        closeButton.backgroundColor = UIColor(red: 0.94, green: 0.945, blue: 0.95, alpha: 1)
        closeButton.tintColor = UIColor(white: 0.10, alpha: 1)
        closeButton.setImage(UIImage(systemName: "keyboard.chevron.compact.down",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)), for: .normal)
        closeButton.accessibilityLabel = "Đóng bàn phím"
        closeButton.layer.cornerRadius = 26
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.white.cgColor
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOpacity = 0.08
        closeButton.layer.shadowRadius = 12
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addSubview(closeButton)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        closeButton.frame = CGRect(x: bounds.width - safeAreaInsets.right - 16 - 52,
                                   y: bounds.height - 12 - 52, width: 52, height: 52)
        closeButton.layer.shadowPath = UIBezierPath(ovalIn: closeButton.bounds).cgPath
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === self ? nil : hit
    }
}
