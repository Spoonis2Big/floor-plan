import SwiftUI

struct Furniture: Identifiable, Codable {
    let id: UUID
    var type: FurnitureType
    var position: CGPoint
    var rotation: Angle
    var size: CGSize
    
    init(
        id: UUID = UUID(),
        type: FurnitureType,
        position: CGPoint = .zero,
        rotation: Angle = .zero
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.size = type.defaultSize
    }
}

extension Furniture {
    func toDragData() -> FurnitureDragData {
        FurnitureDragData(
            furnitureId: id,
            name: type.rawValue,
            width: size.width,
            height: size.height,
            category: type.category.rawValue
        )
    }
}

enum FurnitureType: String, Codable, CaseIterable {
    case chair
    case table
    case bed
    case sofa
    case desk
    case cabinet
    
    var defaultSize: CGSize {
        switch self {
        case .chair: return CGSize(width: 50, height: 50)
        case .table: return CGSize(width: 100, height: 60)
        case .bed: return CGSize(width: 80, height: 120)
        case .sofa: return CGSize(width: 120, height: 60)
        case .desk: return CGSize(width: 100, height: 50)
        case .cabinet: return CGSize(width: 60, height: 40)
        }
    }
    
    var category: FurnitureCategory {
        switch self {
        case .chair, .sofa: return .seating
        case .table, .desk: return .tables
        case .bed: return .bedroom
        case .cabinet: return .storage
        }
    }
    
    var icon: String {
        switch self {
        case .chair: return "chair.fill"
        case .table: return "table.furniture.fill"
        case .bed: return "bed.double.fill"
        case .sofa: return "sofa.fill"
        case .desk: return "desk.fill"
        case .cabinet: return "cabinet.fill"
        }
    }
}

enum FurnitureCategory: String, CaseIterable {
    case seating = "Seating"
    case tables = "Tables"
    case bedroom = "Bedroom"
    case storage = "Storage"
}
