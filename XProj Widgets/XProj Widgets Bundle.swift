import SwiftUI
import WidgetKit

@main
struct XProjWidgetsBundle: WidgetBundle {
    var body: some Widget {
        XProjWidgets()
        
        if #available(macOS 26, *) {
            XProjWidgetsControl()
        }
    }
}
