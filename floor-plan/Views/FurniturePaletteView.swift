import SwiftUI

struct FurniturePaletteView: View {
    @State private var selectedCategory: FurnitureCategory = .seating
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Picker
            categoryPicker
            
            Divider()
            
            // Furniture Grid
            furnitureGrid
        }
        .frame(width: 250)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var categoryPicker: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(FurnitureCategory.allCases, id: \.self) { category in
                Text(category.rawValue).tag(category)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var furnitureGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredFurniture, id: \.self) { type in
                    FurniturePaletteItem(furnitureType: type)
                }
            }
            .padding()
        }
    }
    
    private var filteredFurniture: [FurnitureType] {
        FurnitureType.allCases.filter { $0.category == selectedCategory }
    }
}

struct FurniturePaletteItem: View {
    let furnitureType: FurnitureType
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: furnitureType.icon)
                .font(.system(size: 40))
                .frame(width: 80, height: 80)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            
            Text(furnitureType.rawValue.capitalized)
                .font(.caption)
        }
        .opacity(isDragging ? 0.5 : 1.0)
        .onDrag {
            isDragging = true
            let furniture = Furniture(type: furnitureType)
            let data = try? JSONEncoder().encode(furniture)
            return NSItemProvider(item: data as? NSData, typeIdentifier: "com.floorplan.furniture")
        }
    }
}
