import Flutter
import UIKit
import NetworkExtension
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
             let vpnChannel = FlutterMethodChannel(name: "com.example/vpn",
                                                   binaryMessenger: controller.binaryMessenger)
             
             vpnChannel.setMethodCallHandler { (call, result) in
                 if call.method == "isVPNConnected" {
                                 self.isVPNConnected { isConnected in
                                     result(isConnected)
                                 }
                             } else {
                                 result(FlutterMethodNotImplemented)
                             }
             }
    GeneratedPluginRegistrant.register(with: self)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    @available(iOS 9.0, *)
     private func isVPNConnected(completion: @escaping (Bool) -> Void) {
         let vpnManager = NEVPNManager.shared()
         
         vpnManager.loadFromPreferences { error in
             if let error = error {
                 print("Error loading VPN preferences: \(error.localizedDescription)")
                 completion(false)
                 return
             }
             
             let isConnected = vpnManager.connection.status == .connected
             completion(isConnected)
         }
     }

}
