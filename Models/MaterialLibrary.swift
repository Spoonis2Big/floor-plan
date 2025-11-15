import Foundation
import SwiftUI

/// Centralized library of materials and presets
struct MaterialLibrary: Codable {
    var wallMaterials: [WallMaterial] = []
    var floorMaterials: [FloorMaterial] = []
    
    init() {
        loadDefaultMaterials()
    }
    
    mutating func loadDefaultMaterials() {
        // Default Wall Materials
        wallMaterials = [
            WallMaterial(name: "White Matte", type: .paint, color: .white, finish: .matte),
            WallMaterial(name: "Warm Beige", type: .paint, color: Color(red: 0.96, green: 0.92, blue: 0.84), finish: .eggshell),
            WallMaterial(name: "Light Gray", type: .paint, color: Color(red: 0.85, green: 0.85, blue: 0.85), finish: .satin),
            WallMaterial(name: "Navy Blue", type: .paint, color: Color(red: 0.0, green: 0.2, blue: 0.4), finish: .matte),
            WallMaterial(name: "Sage Green", type: .paint, color: Color(red: 0.7, green: 0.8, blue: 0.7), finish: .eggshell),
            WallMaterial(name: "White Subway Tile", type: .tile, color: .white, finish: .gloss),
            WallMaterial(name: "Exposed Brick", type: .brick, color: Color(red: 0.7, green: 0.4, blue: 0.3), finish: .matte),
            WallMaterial(name: "Light Oak Paneling", type: .woodPaneling, color: Color(red: 0.82, green: 0.71, blue: 0.55), finish: .satin)
        ]
        
        // Default Floor Materials
        floorMaterials = [
            FloorMaterial(name: "Light Oak Hardwood", type: .hardwood, color: Color(red: 0.82, green: 0.71, blue: 0.55), pattern: .wood),
            FloorMaterial(name: "Dark Walnut", type: .hardwood, color: Color(red: 0.4, green: 0.3, blue: 0.2), pattern: .wood),
            FloorMaterial(name: "Gray Laminate", type: .laminate, color: Color(red: 0.6, green: 0.6, blue: 0.6), pattern: .wood),
            FloorMaterial(name: "White Marble Tile", type: .tile, color: .white, pattern: .tiles),
            FloorMaterial(name: "Beige Carpet", type: .carpet, color: Color(red: 0.9, green: 0.85, blue: 0.75), pattern: .solid),
            FloorMaterial(name: "Gray Concrete", type: .concrete, color: Color(red: 0.5, green: 0.5, blue: 0.5), pattern: .solid),
            FloorMaterial(name: "Natural Bamboo", type: .bamboo, color: Color(red: 0.85, green: 0.75, blue: 0.55), pattern: .wood)
        ]
    }
    
    mutating func addWallMaterial(_ material: WallMaterial) {
        wallMaterials.append(material)
    }
    
    mutating func addFloorMaterial(_ material: FloorMaterial) {
        floorMaterials.append(material)
    }
    
    mutating func removeWallMaterial(_ material: WallMaterial) {
        wallMaterials.removeAll { $0.id == material.id }
    }
    
    mutating func removeFloorMaterial(_ material: FloorMaterial) {
        floorMaterials.removeAll { $0.id == material.id }
    }
}
