import SwiftUI

struct RoomEditorView: View {
    @Bindable var viewModel: RoomEditorViewModel
    @State private var canvasSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Grid background
            if viewModel.snapToGrid {
                GridBackgroundView(gridSize: viewModel.gridSize)
            }
            
            // Rooms
            ForEach(viewModel.rooms) { room in
                RoomView(room: room, isSelected: room.id == viewModel.selectedRoomId)
                    .onTapGesture {
                        if viewModel.drawingMode == .select {
                            viewModel.selectedRoomId = room.id
                        }
                    }
            }
            
            // Current drawing
            if let start = viewModel.currentWallStart {
                CurrentWallPreview(start: start)
            }
        }
        .background(Color(NSColor.textBackgroundColor))
        .gesture(dragGesture)
        .overlay(alignment: .topTrailing) {
            drawingModeToolbar
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if viewModel.drawingMode == .drawWall && viewModel.currentWallStart == nil {
                    viewModel.startDrawingWall(at: value.location)
                }
            }
            .onEnded { value in
                if viewModel.drawingMode == .drawWall {
                    viewModel.finishDrawingWall(at: value.location)
                }
            }
    }
    
    private var drawingModeToolbar: some View {
        HStack(spacing: 12) {
            DrawingModeButton(
                mode: .select,
                icon: "arrow.up.left.and.arrow.down.right",
                isSelected: viewModel.drawingMode == .select
            ) {
                viewModel.drawingMode = .select
            }
            
            DrawingModeButton(
                mode: .drawWall,
                icon: "rectangle.on.rectangle.angled",
                isSelected: viewModel.drawingMode == .drawWall
            ) {
                viewModel.drawingMode = .drawWall
            }
            
            DrawingModeButton(
                mode: .addDoor,
                icon: "door.left.hand.open",
                isSelected: viewModel.drawingMode == .addDoor
            ) {
                viewModel.drawingMode = .addDoor
            }
            
            DrawingModeButton(
                mode: .addWindow,
                icon: "square.split.2x1",
                isSelected: viewModel.drawingMode == .addWindow
            ) {
                viewModel.drawingMode = .addWindow
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding()
    }
}

struct DrawingModeButton: View {
    let mode: RoomEditorViewModel.DrawingMode
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct RoomView: View {
    let room: Room
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Room fill
            if !room.walls.isEmpty {
                roomShape
                    .fill(room.color.color)
                    .opacity(0.5)
            }
            
            // Walls
            ForEach(room.walls) { wall in
                WallView(wall: wall)
            }
            
            // Room label
            Text(room.name)
                .font(.headline)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
                .position(room.bounds.center)
        }
        .overlay {
            if isSelected {
                roomShape
                    .stroke(Color.accentColor, lineWidth: 2)
            }
        }
    }
    
    private var roomShape: Path {
        guard !room.walls.isEmpty else { return Path() }
        
        var path = Path()
        let points = room.walls.map { $0.start }
        
        if let first = points.first {
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        return path
    }
}

struct WallView: View {
    let wall: Wall
    
    var body: some View {
        Path { path in
            path.move(to: wall.start)
            path.addLine(to: wall.end)
        }
        .stroke(lineWidth: wall.thickness)
        .foregroundColor(.black)
    }
}

struct CurrentWallPreview: View {
    let start: CGPoint
    @State private var currentPosition: CGPoint = .zero
    
    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: currentPosition)
        }
        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
        .foregroundColor(.accentColor)
        .onContinuousHover { phase in
            if case .active(let location) = phase {
                currentPosition = location
            }
        }
    }
}

struct GridBackgroundView: View {
    let gridSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Vertical lines
                for x in stride(from: 0, through: width, by: gridSize) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                
                // Horizontal lines
                for y in stride(from: 0, through: height, by: gridSize) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
