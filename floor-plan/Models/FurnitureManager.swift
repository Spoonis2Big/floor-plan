class FurnitureManager: ObservableObject {
    // ... existing code ...
    
    enum ToolType {
        case select
        case pan
        case rectangle
        case circle
        case wall
    }
    
    @Published var currentTool: ToolType = .select
    @Published var zoomLevel: Double = 1.0
    @Published var showGrid: Bool = true
    @Published var snapToGrid: Bool = true
    @Published var gridSize: Double = 20
    @Published var gridOpacity: Double = 0.3
    
    // ... existing code ...
    
    func zoomIn() {
        zoomLevel = min(zoomLevel + 0.25, 3.0)
    }
    
    func zoomOut() {
        zoomLevel = max(zoomLevel - 0.25, 0.25)
    }
    
    func fitToWindow() {
        // Calculate zoom to fit all furniture
        // This is a placeholder - implement based on canvas size
        zoomLevel = 1.0
    }
}
