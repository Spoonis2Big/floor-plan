import SwiftUI

struct MaterialPickerView: View {
    @StateObject private var viewModel = MaterialPickerViewModel()
    @State private var showColorPicker = false
    
    var onMaterialSelected: ((Material) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Type Selector
            typeSelectorView
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Current Material Preview
                    currentMaterialPreview
                    
                    Divider()
                    
                    // Color Picker
                    colorPickerSection
                    
                    Divider()
                    
                    // Finish Selector
                    finishSelectorSection
                    
                    Divider()
                    
                    // Preset Materials
                    presetMaterialsSection
                    
                    if !viewModel.customMaterials.isEmpty {
                        Divider()
                        customMaterialsSection
                    }
                    
                    if !viewModel.recentMaterials.isEmpty {
                        Divider()
                        recentMaterialsSection
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer with action buttons
            footerView
        }
        .frame(width: 300)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Text("Material Picker")
                .font(.headline)
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Type Selector
    
    private var typeSelectorView: some View {
        Picker("Material Type", selection: $viewModel.selectedType) {
            Text("Wall").tag(MaterialType.wall)
            Text("Floor").tag(MaterialType.floor)
            Text("Ceiling").tag(MaterialType.ceiling)
        }
        .pickerStyle(.segmented)
        .padding()
        .onChange(of: viewModel.selectedType) { newType in
            viewModel.currentMaterial = Material.defaultMaterial(for: newType)
        }
    }
    
    // MARK: - Current Material Preview
    
    private var currentMaterialPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Selection")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                // Color Preview
                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.currentMaterial.color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentMaterial.name)
                        .font(.system(size: 13, weight: .medium))
                    
                    Text(viewModel.currentMaterial.finish.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    if let texture = viewModel.currentMaterial.texture {
                        Text("Texture: \(texture.capitalized)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Color Picker Section
    
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ColorPicker("Select Color", selection: Binding(
                get: { viewModel.currentMaterial.color },
                set: { viewModel.updateColor($0) }
            ))
            .labelsHidden()
        }
    }
    
    // MARK: - Finish Selector
    
    private var finishSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Finish")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Finish", selection: Binding(
                get: { viewModel.currentMaterial.finish },
                set: { viewModel.updateFinish($0) }
            )) {
                ForEach(MaterialFinish.allCases, id: \.self) { finish in
                    Text(finish.rawValue).tag(finish)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Preset Materials
    
    private var presetMaterialsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Presets")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80), spacing: 8)
            ], spacing: 8) {
                ForEach(viewModel.getMaterialsForCurrentType()) { material in
                    MaterialTile(material: material, isSelected: material.id == viewModel.currentMaterial.id)
                        .onTapGesture {
                            viewModel.selectMaterial(material)
                        }
                }
            }
        }
    }
    
    // MARK: - Custom Materials
    
    private var customMaterialsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Materials")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80), spacing: 8)
            ], spacing: 8) {
                ForEach(viewModel.customMaterials) { material in
                    MaterialTile(material: material, isSelected: material.id == viewModel.currentMaterial.id)
                        .onTapGesture {
                            viewModel.selectMaterial(material)
                        }
                }
            }
        }
    }
    
    // MARK: - Recent Materials
    
    private var recentMaterialsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recently Used")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.recentMaterials) { material in
                        MaterialTile(material: material, isSelected: material.id == viewModel.currentMaterial.id)
                            .frame(width: 80)
                            .onTapGesture {
                                viewModel.selectMaterial(material)
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            Button("Save as Custom") {
                viewModel.saveCustomMaterial()
            }
            
            Spacer()
            
            Button("Apply") {
                onMaterialSelected?(viewModel.currentMaterial)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Material Tile Component

struct MaterialTile: View {
    let material: Material
    var isSelected: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .fill(material.color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
            
            Text(material.name)
                .font(.system(size: 10))
                .lineLimit(1)
                .foregroundColor(isSelected ? .accentColor : .primary)
        }
    }
}

// MARK: - Preview

#Preview {
    MaterialPickerView()
        .frame(height: 600)
}
