import Foundation

struct LineCounter {
    /// Counts lines by scanning bytes in chunks (efficient on large files)
    /// Treats '\n' as a newline and adds one final line if the file doesn't end with '\n'
    static func fastLineCount(_ url: URL) throws -> Int {
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
