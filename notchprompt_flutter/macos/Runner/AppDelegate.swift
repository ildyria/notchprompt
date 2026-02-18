import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    private var channel: FlutterMethodChannel?

    override func applicationDidFinishLaunching(_ notification: Notification) {
        // The Flutter engine is available on the main FlutterViewController.
        guard
            let controller = mainFlutterWindow?.contentViewController
                as? FlutterViewController
        else {
            super.applicationDidFinishLaunching(notification)
            return
        }

        channel = FlutterMethodChannel(
            name: "notchprompt/window",
            binaryMessenger: controller.engine.binaryMessenger
        )

        channel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        super.applicationDidFinishLaunching(notification)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        // App is tray-only — keep alive even if windows are hidden.
        return false
    }

    // MARK: - Method call handler

    private func handleMethodCall(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "setPrivacyMode":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "setPrivacyMode requires {enabled: Bool}",
                    details: nil
                ))
                return
            }
            setPrivacyMode(enabled: enabled)
            result(nil)

        case "setWindowLevel":
            guard let args = call.arguments as? [String: Any],
                  let levelName = args["level"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "setWindowLevel requires {level: String}",
                    details: nil
                ))
                return
            }
            setWindowLevel(levelName: levelName)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Privacy mode

    /// Prevents the overlay window from appearing in screen captures,
    /// recordings, and AirPlay mirrors.
    private func setPrivacyMode(enabled: Bool) {
        for window in NSApplication.shared.windows {
            window.sharingType = enabled ? .none : .readOnly
        }
    }

    // MARK: - Window level

    /// Sets the window level for all current Flutter windows.
    ///
    /// Supported levels:
    ///   "normal"       → NSWindow.Level.normal
    ///   "floating"     → NSWindow.Level.floating
    ///   "screenSaver"  → NSWindow.Level.screenSaver (above fullscreen apps)
    ///   "tornOffMenu"  → NSWindow.Level.tornOffMenu
    private func setWindowLevel(levelName: String) {
        let level: NSWindow.Level
        switch levelName {
        case "floating":
            level = .floating
        case "screenSaver":
            // .screenSaver sits above fullscreen spaces — matches Swift source.
            level = .screenSaver
        case "tornOffMenu":
            level = .tornOffMenu
        default:
            level = .normal
        }

        for window in NSApplication.shared.windows {
            window.level = level
            // Ensure overlay can join all spaces and persists over fullscreen.
            if level == .screenSaver {
                window.collectionBehavior = [
                    .canJoinAllSpaces,
                    .fullScreenAuxiliary,
                    .stationary,
                    .ignoresCycle,
                ]
            } else {
                window.collectionBehavior = []
            }
        }
    }
}
