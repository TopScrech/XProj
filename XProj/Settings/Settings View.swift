import SwiftUI

struct SettingsView: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        VStack {
            Button("Choose projects folder") {
                vm.openFolderPicker()
            }
        }
        .frame(width: 200, height: 300)
    }
}

#Preview {
    SettingsView()
        .environment(ProjectListVM())
}
