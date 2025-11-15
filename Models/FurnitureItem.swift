import Foundation
import CoreGraphics
import SwiftUI

/// Represents a furniture item placed in the floor plan
struct FurnitureItem: Identifiable, Codable {
    let id: UUID
    var position: CGPoint // Center position in real-world coordinates
    var rotation: CGFloat // Rotation in radians
    var furnitureType: FurnitureType
    var style: FurnitureStyle
    var color: CodableColor
    var dimensions: Dimensions // Width, depth, height in real-world units
    var customName: String?
    
    struct Dimensions: Codable, Hashable {
        var width: CGFloat
        var depth: CGFloat
        var height: CGFloat
    }
    
    enum FurnitureType: String, Codable, CaseIterable {
        // Living Room
        case sofa = "Sofa"
        case armchair = "Armchair"
        case coffeeTable = "Coffee Table"
        case tvStand = "TV Stand"
        case bookshelf = "Bookshelf"
        
        // Bedroom
        case bed = "Bed"
        case nightstand = "Nightstand"
        case dresser = "Dresser"
        case wardrobe = "Wardrobe"
        
        // Dining
        case diningTable = "Dining Table"
        case diningChair = "Dining Chair"
        
        // Office
        case desk = "Desk"
        case officeChair = "Office Chair"
        case filingCabinet = "Filing Cabinet"
        
        // Kitchen
        case island = "Kitchen Island"
        case pantry = "Pantry"
        
        // Bathroom
        case vanity = "Vanity"
        case bathtub = "Bathtub"
        case shower = "Shower"
        case toilet = "Toilet"
        
        // Generic
        case cabinet = "Cabinet"
        case shelf = "Shelf"
        case bench = "Bench"
        case ottoman = "Ottoman"
        case plant = "Plant"
        case rug = "Rug"
        
        var icon: String {
            switch self {
            case .sofa: return "sofa.fill"
            case .armchair: return "chair.fill"
            case .coffeeTable, .diningTable: return "table.furniture.fill"
            case .tvStand: return "tv.fill"
            case .bookshelf, .shelf: return "books.vertical.fill"
            case .bed: return "bed.double.fill"
            case .nightstand, .dresser, .cabinet, .filingCabinet: return "cabinet.fill"
            case .wardrobe: return "cabinet.fill"
            case .diningChair, .officeChair: return "chair.fill"
            case .desk: return "desk.fill"
            case .island, .pantry: return "refrigerator.fill"
            case .vanity: return "sink.fill"
            case .bathtub: return "bathtub.fill"
            case .shower: return "shower.fill"
            case .toilet: return "toilet.fill"
            case .bench: return "bench.and.plant"
            case .ottoman: return "square.fill"
            case .plant: return "leaf.fill"
            case .rug: return "rectangle.fill"
            }
        }
        
        var defaultDimensions: Dimensions {
            switch self {
            case .sofa: return Dimensions(width: 84, depth: 36, height: 36)
            case .armchair: return Dimensions(width: 36, depth: 36, height: 36)
            case .coffeeTable: return Dimensions(width: 48, depth: 24, height: 18)
            case .tvStand: return Dimensions(width: 60, depth: 18, height: 24)
            case .bookshelf: return Dimensions(width: 36, depth: 12, height: 72)
            case .bed: return Dimensions(width: 60, depth: 80, height: 24) // Queen
            case .nightstand: return Dimensions(width: 24, depth: 18, height: 24)
            case .dresser: return Dimensions(width: 48, depth: 20, height: 36)
            case .wardrobe: return Dimensions(width: 48, depth: 24, height: 72)
            case .diningTable: return Dimensions(width: 60, depth: 36, height: 30)
            case .diningChair: return Dimensions(width: 18, depth: 20, height: 36)
            case .desk: return Dimensions(width: 60, depth: 30, height: 30)
            case .officeChair: return Dimensions(width: 24, depth: 24, height: 36)
            case .filingCabinet: return Dimensions(width: 15, depth: 28, height: 52)
            case .island: return Dimensions(width: 72, depth: 36, height: 36)
            case .pantry: return Dimensions(width: 24, depth: 24, height: 84)
            case .vanity: return Dimensions(width: 48, depth: 21, height: 32)
            case .bathtub: return Dimensions(width: 32, depth: 60, height: 20)
            case .shower: return Dimensions(width: 36, depth: 36, height: 72)
            case .toilet: return Dimensions(width: 20, depth: 28, height: 30)
            case .cabinet: return Dimensions(width: 36, depth: 18, height: 36)
            case .shelf: return Dimensions(width: 36, depth: 10, height: 12)
            case .bench: return Dimensions(width: 48, depth: 18, height: 18)
            case .ottoman: return Dimensions(width: 24, depth: 24, height: 18)
            case .plant: return Dimensions(width: 12, depth: 12, height: 36)
            case .rug: return Dimensions(width: 96, depth: 72, height: 0)
            }
        }
    }
    
    enum FurnitureStyle: String, Codable, CaseIterable {
        case modern = "Modern"
        case traditional = "Traditional"
        case minimalist = "Minimalist"
        case industrial = "Industrial"
        case scandinavian = "Scandinavian"
        case rustic = "Rustic"
        case contemporary = "Contemporary"
    }
    
    init(id: UUID = UUID(),
         position: CGPoint,
         rotation: CGFloat = 0,
         furnitureType: FurnitureType,
         style: FurnitureStyle = .modern,
         color: Color = .gray,
         dimensions: Dimensions? = nil) {
        self.id = id
        self.position = position
        self.rotation = rotation
        self.furnitureType = furnitureType
        self.style = style
        self.color = CodableColor(color: color)
        self.dimensions = dimensions ?? furnitureType.defaultDimensions
    }
    
    /// Bounding box corners in real-world coordinates
    var corners: [CGPoint] {
        let halfWidth = dimensions.width / 2
        let halfDepth = dimensions.depth / 2
        
        let localCorners = [
            CGPoint(x: -halfWidth, y: -halfDepth),
            CGPoint(x: halfWidth, y: -halfDepth),
            CGPoint(x: halfWidth, y: halfDepth),
            CGPoint(x: -halfWidth, y: halfDepth)
        ]
        
        return localCorners.map { corner in
            let rotatedX = corner.x * cos(rotation) - corner.y * sin(rotation)
            let rotatedY = corner.x * sin(rotation) + corner.y * cos(rotation)
            return CGPoint(x: position.x + rotatedX, y: position.y + rotatedY)
        }
    }
}
