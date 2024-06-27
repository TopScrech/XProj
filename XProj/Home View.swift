import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
//            NavigationLink("Projects") {
                ProjectList()
//            }
            
//            NavigationLink("Derived Data") {
//                DerivedDataList()
//            }
        }
    }
}

#Preview {
    HomeView()
}
