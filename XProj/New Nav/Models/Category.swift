// An enumeration of recipe groupings used to display sidebar items

import SwiftUI

enum Category: Int, Hashable, CaseIterable, Identifiable, Codable {
    case dessert,
         pancake,
         salad,
         sandwich,
         allItems
    
    var id: Int {
        rawValue
    }
    
    /// The localized name of the recipe category.
    var localizedName: LocalizedStringKey {
        switch self {
        case .dessert: "Dessert"
        case .pancake: "Pancake"
        case .salad: "Salad"
        case .sandwich: "Sandwich"
        case .allItems: "All Items"
        }
    }
}
