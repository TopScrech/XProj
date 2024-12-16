import ScrechKit

struct ProjCard: View {
    @Environment(ProjListVM.self) private var vm
    
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        NavigationLink {
            ProjDetails(proj)
        } label: {
            HStack {
                ProjCardImage(proj)
                
                VStack(alignment: .leading) {
                    Text(proj.name)
                    
                    let path = proj.path.replacingOccurrences(of: vm.projectsFolder, with: "~")
                    
                    Text(path)
                        .footnote()
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                Text(formattedDate(proj.openedAt))
                    .secondary()
                
                //            Text(proj.attributes[.size] as? String ?? "")
                //                .footnote()
                //                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 5)
        }
        .contextMenu {
            Button {
                vm.openProjects([proj.path])
            } label: {
                Text("Open in Xcode")
            }
            
            Button {
                openInFinder(rootedAt: proj.path)
            } label: {
                Text("Open in Finder")
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let currentYear = calendar.component(.year, from: now)
            let dateYear = calendar.component(.year, from: date)
            
            if currentYear == dateYear {
                formatter.dateFormat = "MMM d"
            } else {
                formatter.dateFormat = "MMM d, yyyy"
            }
            
            return formatter.string(from: date)
        }
    }
}

//#Preview {
//    List {
//        ProjCard(.init(
//            name: "Preview",
//            path: "/",
//            type: .proj,
//            lastOpened: Date(),
//            attributes: [:]
//        ))
//
//        ProjCard(.init(
//            name: "Preview",
//            path: "/",
//            type: .package,
//            lastOpened: Date(),
//            attributes: [:]
//        ))
//    }
//}
