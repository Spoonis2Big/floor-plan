import Foundation
import CoreGraphics

struct FurnitureItem: Identifiable, Codable, Equatable {
    let id: UUID
    let furnitureId: UUID
    var name: String
    var position: CGPoint
    var rotation: Double // in degrees
    var width: Double
    var height: Double
    
    init(id: UUID = UUID(), furnitureId: UUID, name: String, position: CGPoint, rotation: Double = 0, width: Double, height: Double) {
        self.id = id
        self.furnitureId = furnitureId
        self.name = name
        self.position = position
        self.rotation = rotation
        self.width = width
        self.height = height
    }
    
    var bounds: CGRect {
        CGRect(
            x: position.x - width / 2,
            y: position.y - height / 2,
            width: width,
            height: height
        )
    }
    
    static func == (lhs: FurnitureItem, rhs: FurnitureItem) -> Bool {
        lhs.id == rhs.id
    }
}
