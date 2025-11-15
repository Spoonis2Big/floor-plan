import SwiftUI

struct MainView: View {
    @StateObject private var furnitureManager = FurnitureManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            CanvasToolbar(manager: furnitureManager)
            
            Divider()
            
            // Main content
            HStack(spacing: 0) {
                // Furniture Palette
                FurniturePaletteView()
                    .frame(width: 200)
                
                Divider()
                
                // Canvas
                CanvasView(manager: furnitureManager)
            }
        }
        .onAppear {
            setupKeyboardShortcuts()
        }
    }
    
    private func setupKeyboardShortcuts() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) {
                if event.characters == "z" {
                    if event.modifierFlags.contains(.shift) {
                        furnitureManager.undoManager.redo()
                    } else {
                        furnitureManager.undoManager.undo()
                    }
                    return nil
                }
            } else if event.keyCode == 51 { // Delete key
                furnitureManager.deleteSelected()
                return nil
            }
            return event
        }
    }
}
