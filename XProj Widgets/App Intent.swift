import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Configuration"
    static let description: IntentDescription = "This is an example widget"
    
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
