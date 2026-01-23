import SwiftUI

struct ProjGitignore: View {
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    private var gitignorePath: String {
        (path as NSString).appendingPathComponent(".gitignore")
    }
    
    var body: some View {
        if let lines = processGitignore(path) {
            Section {
                ForEach(lines, id: \.self) {
                    Text($0)
                        .lineLimit(1)
                }
            } header: {
                Button("Git ignore", action: openGitignore)
                    .title2()
                    .buttonStyle(.plain)
                    .onDrag {
                        let fileURL = URL(fileURLWithPath: gitignorePath)
                        return NSItemProvider(object: fileURL as NSURL)
                    } preview: {
                        Image(systemName: "text.document")
                    }
            }
        }
    }
    
    private func processGitignore(_ path: String) -> [String]? {
        guard FileManager.default.fileExists(atPath: gitignorePath) else {
            print(".gitignore file does not exist at this path:", gitignorePath)
            return nil
        }
        
        guard let contents = try? String(contentsOfFile: gitignorePath, encoding: .utf8) else {
            print("Failed to read .gitignore")
            return nil
        }
        
        return contents
            .components(separatedBy: .newlines)
            .filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty
            }
    }
    
    private func openGitignore() {
        let fileURL = URL(fileURLWithPath: gitignorePath)
        
        guard FileManager.default.fileExists(atPath: gitignorePath) else {
            print(".gitignore file does not exist at this path:", gitignorePath)
            return
        }
        
        NSWorkspace.shared.open(fileURL)
    }
}
