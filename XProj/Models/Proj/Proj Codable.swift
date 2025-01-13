import Foundation

struct CodableProj: Codable {
    var id: String
    var name: String
    var path: String
    var type: NavCategory
    var openedAt: Date
    var modifiedAt: Date?
    var createdAt: Date?
}

extension Proj {
    init(from codable: CodableProj) {
        id = codable.id
        name = codable.name
        path = codable.path
        type = codable.type
        openedAt = codable.openedAt
        modifiedAt = codable.modifiedAt
        createdAt = codable.createdAt
    }
    
    func toCodable() -> CodableProj {
        CodableProj(
            id: id,
            name: name,
            path: path,
            type: type,
            openedAt: openedAt,
            modifiedAt: modifiedAt,
            createdAt: createdAt
        )
    }
}
