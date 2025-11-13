import Foundation
import CoreGraphics

/// Represents a complete floor plan with walls and metadata
class FloorPlan: ObservableObject, Codable {
    @Published var walls: [Wall] = []
    @Published var name: String
    @Published var scale: CGFloat // pixels per inch
    @Published var unit: MeasurementUnit

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
        case walls, name, scale, unit
    }

    init(name: String = "Untitled Floor Plan",
         scale: CGFloat = 4.0, // 4 pixels per inch by default
         unit: MeasurementUnit = .imperial) {
        self.name = name
        self.scale = scale
        self.unit = unit
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        walls = try container.decode([Wall].self, forKey: .walls)
        name = try container.decode(String.self, forKey: .name)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        unit = try container.decode(MeasurementUnit.self, forKey: .unit)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(walls, forKey: .walls)
        try container.encode(name, forKey: .name)
        try container.encode(scale, forKey: .scale)
        try container.encode(unit, forKey: .unit)
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
