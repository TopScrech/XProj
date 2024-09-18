import SwiftUI
import WidgetKit
import AppIntents

struct XProjWidgetsControl: ControlWidget {
    static let kind = "dev.topscrech.Bisquit-host.XProj Widgets"
    
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value.isRunning,
                action: StartTimerIntent(value.name)
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

extension XProjWidgetsControl {
    struct Value {
        var isRunning: Bool
        var name: String
    }
    
    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: TimerConfiguration) -> Value {
            XProjWidgetsControl.Value(isRunning: false, name: configuration.timerName)
        }
        
        func currentValue(configuration: TimerConfiguration) async throws -> Value {
            let isRunning = true // Check if the timer is running
            return XProjWidgetsControl.Value(isRunning: isRunning, name: configuration.timerName)
        }
    }
}

struct TimerConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Timer Name Configuration"
    
    @Parameter(title: "Timer Name", default: "Timer")
    var timerName: String
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"
    
    @Parameter(title: "Timer Name")
    var name: String
    
    @Parameter(title: "Timer is running")
    var value: Bool
    
    init() {}
    
    init(_ name: String) {
        self.name = name
    }
    
    func perform() async throws -> some IntentResult {
        // Start the timer…
        return .result()
    }
}