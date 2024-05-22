import SwiftUI

struct ProjectCard: View {
    private let project: Project
    
    init(_ project: Project) {
        self.project = project
    }
    
    var body: some View {
        HStack {
            Image(systemName: project.icon)
                .foregroundStyle(project.iconColor)
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(project.name)
                
                Text(project.type.rawValue)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            Text(project.lastOpened, format: .dateTime)
            
            //            Text(project.attributes[.size] as? String ?? "")
            //                .footnote()
            //                .foregroundStyle(.secondary)
            
            let (found, filePath) = findXcodeprojFile(project.path)
            
            if found, let filePath = filePath {
                Button {
                    launchProject(filePath)
                } label: {
                    Image(systemName: "play")
                }
            }
        }
        .padding(.vertical, 5)
    }
    
    private func findXcodeprojFile(_ folderPath: String) -> (found: Bool, filePath: String?) {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: folderPath)
            
            for item in contents {
                if item.hasSuffix(".xcodeproj") {
                    let filePath = (folderPath as NSString).appendingPathComponent(item)
                    return (true, filePath)
                }
            }
        } catch {
            print("Failed to read directory contents: \(error.localizedDescription)")
        }
        
        return (false, nil)
    }
    
    private func launchProject(_ filePath: String) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [filePath]
            
            do {
                try task.run()
            } catch {
                print("Failed to launch Xcode: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(filePath)")
        }
    }
}

#Preview {
    List {
        ProjectCard(.init(
            name: "Preview",
            path: "/",
            type: .proj,
            lastOpened: Date(),
            attributes: [:]
        ))
    }
}
