import SwiftUI

struct ProjCodeLines: View {
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    private let countedExtensions = [
        "swift","h","m","mm","c","cpp","cc","hpp",
        "metal","sh","py","rb","go","rs","java","kt","kts",
        "scala","php","cs","ts","tsx","js","jsx",
        "json","yaml","yml","xml","html","css",
        "md","sql","ini","toml","gradle","cmake"
    ]
    
    @State private var totalLines = 0
    @State private var isCounting = false
    
    var body: some View {
        Section {
            if totalLines > 0 {
                Text(totalLines)
            }
        } header: {
            Text("Code lines")
                .title2()
        }
        .task {
            await countLines()
        }
        .onChange(of: proj) {
            Task {
                await countLines()
            }
        }
    }
    
    private func countLines() async {
        guard !isCounting else {
            return
        }
        
        totalLines = 0
        isCounting = true
        
        let allowed = Set(countedExtensions.map {
            $0.lowercased()
        })
        
        let fileStrings: [String]? = await DataModel.listFilesRecursively(proj.path)
        var files: [URL] = [] // fallback if no files
        
        guard let fileStrings else {
            return
        }
        
        files = fileStrings.map {
            URL(fileURLWithPath: $0)
        }
        
        // 2) Filter by extension & count in parallel
        let total = await withTaskGroup(of: Int.self) { group -> Int in
            for file in files {
                let ext = file.pathExtension.lowercased()
                
                guard allowed.contains(ext) else {
                    continue
                }
                
                group.addTask(priority: .utility) {
                    (try? LineCounter.fastLineCount(file)) ?? 0
                }
            }
            
            var sum = 0
            
            for await partial in group {
                sum &+= partial
            }
            
            return sum
        }
        
        await MainActor.run {
            self.totalLines = total
            self.isCounting = false
        }
    }
}

#Preview {
    ProjCodeLines(previewProj1)
}
