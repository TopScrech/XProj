import Foundation

struct AppStoreApp: Identifiable, Decodable, Hashable {
    var id = UUID()
    
    let name: String
    let url: URL
    
    init(_ name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

extension Proj {
    func fetchAppStoreApp(_ bundleId: String?) async -> AppStoreApp? {
        guard let bundleId else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decodedResponse = try decoder.decode(AppStoreAppResponse.self, from: data)
            
            let matchingResult = decodedResponse.results.first {
                $0.bundleId == bundleId
            }
            
            guard
                let matchingResult,
                let trackViewUrl = URL(string: matchingResult.trackViewUrl)
            else {
                return nil
            }
            
            return AppStoreApp(matchingResult.trackName, url: trackViewUrl)
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}

fileprivate struct AppStoreAppResponse: Codable {
    let results: [AppStoreAppResponseResult]
}

fileprivate struct AppStoreAppResponseResult: Codable {
    let trackName: String
    let trackViewUrl: String
    let bundleId: String
}
