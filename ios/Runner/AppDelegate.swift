import UIKit

/// iOS has a native lifecycle. Android still boots Flutter through MainActivity.
/// Do not inherit FlutterAppDelegate here: doing so can start an implicit engine.
@main
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
}
