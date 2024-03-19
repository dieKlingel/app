import UIKit
import Flutter
import PushKit
import linphonesw
import flutter_callkeep

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        // Linphone also has the ability to create a PKPushRegistry and handle incomming notifications, but since we have to call displayIncommingCall, during the execution of the delegate function, which is synchron and notifies the flutter callback which can only call displayIncommingCall asynchron, the callback finishes before the incomming call is displayed, and the app will be terminated. So we decided to handle PKPushRegistry by ourself.
        let voip = PKPushRegistry(queue: DispatchQueue.main)
        voip.delegate = self
        voip.desiredPushTypes = [.voIP]
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print(deviceToken);
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("didReceiveIncomingPushWith")
        guard type == .voIP else {
            return
        }
        
        let id = UUID().uuidString
        print(payload.dictionaryPayload)
        let callerName = payload.dictionaryPayload["from-uri"] as? String ?? ""
        let payload = payload.dictionaryPayload as NSDictionary
        //let aps = payload["aps"] as? NSDictionary ?? [:]
        //let callId = aps["call-id"] as? String ?? "";
        let data = flutter_callkeep.Data(id: id, callerName: callerName, handle: "", hasVideo: false)
        //set more data
        data.appName = "dieKlingel"
        data.extra = payload
        SwiftCallKeepPlugin.sharedInstance?.displayIncomingCall(data, fromPushKit: true)
        completion()
    }
}
