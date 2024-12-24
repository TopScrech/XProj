import SwiftUI

struct ThreeColumnContent: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    var body: some View {
        @Bindable var nav = nav
        
        if let category = nav.selectedCategory {
            switch category {
            case .allItems:
                List(selection: $nav.selectedProj) {
                    ForEach(dataModel.projects) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                }
                .frame(minWidth: 600)
                .navigationTitle(category.localizedName)
                .experienceToolbar()
                
            case .derivedData:
                DerivedDataList()
                
            case .packageDependencies:
                PackageDepList()
                
            default:
                List(selection: $nav.selectedProj) {
                    ForEach(dataModel.projects(in: category)) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                }
                .frame(minWidth: 600)
                .navigationTitle(category.localizedName)
                .experienceToolbar()
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
