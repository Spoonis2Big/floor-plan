import SwiftUI

struct MainEditorView: View {
    @State private var showMaterialPicker = false
    @State private var selectedMaterial: Material?
    
    var body: some View {
        HSplitView {
            // Left sidebar - Material Picker
            if showMaterialPicker {
                MaterialPickerView { material in
                    selectedMaterial = material
                    print("Selected material: \(material.name)")
                }
            }
            
            // Main canvas area
            ZStack {
                Color(NSColor.textBackgroundColor)
                
                Text("Floor Plan Canvas")
                    .foregroundColor(.secondary)
            }
            .frame(minWidth: 400)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { showMaterialPicker.toggle() }) {
                    Label("Materials", systemImage: "paintpalette")
                }
            }
        }
    }
}

#Preview {
    MainEditorView()
        .frame(width: 1000, height: 700)
}
