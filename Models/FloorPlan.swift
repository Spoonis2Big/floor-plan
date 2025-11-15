import Foundation
import CoreGraphics

/// Represents a complete floor plan with walls and metadata
class FloorPlan: ObservableObject, Codable, Identifiable {
    let id = UUID()
    @Published var walls: [Wall] = []
    @Published var name: String
    @Published var scale: CGFloat // pixels per inch
    @Published var unit: MeasurementUnit
    @Published var gridSize: Double = 1.0 // in feet
    @Published var showGrid: Bool = true
    
    // Interior Design Collections
    @Published var rooms: [Room] = []
    @Published var furnitureItems: [FurnitureItem] = []
    @Published var materialLibrary: MaterialLibrary = MaterialLibrary()

    enum MeasurementUnit: String, Codable, CaseIterable {
        case imperial = "Imperial (ft/in)"
        case metric = "Metric (m/cm)"

        var displayUnit: String {
            switch self {
            case .imperial: return "ft"
            case .metric: return "m"
            }
        }

        var smallDisplayUnit: String {
            switch self {
            case .imperial: return "in"
            case .metric: return "cm"
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, walls, name, scale, unit, gridSize, showGrid, rooms, furnitureItems, materialLibrary
    }

    init(name: String = "Untitled Floor Plan",
         scale: CGFloat = 4.0, // 4 pixels per inch by default
         unit: MeasurementUnit = .imperial) {
        self.name = name
        self.scale = scale
        self.unit = unit
    }
    
    static func empty() -> FloorPlan {
        FloorPlan(name: "Untitled Floor Plan")
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        walls = try container.decode([Wall].self, forKey: .walls)
        name = try container.decode(String.self, forKey: .name)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        unit = try container.decode(MeasurementUnit.self, forKey: .unit)
        gridSize = try container.decodeIfPresent(Double.self, forKey: .gridSize) ?? 1.0
        showGrid = try container.decodeIfPresent(Bool.self, forKey: .showGrid) ?? true
        rooms = try container.decodeIfPresent([Room].self, forKey: .rooms) ?? []
        furnitureItems = try container.decodeIfPresent([FurnitureItem].self, forKey: .furnitureItems) ?? []
        materialLibrary = try container.decodeIfPresent(MaterialLibrary.self, forKey: .materialLibrary) ?? MaterialLibrary()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(walls, forKey: .walls)
        try container.encode(name, forKey: .name)
        try container.encode(scale, forKey: .scale)
        try container.encode(unit, forKey: .unit)
        try container.encode(gridSize, forKey: .gridSize)
        try container.encode(showGrid, forKey: .showGrid)
        try container.encode(rooms, forKey: .rooms)
        try container.encode(furnitureItems, forKey: .furnitureItems)
        try container.encode(materialLibrary, forKey: .materialLibrary)
    }

    func addWall(_ wall: Wall) {
        walls.append(wall)
    }

    func removeWall(_ wall: Wall) {
        walls.removeAll { $0.id == wall.id }
    }

    func updateWall(_ wall: Wall) {
        if let index = walls.firstIndex(where: { $0.id == wall.id }) {
            walls[index] = wall
        }
    }

    func clearAll() {
        walls.removeAll()
    }
    
    // Room Management
    func addRoom(_ room: Room) {
        rooms.append(room)
    }
    
    func removeRoom(_ room: Room) {
        rooms.removeAll { $0.id == room.id }
    }
    
    func updateRoom(_ room: Room) {
        if let index = rooms.firstIndex(where: { $0.id == room.id }) {
            rooms[index] = room
        }
    }
    
    // Furniture Management
    func addFurniture(_ item: FurnitureItem) {
        furnitureItems.append(item)
    }
    
    func removeFurniture(_ item: FurnitureItem) {
        furnitureItems.removeAll { $0.id == item.id }
    }
    
    func updateFurniture(_ item: FurnitureItem) {
        if let index = furnitureItems.firstIndex(where: { $0.id == item.id }) {
            furnitureItems[index] = item
        }
    }

    /// Convert screen coordinates to real-world measurements
    func toRealWorld(_ screenDistance: CGFloat) -> CGFloat {
        return screenDistance / scale
    }

    /// Convert real-world measurements to screen coordinates
    func toScreen(_ realWorldDistance: CGFloat) -> CGFloat {
        return realWorldDistance * scale
    }

    /// Format a measurement for display
    func formatMeasurement(_ inches: CGFloat) -> String {
        switch unit {
        case .imperial:
            let feet = Int(inches / 12)
            let remainingInches = inches.truncatingRemainder(dividingBy: 12)
            if feet > 0 {
                return String(format: "%d' %.1f\"", feet, remainingInches)
            } else {
                return String(format: "%.1f\"", remainingInches)
            }
        case .metric:
            let cm = inches * 2.54
            let meters = cm / 100
            if meters >= 1.0 {
                return String(format: "%.2f m", meters)
            } else {
                return String(format: "%.1f cm", cm)
            }
        }
    }
}
