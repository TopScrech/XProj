import Foundation

struct AppStoreApp: Identifiable {
    let id = UUID()
    
    let name: String
    let url: URL
    
    init(_ name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

extension Target {
    func fetchAppStoreApp() async -> AppStoreApp? {
        do {
            guard let bundleId else {
                return nil
            }
            
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Decode JSON into AppStoreAppResponse
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(AppStoreAppResponse.self, from: data)
            
            // Find the first result matching the bundleId
            if let matchingResult = decodedResponse.results.first(where: { $0.bundleId == bundleId }),
               let trackViewUrl = URL(string: matchingResult.trackViewUrl) {
                return AppStoreApp(matchingResult.trackName, url: trackViewUrl)
            }
            
            return nil
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}

struct AppStoreAppResponse: Codable {
    let results: [AppStoreAppResponseResult]
}

struct AppStoreAppResponseResult: Codable {
    let trackName: String
    let trackViewUrl: String
    let bundleId: String
}
