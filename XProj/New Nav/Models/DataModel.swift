// An observable data model of recipes and miscellaneous groupings

import SwiftUI

@Observable
final class DataModel {
    private(set) var recipes: [Recipe]
    
    private var recipesById: [Recipe.ID: Recipe] = [:]
    
    /// The shared singleton data model object
    static let shared: DataModel = {
        try! DataModel(contentsOf: dataURL, options: .mappedIfSafe)
    }()
    
    /// Initialize a `DataModel` with the contents of a `URL`
    private init(contentsOf url: URL, options: Data.ReadingOptions) throws {
        let data = try Data(contentsOf: url, options: options)
        let recipes = try JSONDecoder().decode([Recipe].self, from: data)
        
        recipesById = Dictionary(uniqueKeysWithValues: recipes.map { recipe in
            (recipe.id, recipe)
        })
        
        self.recipes = recipes.sorted {
            $0.name < $1.name
        }
    }
    
    private static var dataURL: URL {
        get throws {
            let bundle = Bundle.main
            
            guard
                let path = bundle.path(forResource: "Recipes", ofType: "json")
            else {
                throw CocoaError(.fileReadNoSuchFile)
            }
            
            return URL(fileURLWithPath: path)
        }
    }
    
    /// The recipes for a given category, sorted by name
    func recipes(in category: Category?) -> [Recipe] {
        recipes.filter {
            $0.category == category
        }
    }
    
//    /// The related recipes for a given recipe, sorted by name
//    func recipes(relatedTo recipe: Recipe) -> [Recipe] {
//        recipes.filter {
//            recipe.related.contains($0.id)
//        }
//    }
    
    /// Accesses the recipe associated with the given unique identifier
    /// if the identifier is tracked by the data model; otherwise, returns `nil`
    subscript(recipeId: Recipe.ID) -> Recipe? {
        recipesById[recipeId]
    }
}
