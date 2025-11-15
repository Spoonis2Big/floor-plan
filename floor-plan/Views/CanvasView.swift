import SwiftUI

struct CanvasView: View {
    @ObservedObject var manager: FurnitureManager
    
    @State private var canvasSize: CGSize = .zero
    @State private var isDropTargeted = false
    @State private var dragLocation: CGPoint?
    @State private var previewItem: FurnitureDragData?
    @State private var previewHasCollision = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                GridBackgroundView(
                    gridSize: manager.gridSettings.gridSize,
                    showGrid: manager.gridSettings.showGrid
                )
                
                // Canvas background
                Rectangle()
                    .fill(Color.white.opacity(0.01))
                    .border(isDropTargeted ? Color.blue : Color.gray, width: isDropTargeted ? 3 : 1)
                
                // Existing furniture items
                ForEach(manager.items) { item in
                    FurnitureItemView(
                        item: item,
                        isSelected: manager.selectedItemId == item.id,
                        manager: manager
                    )
                }
                
                // Drag preview
                if let preview = previewItem, let location = dragLocation {
                    DragPreviewView(furniture: preview, hasCollision: previewHasCollision)
                        .position(location)
                        .opacity(0.7)
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        canvasSize = geo.size
                    }
                }
            )
            .onDrop(
                of: [FurnitureDragData.utType],
                isTargeted: $isDropTargeted
            ) { providers, location in
                handleDrop(providers: providers, location: location, in: geometry)
            }
            .onDrop(
                of: [FurnitureDragData.utType],
                delegate: CanvasDropDelegate(
                    dragLocation: $dragLocation,
                    previewItem: $previewItem,
                    previewHasCollision: $previewHasCollision,
                    manager: manager,
                    geometry: geometry
                )
            )
            .contentShape(Rectangle())
            .onTapGesture {
                manager.selectItem(nil)
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider], location: CGPoint, in geometry: GeometryProxy) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadDataRepresentation(forTypeIdentifier: FurnitureDragData.utType.identifier) { data, error in
            guard let data = data,
                  let dragData = try? JSONDecoder().decode(FurnitureDragData.self, from: data) else {
                return
            }
            
            DispatchQueue.main.async {
                // Snap to grid
                let snappedPosition = manager.gridSettings.snapPoint(location)
                
                // Create new furniture item
                let newItem = FurnitureItem(
                    id: UUID(),
                    furnitureId: dragData.furnitureId,
                    name: dragData.name,
                    position: snappedPosition,
                    rotation: 0,
                    width: dragData.width,
                    height: dragData.height
                )
                
                // Check collision before adding
                if !manager.checkCollision(for: newItem) {
                    manager.addItem(newItem)
                }
                
                // Clear preview
                dragLocation = nil
                previewItem = nil
            }
        }
        
        return true
    }
}

// Drop delegate for drag preview
struct CanvasDropDelegate: DropDelegate {
    @Binding var dragLocation: CGPoint?
    @Binding var previewItem: FurnitureDragData?
    @Binding var previewHasCollision: Bool
    let manager: FurnitureManager
    let geometry: GeometryProxy
    
    func dropEntered(info: DropInfo) {
        loadPreviewData(from: info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        dragLocation = info.location
        updateCollisionStatus()
        return DropProposal(operation: .copy)
    }
    
    func dropExited(info: DropInfo) {
        dragLocation = nil
        previewItem = nil
        previewHasCollision = false
    }
    
    func performDrop(info: DropInfo) -> Bool {
        dragLocation = nil
        previewItem = nil
        previewHasCollision = false
        return true
    }
    
    private func loadPreviewData(from info: DropInfo) {
        guard let provider = info.itemProviders(for: [FurnitureDragData.utType]).first else { return }
        
        provider.loadDataRepresentation(forTypeIdentifier: FurnitureDragData.utType.identifier) { data, error in
            guard let data = data,
                  let dragData = try? JSONDecoder().decode(FurnitureDragData.self, from: data) else {
                return
            }
            
            DispatchQueue.main.async {
                previewItem = dragData
                updateCollisionStatus()
            }
        }
    }
    
    private func updateCollisionStatus() {
        guard let preview = previewItem, let location = dragLocation else {
            previewHasCollision = false
            return
        }
        
        let snappedPosition = manager.gridSettings.snapPoint(location)
        
        let tempItem = FurnitureItem(
            id: UUID(),
            furnitureId: preview.furnitureId,
            name: preview.name,
            position: snappedPosition,
            rotation: 0,
            width: preview.width,
            height: preview.height
        )
        
        previewHasCollision = manager.checkCollision(for: tempItem)
    }
}
