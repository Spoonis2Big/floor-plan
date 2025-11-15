import Foundation
import SwiftUI

enum RoomType: String, Codable, CaseIterable {
    case bedroom
    case bathroom
    case kitchen
    case livingRoom
    case diningRoom
    case office
    case hallway
    case closet
    case garage
    case other
    
    var displayName: String {
        switch self {
        case .bedroom: return "Bedroom"
        case .bathroom: return "Bathroom"
        case .kitchen: return "Kitchen"
        case .livingRoom: return "Living Room"
        case .diningRoom: return "Dining Room"
        case .office: return "Office"
        case .hallway: return "Hallway"
        case .closet: return "Closet"
        case .garage: return "Garage"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .livingRoom: return "sofa.fill"
        case .bedroom: return "bed.double.fill"
        case .kitchen: return "refrigerator.fill"
        case .bathroom: return "bathtub.fill"
        case .diningRoom: return "fork.knife"
        case .office: return "desktopcomputer"
        case .hallway: return "arrow.left.and.right"
        case .closet: return "cabinet.fill"
        case .garage: return "car.fill"
        case .other: return "square.dashed"
        }
    }
}

/// Represents a room defined by connected walls
struct Room: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: RoomType
    var walls: [UUID] // References to Wall IDs
    var area: Double
    var color: String
    
    init(id: UUID = UUID(),
         name: String,
         type: RoomType = .other,
         walls: [UUID] = [],
         area: Double = 0,
         color: String = "#FFFFFF") {
        self.id = id
        self.name = name
        self.type = type
        self.walls = walls
        self.area = area
        self.color = color
    }
    
    static func empty(name: String = "New Room") -> Room {
        Room(name: name)
    }
}
