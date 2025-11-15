import SwiftUI
import Combine

class MaterialPickerViewModel: ObservableObject {
    @Published var selectedType: MaterialType = .wall
    @Published var currentMaterial: Material
    @Published var customMaterials: [Material] = []
    @Published var recentMaterials: [Material] = []
    
    // Predefined material presets
    let presetMaterials: [MaterialType: [Material]] = [
        .wall: [
            Material(type: .wall, name: "White", color: .white, finish: .matte, texture: nil),
            Material(type: .wall, name: "Beige", color: Color(red: 0.96, green: 0.96, blue: 0.86), finish: .matte, texture: nil),
            Material(type: .wall, name: "Light Gray", color: Color(red: 0.83, green: 0.83, blue: 0.83), finish: .matte, texture: nil),
            Material(type: .wall, name: "Brick", color: Color(red: 0.7, green: 0.3, blue: 0.2), finish: .matte, texture: "brick"),
        ],
        .floor: [
            Material(type: .floor, name: "Oak Wood", color: Color(red: 0.65, green: 0.5, blue: 0.39), finish: .satin, texture: "wood"),
            Material(type: .floor, name: "Dark Wood", color: Color(red: 0.3, green: 0.2, blue: 0.1), finish: .glossy, texture: "wood"),
            Material(type: .floor, name: "White Tile", color: .white, finish: .glossy, texture: "tile"),
            Material(type: .floor, name: "Gray Carpet", color: Color(red: 0.5, green: 0.5, blue: 0.5), finish: .matte, texture: "carpet"),
        ],
        .ceiling: [
            Material(type: .ceiling, name: "White", color: .white, finish: .matte, texture: nil),
            Material(type: .ceiling, name: "Off-White", color: Color(red: 0.98, green: 0.98, blue: 0.95), finish: .matte, texture: nil),
            Material(type: .ceiling, name: "Popcorn", color: .white, finish: .matte, texture: "popcorn"),
        ]
    ]
    
    init() {
        self.currentMaterial = Material.defaultMaterial(for: .wall)
    }
    
    func selectMaterial(_ material: Material) {
        currentMaterial = material
        addToRecent(material)
    }
    
    func updateColor(_ color: Color) {
        currentMaterial.color = color
    }
    
    func updateFinish(_ finish: MaterialFinish) {
        currentMaterial.finish = finish
    }
    
    func updateTexture(_ texture: String?) {
        currentMaterial.texture = texture
    }
    
    func saveCustomMaterial() {
        customMaterials.append(currentMaterial)
    }
    
    private func addToRecent(_ material: Material) {
        // Remove if already exists
        recentMaterials.removeAll { $0.id == material.id }
        // Add to front
        recentMaterials.insert(material, at: 0)
        // Keep only last 10
        if recentMaterials.count > 10 {
            recentMaterials = Array(recentMaterials.prefix(10))
        }
    }
    
    func getMaterialsForCurrentType() -> [Material] {
        presetMaterials[selectedType] ?? []
    }
}
