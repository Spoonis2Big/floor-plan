import SwiftUI

/// Interactive canvas for drawing and viewing the floor plan
struct FloorPlanCanvasView: View {
    @ObservedObject var floorPlan: FloorPlan
    @State private var currentStartPoint: CGPoint?
    @State private var currentEndPoint: CGPoint?
    @State private var selectedWall: Wall?
    @State private var hoveredWall: Wall?
    @State private var offset: CGSize = .zero
    @State private var zoom: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                GridView(scale: floorPlan.scale * zoom, offset: offset)
                    .background(Color.white)

                // Existing walls
                ForEach(floorPlan.walls) { wall in
                    WallView(
                        wall: wall,
                        scale: floorPlan.scale * zoom,
                        isSelected: selectedWall?.id == wall.id,
                        isHovered: hoveredWall?.id == wall.id
                    )
                    .onTapGesture {
                        selectedWall = wall
                    }
                }

                // Current wall being drawn
                if let start = currentStartPoint, let end = currentEndPoint {
                    WallView(
                        wall: Wall(startPoint: start, endPoint: end),
                        scale: floorPlan.scale * zoom,
                        isSelected: false,
                        isHovered: false,
                        isTemporary: true
                    )

                    // Show measurement while drawing
                    MeasurementLabel(
                        wall: Wall(startPoint: start, endPoint: end),
                        floorPlan: floorPlan,
                        zoom: zoom
                    )
                }

                // Measurements for existing walls
                ForEach(floorPlan.walls) { wall in
                    if selectedWall?.id == wall.id || hoveredWall?.id == wall.id {
                        MeasurementLabel(wall: wall, floorPlan: floorPlan, zoom: zoom)
                    }
                }
            }
            .offset(offset)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDrag(value, in: geometry.size)
                    }
                    .onEnded { value in
                        handleDragEnd(value, in: geometry.size)
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        zoom = max(0.1, min(5.0, value))
                    }
            )
            .onHover { isHovering in
                if !isHovering {
                    hoveredWall = nil
                }
            }
        }
    }

    private func handleDrag(_ value: DragGesture.Value, in size: CGSize) {
        let location = value.location

        if currentStartPoint == nil {
            // Starting a new wall
            currentStartPoint = snapToGrid(location)
        } else {
            // Dragging to set end point
            currentEndPoint = snapToGrid(location)
        }
    }

    private func handleDragEnd(_ value: DragGesture.Value, in size: CGSize) {
        guard let start = currentStartPoint, let end = currentEndPoint else {
            currentStartPoint = value.location
            return
        }

        // Only create wall if it has meaningful length
        let minLength: CGFloat = 10.0
        if start.distance(to: end) > minLength {
            let wall = Wall(startPoint: start, endPoint: end)
            floorPlan.addWall(wall)
        }

        // Reset for next wall
        currentStartPoint = nil
        currentEndPoint = nil
    }

    private func snapToGrid(_ point: CGPoint) -> CGPoint {
        let gridSize = floorPlan.scale * zoom * 12 // Snap to 12-inch grid
        return CGPoint(
            x: round(point.x / gridSize) * gridSize,
            y: round(point.y / gridSize) * gridSize
        )
    }
}

/// View for rendering a single wall
struct WallView: View {
    let wall: Wall
    let scale: CGFloat
    let isSelected: Bool
    let isHovered: Bool
    var isTemporary: Bool = false

    var body: some View {
        Path { path in
            path.move(to: wall.startPoint)
            path.addLine(to: wall.endPoint)
        }
        .stroke(
            strokeColor,
            style: StrokeStyle(
                lineWidth: wall.thickness * scale,
                lineCap: .round
            )
        )
    }

    private var strokeColor: Color {
        if isTemporary {
            return Color.blue.opacity(0.5)
        } else if isSelected {
            return Color.orange
        } else if isHovered {
            return Color.blue
        } else {
            return Color.black
        }
    }
}

/// Grid background for the canvas
struct GridView: View {
    let scale: CGFloat
    let offset: CGSize

    var body: some View {
        Canvas { context, size in
            let gridSpacing = scale * 12 // 12 inches (1 foot)
            let minorGridSpacing = scale * 1 // 1 inch

            // Draw minor grid (inches) - lighter
            context.stroke(
                Path { path in
                    // Vertical lines
                    var x: CGFloat = 0
                    while x < size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        x += minorGridSpacing
                    }
                    // Horizontal lines
                    var y: CGFloat = 0
                    while y < size.height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        y += minorGridSpacing
                    }
                },
                with: .color(.gray.opacity(0.1)),
                lineWidth: 0.5
            )

            // Draw major grid (feet) - darker
            context.stroke(
                Path { path in
                    // Vertical lines
                    var x: CGFloat = 0
                    while x < size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        x += gridSpacing
                    }
                    // Horizontal lines
                    var y: CGFloat = 0
                    while y < size.height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        y += gridSpacing
                    }
                },
                with: .color(.gray.opacity(0.3)),
                lineWidth: 1.0
            )
        }
    }
}

/// Label showing the measurement of a wall
struct MeasurementLabel: View {
    let wall: Wall
    let floorPlan: FloorPlan
    let zoom: CGFloat

    var body: some View {
        Text(floorPlan.formatMeasurement(wall.length))
            .font(.system(size: 12 / zoom))
            .padding(4)
            .background(Color.white.opacity(0.9))
            .cornerRadius(4)
            .position(wall.center)
    }
}

// Helper extension for distance calculation
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt(dx * dx + dy * dy)
    }
}
