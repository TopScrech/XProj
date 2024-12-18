import SwiftUI

func openFolderPicker(completion: @escaping (URL?) -> Void) {
    let panel = NSOpenPanel()
    
    panel.canChooseFiles = false
    panel.canCreateDirectories = true
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    
    panel.begin { response in
        if response == .OK, let url = panel.url {
            completion(url)
        } else {
            completion(nil)
        }
    }
}
