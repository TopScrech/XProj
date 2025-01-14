import SwiftUI

struct ProjDetailsGitignore: View {
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
                ForEach(lines, id: \.self) { line in
                    Text(line)
                }
            } header: {
                Button("Git ignore") {
                    openGitignore()
                }
                .title2()
                .buttonStyle(.plain)
            }
        }
    }
    
    private func processGitignore(_ path: String) -> [String]? {
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: gitignorePath) else {
            print(".gitignore file does not exist at the specified path")
            return nil
        }
        
        guard let contents = try? String(contentsOfFile: gitignorePath, encoding: .utf8) else {
            print("Failed to read .gitignore file")
            return nil
        }
        
        let lines = contents
            .components(separatedBy: .newlines)
            .filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty
            }
        
        return lines
    }
    
    private func openGitignore() {
        let fileUrl = URL(fileURLWithPath: gitignorePath)
        
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: gitignorePath) else {
            print(".gitignore file does not exist at the specified path")
            return
        }
        
        NSWorkspace.shared.open(fileUrl)
    }
}
