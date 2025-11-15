import SwiftUI

struct GridBackgroundView: View {
    let gridSize: CGFloat
    let showGrid: Bool
    
    var body: some View {
        GeometryReader { geometry in
            if showGrid {
                Path { path in
                    // Vertical lines
                    for x in stride(from: 0, through: geometry.size.width, by: gridSize) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    
                    // Horizontal lines
                    for y in stride(from: 0, through: geometry.size.height, by: gridSize) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            }
        }
    }
}
