// The content view for the nav stack view experience

import SwiftUI

struct StackContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = ProjType.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.projPath) {
            List(categories) { category in
                Section {
                    ForEach(dataModel.projects(in: category)) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                } header: {
                    Text(category.localizedName)
                }
            }
            .navigationTitle("Categories")
            .experienceToolbar()
            .navigationDestination(for: Proj.self) { proj in
                ProjDetails(proj)
                    .experienceToolbar()
                
                //                RecipeDetail(proj) { relatedProj in
                //                    Button {
                //                        nav.projPath.append(relatedProj)
                //                    } label: {
                //                        RecipeTile(relatedProj)
                //                    }
                //                    .buttonStyle(.plain)
                //                }
            }
        }
    }
}

#Preview() {
    StackContainer()
        .environment(DataModel.shared)
        .environment(NavModel.shared)
}
