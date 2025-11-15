import SwiftUI

enum MaterialType {
    case wall
    case floor
    case ceiling
}

enum MaterialFinish: String, CaseIterable {
    case matte = "Matte"
    case glossy = "Glossy"
    case satin = "Satin"
}

struct Material: Identifiable {
    let id = UUID()
    let type: MaterialType
    var name: String
    var color: Color
    var finish: MaterialFinish
    var texture: String? // Optional texture/pattern name
    
    static func defaultMaterial(for type: MaterialType) -> Material {
        switch type {
        case .wall:
            return Material(type: .wall, name: "White Wall", color: .white, finish: .matte, texture: nil)
        case .floor:
            return Material(type: .floor, name: "Wood Floor", color: Color(red: 0.65, green: 0.5, blue: 0.39), finish: .satin, texture: "wood")
        case .ceiling:
            return Material(type: .ceiling, name: "White Ceiling", color: .white, finish: .matte, texture: nil)
        }
    }
}
