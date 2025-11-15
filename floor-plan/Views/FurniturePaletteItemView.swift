import SwiftUI

struct FurniturePaletteItemView: View {
    let furniture: Furniture
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: furniture.iconName)
                .font(.system(size: 32))
                .foregroundColor(furniture.color)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Text(furniture.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .background(isDragging ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onDrag {
            isDragging = true
            
            let dragData = furniture.toDragData()
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(dragData) else {
                return NSItemProvider()
            }
            
            let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: FurnitureDragData.utType.identifier)
            return itemProvider
        } onEnded: { _ in
            isDragging = false
        }
    }
}
