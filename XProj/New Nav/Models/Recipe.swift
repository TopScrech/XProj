// A data model for a recipe and its metadata, including its related recipes

import SwiftUI

struct Recipe: Decodable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var category: Category
    var ingredients: [Ingredient]
//    var related: [Recipe.ID] = []
    var imageName: String? = nil
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        
        id = UUID(uuidString: idString)!
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(Category.self, forKey: .category)
        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        
//        let relatedIdStrings = try container.decode([String].self, forKey: .related)
        
//        related = relatedIdStrings.compactMap(UUID.init(uuidString:))
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id,
             name,
             category,
             ingredients,
             related,
             imageName
    }
}

extension Recipe {
    static var mock: Recipe {
        DataModel.shared.recipes[0]
    }
}
