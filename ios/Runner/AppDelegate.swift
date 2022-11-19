import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?

    private let linkStreamHandler = LinkStreamHandler()
    
    private var initialLink: String?
    
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      let controller = window.rootViewController as! FlutterViewController
      methodChannel = FlutterMethodChannel(name: "city.visit.braila", binaryMessenger: controller.binaryMessenger)
      eventChannel = FlutterEventChannel(name: "city.visit.braila/incomingRedirects", binaryMessenger: controller.binaryMessenger)

      methodChannel?.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
          guard call.method == "initialLink" else {
              result(FlutterMethodNotImplemented)
              return
          }
      })
      
      GeneratedPluginRegistrant.register(with: self)
      eventChannel?.setStreamHandler(linkStreamHandler)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        eventChannel?.setStreamHandler(linkStreamHandler)
        return linkStreamHandler.handleLink(url.absoluteString)
    }
}

class LinkStreamHandler:NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?

    var queuedLinks = [String]()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        queuedLinks.forEach({ events($0) })
        queuedLinks.removeAll()

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil

        return nil
    }

    func handleLink(_ link: String) -> Bool {
        guard let eventSink = eventSink else {
            queuedLinks.append(link)
            return false
        }

        eventSink(link)
        return true
    }
}
