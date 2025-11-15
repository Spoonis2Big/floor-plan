import Foundation
import SwiftUI

/// Represents flooring material
struct FloorMaterial: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: FloorType
    var color: CodableColor
    var pattern: Pattern
    var direction: Direction // For planks/tiles
    
    enum FloorType: String, Codable, CaseIterable {
        case hardwood = "Hardwood"
        case laminate = "Laminate"
        case tile = "Tile"
        case carpet = "Carpet"
        case vinyl = "Vinyl"
        case concrete = "Concrete"
        case stone = "Stone"
        case bamboo = "Bamboo"
        
        var icon: String {
            switch self {
            case .hardwood, .laminate, .bamboo: return "rectangle.split.3x1"
            case .tile, .stone: return "square.grid.3x3"
            case .carpet: return "circle.grid.cross.fill"
            case .vinyl: return "square.on.square"
            case .concrete: return "square.fill"
            }
        }
    }
    
    enum Pattern: String, Codable, CaseIterable {
        case solid = "Solid"
        case wood = "Wood Grain"
        case tiles = "Tiles"
        case herringbone = "Herringbone"
        case chevron = "Chevron"
        case basketWeave = "Basket Weave"
    }
    
    enum Direction: String, Codable, CaseIterable {
        case horizontal = "Horizontal"
        case vertical = "Vertical"
        case diagonal = "Diagonal"
    }
    
    init(id: UUID = UUID(),
         name: String,
         type: FloorType,
         color: Color,
         pattern: Pattern = .solid,
         direction: Direction = .horizontal) {
        self.id = id
        self.name = name
        self.type = type
        self.color = CodableColor(color: color)
        self.pattern = pattern
        self.direction = direction
    }
}
