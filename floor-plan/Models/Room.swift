import SwiftUI

struct Room: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: RoomType
    var walls: [Wall]
    var color: CodableColor
    var furniture: [Furniture]
    
    init(
        id: UUID = UUID(),
        name: String = "New Room",
        type: RoomType = .living,
        walls: [Wall] = [],
        color: CodableColor = CodableColor(color: .gray.opacity(0.2)),
        furniture: [Furniture] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.walls = walls
        self.color = color
        self.furniture = furniture
    }
    
    var bounds: CGRect {
        guard !walls.isEmpty else { return .zero }
        
        let points = walls.flatMap { [$0.start, $0.end] }
        let minX = points.map { $0.x }.min() ?? 0
        let maxX = points.map { $0.x }.max() ?? 0
        let minY = points.map { $0.y }.min() ?? 0
        let maxY = points.map { $0.y }.max() ?? 0
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    var area: Double {
        let rect = bounds
        return rect.width * rect.height
    }
}

struct Wall: Identifiable, Codable {
    let id: UUID
    var start: CGPoint
    var end: CGPoint
    var thickness: CGFloat
    var isDoor: Bool
    var isWindow: Bool
    
    init(
        id: UUID = UUID(),
        start: CGPoint,
        end: CGPoint,
        thickness: CGFloat = 10,
        isDoor: Bool = false,
        isWindow: Bool = false
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.thickness = thickness
        self.isDoor = isDoor
        self.isWindow = isWindow
    }
    
    var length: CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        return sqrt(dx * dx + dy * dy)
    }
}

enum RoomType: String, Codable, CaseIterable {
    case living = "Living Room"
    case bedroom = "Bedroom"
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case dining = "Dining Room"
    case office = "Office"
    case hallway = "Hallway"
    case other = "Other"
    
    var defaultColor: Color {
        switch self {
        case .living: return .blue.opacity(0.2)
        case .bedroom: return .purple.opacity(0.2)
        case .kitchen: return .green.opacity(0.2)
        case .bathroom: return .cyan.opacity(0.2)
        case .dining: return .orange.opacity(0.2)
        case .office: return .yellow.opacity(0.2)
        case .hallway: return .gray.opacity(0.1)
        case .other: return .gray.opacity(0.2)
        }
    }
}

// Helper for encoding/decoding Color
struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(color: Color) {
        let nsColor = NSColor(color)
        self.red = Double(nsColor.redComponent)
        self.green = Double(nsColor.greenComponent)
        self.blue = Double(nsColor.blueComponent)
        self.alpha = Double(nsColor.alphaComponent)
    }
    
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
