import SwiftUI

struct ThreeColumnContent: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        @Bindable var nav = nav
        
        if let category = nav.selectedCategory {
            switch category {
            case .allItems:
                List(selection: $nav.selectedProj) {
                    ForEach(vm.filteredProjects) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                }
                .frame(minWidth: 600)
                .navigationTitle(category.localizedName)
                
            case .derivedData:
                DerivedDataList()
                
            case .packageDependencies:
                PackageDepList()
                
            default:
                List(selection: $nav.selectedProj) {
                    ForEach(vm.projects(in: category)) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                }
                .frame(minWidth: 600)
                .navigationTitle(category.localizedName)
            }
        } else {
            Text("Choose a category")
                .navigationTitle("")
        }
    }
}

#Preview {
    ThreeColumnContent()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
}
