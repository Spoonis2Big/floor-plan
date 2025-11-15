import Foundation

enum FurnitureCategory: String, CaseIterable {
    case livingRoom = "Living Room"
    case bedroom = "Bedroom"
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case office = "Office"
    case dining = "Dining"
}

struct Furniture: Identifiable {
    let id = UUID()
    var name: String
    var category: FurnitureCategory
    var width: Double  // in feet
    var depth: Double  // in feet
    var height: Double // in feet
    var imageName: String? // Asset catalog reference
    var position: CGPoint = .zero
    var rotation: Double = 0 // in degrees
    
    // Common furniture presets
    static let presets: [Furniture] = [
        // Living Room
        Furniture(name: "Sofa", category: .livingRoom, width: 7, depth: 3, height: 2.5, imageName: "sofa"),
        Furniture(name: "Armchair", category: .livingRoom, width: 3, depth: 3, height: 3, imageName: "armchair"),
        Furniture(name: "Coffee Table", category: .livingRoom, width: 4, depth: 2, height: 1.5, imageName: "coffee_table"),
        
        // Bedroom
        Furniture(name: "Queen Bed", category: .bedroom, width: 5, depth: 6.5, height: 2, imageName: "queen_bed"),
        Furniture(name: "Nightstand", category: .bedroom, width: 2, depth: 1.5, height: 2, imageName: "nightstand"),
        Furniture(name: "Dresser", category: .bedroom, width: 5, depth: 2, height: 3, imageName: "dresser"),
        
        // Kitchen
        Furniture(name: "Refrigerator", category: .kitchen, width: 3, depth: 2.5, height: 5.5, imageName: "refrigerator"),
        Furniture(name: "Stove", category: .kitchen, width: 2.5, depth: 2.5, height: 3, imageName: "stove"),
        
        // Dining
        Furniture(name: "Dining Table", category: .dining, width: 6, depth: 3, height: 2.5, imageName: "dining_table"),
        Furniture(name: "Dining Chair", category: .dining, width: 1.5, depth: 1.5, height: 3, imageName: "dining_chair"),
    ]
}
