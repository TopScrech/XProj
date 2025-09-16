import Foundation

//@Observable
//final class ProjCardVM {
extension DataModel {
    func findXcodeprojFile(_ folderPath: String) -> (found: Bool, filePath: String?) {
        let fm = FileManager.default
        
        do {
            let contents = try fm.contentsOfDirectory(atPath: folderPath)
            
            for item in contents {
                if item.hasSuffix(".xcodeproj") {
                    let filePath = (folderPath as NSString)
                        .appendingPathComponent(item)
                    
                    return (true, filePath)
                }
            }
        } catch {
            print("Failed to read directory contents:", error.localizedDescription)
        }
        
        return (false, nil)
    }
    
    func launchProj(_ filePath: String) {
        let fm = FileManager.default
        
        if fm.fileExists(atPath: filePath) {
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [filePath]
            
            do {
                try task.run()
            } catch {
                print("Failed to launch Xcode:", error.localizedDescription)
            }
        } else {
            print("File does not exist at path:", filePath)
        }
    }
}
