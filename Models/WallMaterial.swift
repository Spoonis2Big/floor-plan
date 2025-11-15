import Foundation
import SwiftUI

/// Represents a wall finish material (paint, wallpaper, tile, etc.)
struct WallMaterial: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: MaterialType
    var color: CodableColor
    var finish: Finish
    var pattern: Pattern?
    var customTexture: String? // Asset name or file path
    
    enum MaterialType: String, Codable, CaseIterable {
        case paint = "Paint"
        case wallpaper = "Wallpaper"
        case tile = "Tile"
        case woodPaneling = "Wood Paneling"
        case brick = "Brick"
        case stone = "Stone"
        case fabric = "Fabric"
        case metal = "Metal"
        
        var icon: String {
            switch self {
            case .paint: return "paintbrush.fill"
            case .wallpaper: return "square.fill.on.square.fill"
            case .tile: return "square.grid.3x3.fill"
            case .woodPaneling: return "rectangle.split.3x1.fill"
            case .brick: return "building.2.fill"
            case .stone: return "mountain.2.fill"
            case .fabric: return "tshirt.fill"
            case .metal: return "sparkles"
            }
        }
    }
    
    enum Finish: String, Codable, CaseIterable {
        case matte = "Matte"
        case eggshell = "Eggshell"
        case satin = "Satin"
        case semiGloss = "Semi-Gloss"
        case gloss = "Gloss"
        case metallic = "Metallic"
    }
    
    enum Pattern: String, Codable, CaseIterable {
        case solid = "Solid"
        case stripes = "Stripes"
        case dots = "Dots"
        case geometric = "Geometric"
        case floral = "Floral"
        case textured = "Textured"
    }
    
    init(id: UUID = UUID(),
         name: String,
         type: MaterialType,
         color: Color,
         finish: Finish = .matte,
         pattern: Pattern? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.color = CodableColor(color: color)
        self.finish = finish
        self.pattern = pattern
    }
}

/// Wrapper to make SwiftUI Color Codable
struct CodableColor: Codable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    init(color: Color) {
        // Extract RGBA components
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }
}
