import Foundation

@Observable
final class CodeLinesVM {
    var isCounting = false
    var fileLineItems: [FileLines] = []
    
    func countLines(_ codeLineCountingExtensions: String, at path: String?) async {
        guard !isCounting, let path else {
            return
        }
        
        isCounting = true
        fileLineItems = []
        
        let allowed = Set(
            codeLineCountingExtensions
                .split { $0 == "," || $0.isWhitespace }
                .map { $0.lowercased() }
        )
        
        guard let fileStrings = await DataModel.listFilesRecursively(path) else {
            isCounting = false
            return
        }
        
        let urls = fileStrings.map {
            URL(fileURLWithPath: $0)
        }
        
        let items = await withTaskGroup(of: FileLines?.self) { group in
            for url in urls {
                let ext = url.pathExtension.lowercased()
                
                guard allowed.contains(ext) else {
                    continue
                }
                
                group.addTask(priority: .utility) {
                    let lines = (try? await self.fastLineCount(url)) ?? 0
                    return FileLines(url: url, lines: lines)
                }
            }
            
            var collected: [FileLines] = []
            
            for await item in group {
                if let item {
                    collected.append(item)
                }
            }
            
            return collected
        }
        
        fileLineItems = items.sorted {
            $0.path < $1.path
        }
        
        isCounting = false
    }
    
    func fastLineCount(_ url: URL) async throws -> Int {
        let handle = try FileHandle(forReadingFrom: url)
        
        defer {
            try? handle.close()
        }
        
        var count = 0
        var lastByteWasNewline = true
        var sawAnyByte = false
        
        for try await b in handle.bytes {
            sawAnyByte = true
            
            if b == 0x0A {
                count &+= 1
                lastByteWasNewline = true
            } else {
                lastByteWasNewline = false
            }
        }
        
        if sawAnyByte && !lastByteWasNewline {
            count &+= 1
        }
        
        return count
    }
}
