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

    /// Check if a point is near the start endpoint (within hitRadius)
    func isNearStartPoint(_ point: CGPoint, hitRadius: CGFloat = 20) -> Bool {
        return startPoint.distance(to: point) <= hitRadius
    }

    /// Check if a point is near the end endpoint (within hitRadius)
    func isNearEndPoint(_ point: CGPoint, hitRadius: CGFloat = 20) -> Bool {
        return endPoint.distance(to: point) <= hitRadius
    }

    /// Check if a point is on the wall line (within hitRadius)
    func isOnWall(_ point: CGPoint, hitRadius: CGFloat = 10) -> Bool {
        // Calculate distance from point to line segment
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let lengthSquared = dx * dx + dy * dy

        if lengthSquared == 0 {
            return startPoint.distance(to: point) <= hitRadius
        }

        let t = max(0, min(1, ((point.x - startPoint.x) * dx + (point.y - startPoint.y) * dy) / lengthSquared))
        let projection = CGPoint(
            x: startPoint.x + t * dx,
            y: startPoint.y + t * dy
        )

        return projection.distance(to: point) <= hitRadius
    }

    /// Move the wall by a given offset
    mutating func moveBy(dx: CGFloat, dy: CGFloat) {
        startPoint.x += dx
        startPoint.y += dy
        endPoint.x += dx
        endPoint.y += dy
    }
}
