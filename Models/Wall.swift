import Foundation
import CoreGraphics

/// Represents a wall in the floor plan
struct Wall: Identifiable, Codable {
    let id: UUID
    var startPoint: CGPoint
    var endPoint: CGPoint
    var thickness: CGFloat // in real-world units (e.g., inches)
    var height: CGFloat // wall height in real-world units

    init(id: UUID = UUID(),
         startPoint: CGPoint,
         endPoint: CGPoint,
         thickness: CGFloat = 6.0, // default 6 inches
         height: CGFloat = 96.0) { // default 8 feet
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.thickness = thickness
        self.height = height
    }

    /// Length of the wall in real-world units
    var length: CGFloat {
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Angle of the wall in radians
    var angle: CGFloat {
        atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
    }

    /// Center point of the wall
    var center: CGPoint {
        CGPoint(
            x: (startPoint.x + endPoint.x) / 2,
            y: (startPoint.y + endPoint.y) / 2
        )
    }
}
