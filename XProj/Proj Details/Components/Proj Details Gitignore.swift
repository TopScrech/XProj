import SwiftUI

struct ProjDetailsGitignore: View {
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    var body: some View {
        if let lines = processGitignore(path) {
            Section {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                }
            } header: {
                Text("Git ignore")
                    .title2()
            }
        }
    }
    
    private func processGitignore(_ path: String) -> [String]? {
        let gitignorePath = (path as NSString).appendingPathComponent(".gitignore")
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: gitignorePath) else {
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
}
