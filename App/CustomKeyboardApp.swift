import UIKit
import SwiftUI

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let appWindow = UIWindow(frame: UIScreen.main.bounds)
        appWindow.rootViewController = UIHostingController(rootView: ContentView())
        appWindow.makeKeyAndVisible()
        window = appWindow
        return true
    }
}
