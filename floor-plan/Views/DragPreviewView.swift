import SwiftUI

struct DragPreviewView: View {
    let furniture: FurnitureDragData
    let hasCollision: Bool
    
    var body: some View {
        Rectangle()
            .fill(hasCollision ? Color.red.opacity(0.3) : Color.blue.opacity(0.3))
            .frame(width: furniture.width, height: furniture.height)
            .border(hasCollision ? Color.red : Color.blue, width: 2)
            .overlay(
                VStack {
                    Image(systemName: hasCollision ? "exclamationmark.triangle" : "checkmark")
                        .foregroundColor(.white)
                    Text(furniture.name)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            )
    }
}
