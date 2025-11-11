import SwiftUI

/// Displays elevation views (North, South, East, West) of the floor plan
struct ElevationView: View {
    @ObservedObject var floorPlan: FloorPlan
    let direction: ElevationDirection

    enum ElevationDirection: String, CaseIterable {
        case north = "North"
        case south = "South"
        case east = "East"
        case west = "West"

        var angle: CGFloat {
            switch self {
            case .north: return 0
            case .south: return .pi
            case .east: return .pi / 2
            case .west: return -.pi / 2
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(direction.rawValue) Elevation")
                .font(.headline)

            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Background
                    Rectangle()
                        .fill(Color.white)
                        .border(Color.gray, width: 1)

                    // Ground line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    }
                    .stroke(Color.brown, lineWidth: 2)

                    // Walls visible from this direction
                    ForEach(visibleWalls) { wall in
                        ElevationWallView(
                            wall: wall,
                            floorPlan: floorPlan,
                            canvasHeight: geometry.size.height,
                            canvasWidth: geometry.size.width
                        )
                    }
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
        }
        .padding()
    }

    /// Filter walls that are visible from this elevation direction
    private var visibleWalls: [Wall] {
        let tolerance: CGFloat = 0.1 // Angular tolerance in radians

        return floorPlan.walls.filter { wall in
            let wallAngle = wall.angle

            // Normalize angles to 0...2π
            let normalizedWallAngle = (wallAngle + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)
            let normalizedViewAngle = (direction.angle + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)

            // Check if wall is perpendicular to view direction (±90°)
            let angleDiff1 = abs(normalizedWallAngle - normalizedViewAngle)
            let angleDiff2 = abs(angleDiff1 - 2 * .pi)
            let minAngleDiff = min(angleDiff1, angleDiff2)

            return abs(minAngleDiff - .pi / 2) < tolerance ||
                   abs(minAngleDiff - 3 * .pi / 2) < tolerance
        }
    }
}

/// Renders a single wall in elevation view
struct ElevationWallView: View {
    let wall: Wall
    let floorPlan: FloorPlan
    let canvasHeight: CGFloat
    let canvasWidth: CGFloat

    var body: some View {
        let position = calculatePosition()
        let width = wall.length * floorPlan.scale
        let height = wall.height * floorPlan.scale

        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .border(Color.black, width: 2)
            .frame(width: width, height: height)
            .position(x: position.x, y: canvasHeight - height / 2)
    }

    private func calculatePosition() -> CGPoint {
        // Project wall position onto elevation plane
        // For simplicity, use the midpoint of the wall
        let midX = (wall.startPoint.x + wall.endPoint.x) / 2
        let midY = (wall.startPoint.y + wall.endPoint.y) / 2

        // Map to canvas coordinates (this is a simplified projection)
        return CGPoint(
            x: midX.truncatingRemainder(dividingBy: canvasWidth),
            y: 0
        )
    }
}

/// View showing all four elevations in a grid
struct AllElevationsView: View {
    @ObservedObject var floorPlan: FloorPlan

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Elevation Views")
                    .font(.title)
                    .padding(.top)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(ElevationView.ElevationDirection.allCases, id: \.self) { direction in
                        ElevationView(floorPlan: floorPlan, direction: direction)
                            .frame(minHeight: 200)
                    }
                }
                .padding()
            }
        }
    }
}
