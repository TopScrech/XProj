import Foundation
import Kingfisher

@Observable
final class ProjCodeLinesVM {
    var totalLines = 0
    var isCounting = false
    
    // MARK: - Cache (Kingfisher, stores plain Int as UTF-8)
    private func loadCachedLines(_ projName: String) -> Int? {
        if let data = try? ImageCache.default.diskStorage.value(forKey: "code_lines_" + projName),
           let string = String(data: data, encoding: .utf8),
           let value = Int(string) {
            return value
        }
        
        return nil
    }
    
    private func saveCachedLines(_ lines: Int, projName: String) {
        if let data = String(lines).data(using: .utf8) {
            try? ImageCache.default.diskStorage.store(
                value: data,
                forKey: "code_lines_" + projName,
                expiration: .days(30)
            )
        }
    }
    
    // MARK: - Line Counting
    func countLines(_ codeLineCountingExtensions: String, proj: Proj) async {
        // 0) Try cache first (30-day TTL)
        if let cached = loadCachedLines(proj.name) {
            self.totalLines = cached
        }
        
        guard !isCounting else {
            return
        }
        
        totalLines = 0
        isCounting = true
        
        let allowed = Set(
            codeLineCountingExtensions
                .split { $0 == "," || $0.isWhitespace } // split on commas and spaces
                .map { $0.lowercased() }
        )
        
        let fileStrings = await DataModel.listFilesRecursively(proj.path)
        var files: [URL] = [] // fallback if no files
        
        guard let fileStrings else {
            self.isCounting = false
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
                    (try? self.fastLineCount(file)) ?? 0
                }
            }
            
            var sum = 0
            
            for await partial in group {
                sum &+= partial
            }
            
            return sum
        }
        
        // 3) Save to cache & update UI
        saveCachedLines(total, projName: proj.name)
        
        self.totalLines = total
        self.isCounting = false
    }
    
    /// Counts lines by scanning bytes in chunks (efficient on large files)
    /// Treats '\n' as a newline and adds one final line if the file doesn't end with '\n'
    func fastLineCount(_ url: URL) throws -> Int {
        let handle = try FileHandle(forReadingFrom: url)
        
        defer {
            try? handle.close()
        }
        
        var count = 0
        var lastByteWasNewline = true
        
        while true {
            let data = try handle.read(upToCount: 64 * 1024) ?? Data()
            
            if data.isEmpty {
                break
            }
            
            // Count LF bytes
            for b in data {
                if b == 0x0A {
                    count += 1
                }
            }
            
            lastByteWasNewline = (data.last == 0x0A)
        }
        
        // Add final line if non-empty and not newline-terminated
        let fileSize = try handle.seekToEnd()
        
        if fileSize > 0 && !lastByteWasNewline {
            count += 1
        }
        
        return count
    }
}
