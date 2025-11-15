import Foundation
import SwiftUI

struct DoorStyle: Codable, Hashable {
    var type: DoorType
    var material: DoorMaterial
    var color: CodableColor
    var handleType: HandleType
    var swingDirection: SwingDirection
    
    enum DoorType: String, Codable, CaseIterable {
        case single = "Single"
        case double = "Double"
        case sliding = "Sliding"
        case pocket = "Pocket"
        case french = "French"
        case bifold = "Bifold"
        
        var icon: String {
            switch self {
            case .single, .double: return "door.left.hand.open"
            case .sliding, .pocket: return "arrow.left.and.right"
            case .french: return "door.french.open"
            case .bifold: return "arrow.up.left.and.arrow.down.right"
            }
        }
    }
    
    enum DoorMaterial: String, Codable, CaseIterable {
        case wood = "Wood"
        case glass = "Glass"
        case metal = "Metal"
        case composite = "Composite"
    }
    
    enum HandleType: String, Codable, CaseIterable {
        case knob = "Knob"
        case lever = "Lever"
        case pull = "Pull"
        case none = "None"
    }
    
    enum SwingDirection: String, Codable, CaseIterable {
        case inward = "Inward"
        case outward = "Outward"
        case none = "None" // For sliding doors
    }
}

struct WindowTreatment: Codable, Hashable {
    var type: WindowType
    var color: CodableColor
    var pattern: Pattern
    
    enum WindowType: String, Codable, CaseIterable {
        case curtains = "Curtains"
        case blinds = "Blinds"
        case shades = "Shades"
        case shutters = "Shutters"
        case valance = "Valance"
        case none = "None"
        
        var icon: String {
            switch self {
            case .curtains: return "rectangle.portrait.fill"
            case .blinds: return "rectangle.split.3x1"
            case .shades: return "rectangle.fill"
            case .shutters: return "rectangle.split.2x1"
            case .valance: return "rectangle.topthird.inset.filled"
            case .none: return "xmark"
            }
        }
    }
    
    enum Pattern: String, Codable, CaseIterable {
        case solid = "Solid"
        case striped = "Striped"
        case patterned = "Patterned"
        case sheer = "Sheer"
    }
}
