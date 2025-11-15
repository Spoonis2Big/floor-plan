import Foundation
import CoreGraphics

struct GridSettings {
    var gridSize: CGFloat = 20.0
    var showGrid: Bool = true
    var snapToGrid: Bool = true
    
    func snapPoint(_ point: CGPoint) -> CGPoint {
        guard snapToGrid else { return point }
        
        return CGPoint(
            x: round(point.x / gridSize) * gridSize,
            y: round(point.y / gridSize) * gridSize
        )
    }
    
    func snapSize(_ size: CGSize) -> CGSize {
        guard snapToGrid else { return size }
        
        return CGSize(
            width: round(size.width / gridSize) * gridSize,
            height: round(size.height / gridSize) * gridSize
        )
    }
}
