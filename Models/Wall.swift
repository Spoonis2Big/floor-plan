import Foundation
import CoreGraphics

enum WallType: String, Codable {
    case exterior
    case interior
    case partition
}

enum WindowTreatment: String, Codable {
    case none
    case curtains
    case blinds
    case shutters
    case shades
}

enum WallMaterial: String, Codable {
    case drywall
    case brick
    case concrete
    case wood
    case glass
    case metal
}

enum DoorStyle: String, Codable {
    case standard
    case sliding
    case bifold
    case french
    case pocket
    case barn
}

struct CodablePoint: Codable {
    var x: Double
    var y: Double
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    init(from point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
}

/// Represents a wall in the floor plan
struct Wall: Identifiable, Codable {
    let id: UUID
    var startPoint: CGPoint
    var endPoint: CGPoint
    var thickness: CGFloat // in real-world units (e.g., inches)
    var height: CGFloat // wall height in real-world units
    var type: WallType
    var material: WallMaterial
    var color: String
    
    // 🆕 Interior Design Properties
    var leftSideMaterial: WallMaterial?  // Material facing left when looking from start to end
    var rightSideMaterial: WallMaterial? // Material facing right
    var hasDoor: Bool = false
    var doorPosition: CGFloat? // 0.0 to 1.0 along wall length
    var doorWidth: CGFloat? // in real-world units
    var doorStyle: DoorStyle?
    var hasWindow: Bool = false
    var windowPosition: CGFloat? // 0.0 to 1.0 along wall length
    var windowWidth: CGFloat? // in real-world units
    var windowHeight: CGFloat? // in real-world units
    var windowSillHeight: CGFloat? // height from floor
    var windowTreatment: WindowTreatment

    enum CodingKeys: String, CodingKey {
        case id, startPoint, endPoint, thickness, height, type, material, color
        case leftSideMaterial, rightSideMaterial, hasDoor, doorPosition, doorWidth, doorStyle
        case hasWindow, windowPosition, windowWidth, windowHeight, windowSillHeight, windowTreatment
    }

    init(id: UUID = UUID(),
         startPoint: CGPoint,
         endPoint: CGPoint,
         thickness: CGFloat = 6.0, // default 6 inches
         height: CGFloat = 96.0, // default 8 feet
         type: WallType = .interior,
         material: WallMaterial = .drywall,
         color: String = "#FFFFFF",
         windowTreatment: WindowTreatment = .none) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.thickness = thickness
        self.height = height
        self.type = type
        self.material = material
        self.color = color
        self.windowTreatment = windowTreatment
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        
        let start = try container.decode(CodablePoint.self, forKey: .startPoint)
        startPoint = start.cgPoint
        
        let end = try container.decode(CodablePoint.self, forKey: .endPoint)
        endPoint = end.cgPoint
        
        thickness = try container.decode(CGFloat.self, forKey: .thickness)
        height = try container.decode(CGFloat.self, forKey: .height)
        type = try container.decode(WallType.self, forKey: .type)
        material = try container.decode(WallMaterial.self, forKey: .material)
        color = try container.decode(String.self, forKey: .color)
        
        leftSideMaterial = try container.decodeIfPresent(WallMaterial.self, forKey: .leftSideMaterial)
        rightSideMaterial = try container.decodeIfPresent(WallMaterial.self, forKey: .rightSideMaterial)
        hasDoor = try container.decodeIfPresent(Bool.self, forKey: .hasDoor) ?? false
        doorPosition = try container.decodeIfPresent(CGFloat.self, forKey: .doorPosition)
        doorWidth = try container.decodeIfPresent(CGFloat.self, forKey: .doorWidth)
        doorStyle = try container.decodeIfPresent(DoorStyle.self, forKey: .doorStyle)
        hasWindow = try container.decodeIfPresent(Bool.self, forKey: .hasWindow) ?? false
        windowPosition = try container.decodeIfPresent(CGFloat.self, forKey: .windowPosition)
        windowWidth = try container.decodeIfPresent(CGFloat.self, forKey: .windowWidth)
        windowHeight = try container.decodeIfPresent(CGFloat.self, forKey: .windowHeight)
        windowSillHeight = try container.decodeIfPresent(CGFloat.self, forKey: .windowSillHeight)
        windowTreatment = try container.decode(WindowTreatment.self, forKey: .windowTreatment)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(CodablePoint(from: startPoint), forKey: .startPoint)
        try container.encode(CodablePoint(from: endPoint), forKey: .endPoint)
        try container.encode(thickness, forKey: .thickness)
        try container.encode(height, forKey: .height)
        try container.encode(type, forKey: .type)
        try container.encode(material, forKey: .material)
        try container.encode(color, forKey: .color)
        try container.encodeIfPresent(leftSideMaterial, forKey: .leftSideMaterial)
        try container.encodeIfPresent(rightSideMaterial, forKey: .rightSideMaterial)
        try container.encode(hasDoor, forKey: .hasDoor)
        try container.encodeIfPresent(doorPosition, forKey: .doorPosition)
        try container.encodeIfPresent(doorWidth, forKey: .doorWidth)
        try container.encodeIfPresent(doorStyle, forKey: .doorStyle)
        try container.encode(hasWindow, forKey: .hasWindow)
        try container.encodeIfPresent(windowPosition, forKey: .windowPosition)
        try container.encodeIfPresent(windowWidth, forKey: .windowWidth)
        try container.encodeIfPresent(windowHeight, forKey: .windowHeight)
        try container.encodeIfPresent(windowSillHeight, forKey: .windowSillHeight)
        try container.encode(windowTreatment, forKey: .windowTreatment)
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
    
    /// Get the normal vector pointing to the left side (perpendicular to wall direction)
    var leftNormal: CGVector {
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let length = sqrt(dx * dx + dy * dy)
        return CGVector(dx: -dy / length, dy: dx / length)
    }
    
    /// Get the normal vector pointing to the right side
    var rightNormal: CGVector {
        let left = leftNormal
        return CGVector(dx: -left.dx, dy: -left.dy)
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
