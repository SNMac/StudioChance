import Flutter
import UIKit
import OSLog
import google_sign_in_ios

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        #if targetEnvironment(simulator)
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        GIDSignIn.sharedInstance.configureDebugProvider(withAPIKey: apiKey) { error in
            if let error {
                logger.info("Error configuring GIDSignIn for App Check: \(error)")
            }
        }
        #else
        GIDSignIn.sharedInstance.configure { error in
            if let error {
                logger.info("Error configuring GIDSignIn for Firebase App Check: \(error)")
            }
        }
        #endif
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
