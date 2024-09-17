import SwiftUI

struct DerivedDataList: View {
    @State private var vm = DerivedDataVM()
    
    var body: some View {
        List {
            Button("Picker") {
                vm.openFolderPicker()
            }
            
            ForEach(vm.filteredFolders, id: \.self) { folder in
                Text(folder)
            }
        }
        .searchable(text: $vm.searchPrompt)
        .refreshableTask {
            DispatchQueue.global(qos: .background).async {
                vm.getFolders()
            }
        }
    }
}

#Preview {
    DerivedDataList()
}
