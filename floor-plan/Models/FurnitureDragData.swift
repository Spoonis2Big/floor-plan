import Foundation
import UniformTypeIdentifiers

struct FurnitureDragData: Codable {
    let furnitureId: UUID
    let name: String
    let width: Double
    let height: Double
    let category: String
    
    static let utType = UTType(exportedAs: "com.floorplan.furniture")
}
