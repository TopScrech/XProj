import Foundation
import OSLog

//@Observable
//final class ProjCardVM {
extension DataModel {
    func findXcodeprojFile(_ folderPath: String) -> (found: Bool, filePath: String?) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
            
            for item in contents {
                if item.hasSuffix(".xcodeproj") {
                    let filePath = (folderPath as NSString)
                        .appendingPathComponent(item)
                    
                    return (true, filePath)
                }
            }
        } catch {
            Logger().error("Failed to read dir contents: \(error)")
        }
        
        return (false, nil)
    }
    
    func launchProj(_ filePath: String) {
        if FileManager.default.fileExists(atPath: filePath) {
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [filePath]
            
            do {
                try task.run()
            } catch {
                Logger().error("Failed to launch Xcode: \(error)")
            }
        } else {
            Logger().error("File does not exist at: \(filePath)")
        }
    }
}
