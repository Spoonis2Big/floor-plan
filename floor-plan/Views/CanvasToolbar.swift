import SwiftUI

struct CanvasToolbar: View {
    @ObservedObject var manager: FurnitureManager
    @State private var showingGridSettings = false
    @State private var showingExportOptions = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection Tools
            HStack(spacing: 4) {
                ToolButton(
                    icon: "arrow.up.left.and.arrow.down.right",
                    tooltip: "Select (V)",
                    isSelected: manager.currentTool == .select
                ) {
                    manager.currentTool = .select
                }
                
                ToolButton(
                    icon: "hand.draw",
                    tooltip: "Pan (H)",
                    isSelected: manager.currentTool == .pan
                ) {
                    manager.currentTool = .pan
                }
            }
            
            Divider()
                .frame(height: 24)
            
            // Drawing Tools
            HStack(spacing: 4) {
                ToolButton(
                    icon: "rectangle",
                    tooltip: "Rectangle (R)",
                    isSelected: manager.currentTool == .rectangle
                ) {
                    manager.currentTool = .rectangle
                }
                
                ToolButton(
                    icon: "circle",
                    tooltip: "Circle (C)",
                    isSelected: manager.currentTool == .circle
                ) {
                    manager.currentTool = .circle
                }
                
                ToolButton(
                    icon: "line.diagonal",
                    tooltip: "Wall (W)",
                    isSelected: manager.currentTool == .wall
                ) {
                    manager.currentTool = .wall
                }
            }
            
            Divider()
                .frame(height: 24)
            
            // Edit Actions
            HStack(spacing: 4) {
                ToolButton(
                    icon: "arrow.uturn.backward",
                    tooltip: "Undo (⌘Z)",
                    isEnabled: manager.undoManager.canUndo
                ) {
                    manager.undoManager.undo()
                }
                
                ToolButton(
                    icon: "arrow.uturn.forward",
                    tooltip: "Redo (⌘⇧Z)",
                    isEnabled: manager.undoManager.canRedo
                ) {
                    manager.undoManager.redo()
                }
            }
            
            Divider()
                .frame(height: 24)
            
            // View Controls
            HStack(spacing: 4) {
                ToolButton(
                    icon: "square.grid.2x2",
                    tooltip: "Grid Settings",
                    isSelected: showingGridSettings
                ) {
                    showingGridSettings.toggle()
                }
                
                ToolButton(
                    icon: "minus.magnifyingglass",
                    tooltip: "Zoom Out (⌘-)"
                ) {
                    manager.zoomOut()
                }
                
                Text("\(Int(manager.zoomLevel * 100))%")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .frame(width: 45)
                
                ToolButton(
                    icon: "plus.magnifyingglass",
                    tooltip: "Zoom In (⌘+)"
                ) {
                    manager.zoomIn()
                }
                
                ToolButton(
                    icon: "arrow.up.left.and.arrow.down.right",
                    tooltip: "Fit to Window"
                ) {
                    manager.fitToWindow()
                }
            }
            
            Spacer()
            
            // Export & Settings
            HStack(spacing: 4) {
                ToolButton(
                    icon: "square.and.arrow.up",
                    tooltip: "Export"
                ) {
                    showingExportOptions = true
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .popover(isPresented: $showingGridSettings) {
            GridSettingsPopover(manager: manager)
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsSheet(manager: manager)
        }
    }
}

// MARK: - Tool Button

struct ToolButton: View {
    let icon: String
    let tooltip: String
    var isSelected: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isEnabled ? (isSelected ? .accentColor : .primary) : .secondary)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(tooltip)
        .disabled(!isEnabled)
    }
}

// MARK: - Grid Settings Popover

struct GridSettingsPopover: View {
    @ObservedObject var manager: FurnitureManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grid Settings")
                .font(.headline)
            
            Toggle("Show Grid", isOn: $manager.showGrid)
            
            Toggle("Snap to Grid", isOn: $manager.snapToGrid)
            
            HStack {
                Text("Grid Size:")
                Spacer()
                TextField("", value: $manager.gridSize, format: .number)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                Text("px")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Grid Opacity:")
                Spacer()
                Slider(value: $manager.gridOpacity, in: 0...1)
                    .frame(width: 100)
                Text("\(Int(manager.gridOpacity * 100))%")
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding()
        .frame(width: 280)
    }
}

// MARK: - Export Options Sheet

struct ExportOptionsSheet: View {
    @ObservedObject var manager: FurnitureManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedFormat: ExportFormat = .png
    @State private var includeGrid = false
    @State private var exportScale: Double = 1.0
    
    enum ExportFormat: String, CaseIterable {
        case png = "PNG"
        case pdf = "PDF"
        case svg = "SVG"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Floor Plan")
                .font(.headline)
            
            Form {
                Picker("Format:", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("Include Grid", isOn: $includeGrid)
                
                HStack {
                    Text("Scale:")
                    Slider(value: $exportScale, in: 0.5...3.0, step: 0.5)
                    Text("\(exportScale, specifier: "%.1f")x")
                        .frame(width: 40)
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Export...") {
                    exportFloorPlan()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    private func exportFloorPlan() {
        // TODO: Implement export functionality
        dismiss()
    }
}
