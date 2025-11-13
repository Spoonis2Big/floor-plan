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
    @State private var editMode: EditMode = .none
    @State private var dragStartLocation: CGPoint = .zero
    @State private var originalWall: Wall?

    enum EditMode {
        case none
        case drawing
        case movingWall
        case adjustingStartPoint
        case adjustingEndPoint
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                GridView(scale: floorPlan.scale * zoom, offset: offset)
                    .background(Color.white)

                // Existing walls
                ForEach(floorPlan.walls) { wall in
                    ZStack {
                        WallView(
                            wall: wall,
                            scale: floorPlan.scale * zoom,
                            isSelected: selectedWall?.id == wall.id,
                            isHovered: hoveredWall?.id == wall.id
                        )

                        // Show endpoint handles when wall is selected
                        if selectedWall?.id == wall.id {
                            EndpointHandle(position: wall.startPoint, color: .blue)
                            EndpointHandle(position: wall.endPoint, color: .green)
                        }
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

        switch editMode {
        case .none:
            // Determine what we're dragging
            if let wall = selectedWall {
                // Check if we're near an endpoint
                if wall.isNearStartPoint(location, hitRadius: 20 / zoom) {
                    editMode = .adjustingStartPoint
                    dragStartLocation = location
                    originalWall = wall
                } else if wall.isNearEndPoint(location, hitRadius: 20 / zoom) {
                    editMode = .adjustingEndPoint
                    dragStartLocation = location
                    originalWall = wall
                } else if wall.isOnWall(location, hitRadius: 15 / zoom) {
                    editMode = .movingWall
                    dragStartLocation = location
                    originalWall = wall
                } else {
                    // Start drawing a new wall
                    editMode = .drawing
                    currentStartPoint = snapToGrid(location)
                    selectedWall = nil
                }
            } else {
                // Check if clicking on an existing wall to select it
                if let wall = findWallAtPoint(location) {
                    selectedWall = wall
                    // Don't start editing yet, wait for next drag
                } else {
                    // Start drawing a new wall
                    editMode = .drawing
                    currentStartPoint = snapToGrid(location)
                }
            }

        case .drawing:
            // Continue drawing
            currentEndPoint = snapToGrid(location)

        case .movingWall:
            guard var wall = originalWall else { return }
            let dx = location.x - dragStartLocation.x
            let dy = location.y - dragStartLocation.y
            wall.moveBy(dx: dx, dy: dy)
            wall.startPoint = snapToGrid(wall.startPoint)
            wall.endPoint = snapToGrid(wall.endPoint)
            floorPlan.updateWall(wall)
            selectedWall = wall
            dragStartLocation = location

        case .adjustingStartPoint:
            guard var wall = originalWall else { return }
            wall.startPoint = snapToGrid(location)
            floorPlan.updateWall(wall)
            selectedWall = wall
            originalWall = wall

        case .adjustingEndPoint:
            guard var wall = originalWall else { return }
            wall.endPoint = snapToGrid(location)
            floorPlan.updateWall(wall)
            selectedWall = wall
            originalWall = wall
        }
    }

    private func handleDragEnd(_ value: DragGesture.Value, in size: CGSize) {
        switch editMode {
        case .drawing:
            guard let start = currentStartPoint, let end = currentEndPoint else {
                return
            }

            // Only create wall if it has meaningful length
            let minLength: CGFloat = 10.0
            if start.distance(to: end) > minLength {
                let wall = Wall(startPoint: start, endPoint: end)
                floorPlan.addWall(wall)
                selectedWall = wall
            }

            // Reset drawing state
            currentStartPoint = nil
            currentEndPoint = nil

        case .movingWall, .adjustingStartPoint, .adjustingEndPoint:
            // Finalize the edit
            originalWall = nil

        case .none:
            break
        }

        editMode = .none
    }

    private func findWallAtPoint(_ point: CGPoint) -> Wall? {
        // Check endpoints first (higher priority)
        for wall in floorPlan.walls {
            if wall.isNearStartPoint(point, hitRadius: 20 / zoom) ||
               wall.isNearEndPoint(point, hitRadius: 20 / zoom) {
                return wall
            }
        }

        // Then check wall bodies
        for wall in floorPlan.walls {
            if wall.isOnWall(point, hitRadius: 15 / zoom) {
                return wall
            }
        }

        return nil
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

/// Visual handle for wall endpoints
struct EndpointHandle: View {
    let position: CGPoint
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .position(position)
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
