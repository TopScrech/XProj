// Nav model used to persist and restore the nav state

import SwiftUI

@Observable
final class NavModel: Codable {
    /// Selected nav category
    var selectedCategory: NavCategory?
    
    /// Homogenous nav state
    var projPath: [Proj]
    
    /// Leading columns' visibility states
    var columnVisibility: NavigationSplitViewVisibility
    var showExperiencePicker = false
    
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()
    
    /// The URL for the JSON file that stores the proj data
    private static var dataUrl: URL {
        .cachesDirectory.appending(path: "NavigationData.json")
    }
    
    /// Singleton object
    static let shared = {
        if let model = try? NavModel(contentsOf: dataUrl) {
            model
        } else {
            NavModel()
        }
    }()
    
    /// Initialize a `NavModel` that enables programmatic control of leading columns’
    /// visibility, selected nav category, and navigation state based on proj data
    init(
        columnVisibility: NavigationSplitViewVisibility = .automatic,
        selectedCategory: NavCategory? = nil,
        projPath: [Proj] = []
    ) {
        self.columnVisibility = columnVisibility
        self.selectedCategory = selectedCategory
        self.projPath = projPath
    }
    
    /// Initialize a `DataModel` with the contents of a `URL`
    private convenience init(
        contentsOf url: URL,
        options: Data.ReadingOptions = .mappedIfSafe
    ) throws {
        let data = try Data(contentsOf: url, options: options)
        let model = try Self.decoder.decode(Self.self, from: data)
        
        self.init(
            columnVisibility: model.columnVisibility,
            selectedCategory: model.selectedCategory,
            projPath: model.projPath
        )
    }
    
    func clearNavCache() {
        do {
            try FileManager.default.removeItem(at: Self.dataUrl)
        } catch {
            print(error)
        }
    }
    
    /// Loads the navigation data for the nav model from a previously saved state
    func load() throws {
        let model = try NavModel(contentsOf: Self.dataUrl)
        
        selectedCategory = model.selectedCategory
        projPath = model.projPath
        columnVisibility = model.columnVisibility
    }
    
    /// Saves the JSON data for the nav model at its current state
    func save() throws {
        try jsonData?.write(to: Self.dataUrl)
    }
    
    /// Selected projects
    var selectedProj: Set<Proj> {
        get {
            Set(projPath)
        } set {
            projPath = Array(newValue)
        }
    }
    
    /// The JSON data used to encode and decode the nav model at its current state
    private var jsonData: Data? {
        get {
            try? Self.encoder.encode(self)
        } set {
            guard
                let data = newValue,
                let model = try? Self.decoder.decode(Self.self, from: data)
            else {
                return
            }
            
            selectedCategory = model.selectedCategory
            projPath = model.projPath
            columnVisibility = model.columnVisibility
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.selectedCategory = try container.decodeIfPresent(
            NavCategory.self,
            forKey: .selectedCategory
        )
        
        let projPathIds = try container.decode(
            [Proj.ID].self,
            forKey: .recipePathIds
        )
        
        self.projPath = projPathIds.compactMap {
            DataModel.shared[$0]
        }
        
        self.columnVisibility = try container.decode(
            NavigationSplitViewVisibility.self,
            forKey: .columnVisibility
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedCategory, forKey: .selectedCategory)
        try container.encode(projPath.map(\.id), forKey: .recipePathIds)
        try container.encode(columnVisibility, forKey: .columnVisibility)
    }
    
    private enum CodingKeys: String, CodingKey {
        case selectedCategory,
             recipePathIds,
             columnVisibility
    }
}
