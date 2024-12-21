// A data model for a recipe and its metadata, including its related recipes

import SwiftUI

struct Recipe: Decodable, Hashable, Identifiable {
    var id: String
    var name: String
    let type: ProjType
    var category: Category
    let openedAt: Date
    let modifiedAt: Date?
    let createdAt: Date?
    
    //    var ingredients: [Ingredient] = []
    //    var related: [Recipe.ID] = []
    //    var imageName: String? = nil
    
    init(
        id: String,
        name: String,
        type: ProjType,
        category: Category,
        openedAt: Date,
        modifiedAt: Date?,
        createdAt: Date?
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.category = category
        self.openedAt = openedAt
        self.modifiedAt = modifiedAt
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(ProjType.self, forKey: .type)
        
        category = try container.decode(Category.self, forKey: .category)
        
        openedAt = try container.decode(Date.self, forKey: .openedAt)
        modifiedAt = try container.decodeIfPresent(Date.self, forKey: .modifiedAt)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        
        //        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        
        //        let relatedIdStrings = try container.decode([String].self, forKey: .related)
        
        //        related = relatedIdStrings.compactMap(UUID.init(uuidString:))
        //        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id,
             name,
             type,
             category,
             openedAt,
             modifiedAt,
             createdAt
    }
}

extension Recipe {
    static var mock: Recipe {
        DataModel.shared.projects[0]
    }
}
