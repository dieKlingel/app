import Foundation
import linphonesw

class NativeVideoRendererFactory : NSObject, FlutterPlatformViewFactory {
    
    let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }
    
    public func create( withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NativeVideoRenderer(messenger: messenger, frame: frame, viewId:viewId, args:args)
    }
}

public class NativeVideoRenderer : NSObject, FlutterPlatformView {
    let frame : CGRect
    let uiView: UIView
    let viewId : Int64
    let messenger : FlutterBinaryMessenger
    let channel: FlutterMethodChannel
    
    init(messenger: FlutterBinaryMessenger, frame:CGRect, viewId:Int64, args: Any?){
        self.messenger = messenger
        self.frame = frame
        self.viewId = viewId
        self.uiView = UIView(frame: self.frame)
        channel = FlutterMethodChannel(name: "NativeVideoRenderer/\(viewId)", binaryMessenger: messenger)
        super.init()

        channel.setMethodCallHandler(handler)
    }
    
    public func handler(call: FlutterMethodCall, result: FlutterResult) -> Void {
        switch call.method {
        case "getNativeTextureId":
            let cPtr = UnsafeMutableRawPointer(Unmanaged.passRetained(self.uiView).toOpaque())
            let cInt = Int(bitPattern: cPtr);
            result(cInt)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func view() -> UIView {
        let view : UIView = uiView
        view.backgroundColor = UIColor.lightGray

        return view
    }
    
}
