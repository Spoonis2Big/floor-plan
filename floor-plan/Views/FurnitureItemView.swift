import SwiftUI

struct FurnitureItemView: View {
    let item: FurnitureItem
    let isSelected: Bool
    @ObservedObject var manager: FurnitureManager
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var startPosition: CGPoint = .zero
    
    var body: some View {
        Rectangle()
            .fill(isSelected ? Color.blue.opacity(0.5) : Color.blue.opacity(0.3))
            .frame(width: item.width, height: item.height)
            .border(isSelected ? Color.blue : Color.gray, width: isSelected ? 3 : 2)
            .overlay(
                VStack(spacing: 4) {
                    Text(item.name)
                        .font(.caption)
                        .foregroundColor(.white)
                        .bold()
                    
                    if isSelected {
                        HStack(spacing: 8) {
                            Button(action: rotateLeft) {
                                Image(systemName: "rotate.left")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: rotateRight) {
                                Image(systemName: "rotate.right")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                    }
                }
            )
            .rotationEffect(.degrees(item.rotation))
            .position(
                x: item.position.x + dragOffset.width,
                y: item.position.y + dragOffset.height
            )
            .shadow(radius: isDragging ? 8 : (isSelected ? 4 : 0))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            startPosition = item.position
                            manager.selectItem(item.id)
                        }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let newPosition = CGPoint(
                            x: item.position.x + value.translation.width,
                            y: item.position.y + value.translation.height
                        )
                        
                        let snappedPosition = manager.gridSettings.snapPoint(newPosition)
                        
                        // Create temporary item to check collision
                        var tempItem = item
                        tempItem.position = snappedPosition
                        
                        if !manager.checkCollision(for: tempItem, excludingId: item.id) {
                            manager.updateItemPosition(item.id, position: snappedPosition, useUndo: true)
                        }
                        
                        dragOffset = .zero
                        isDragging = false
                    }
            )
            .onTapGesture {
                manager.selectItem(item.id)
            }
    }
    
    private func rotateLeft() {
        let newRotation = item.rotation - 90
        manager.updateItemRotation(item.id, rotation: newRotation)
    }
    
    private func rotateRight() {
        let newRotation = item.rotation + 90
        manager.updateItemRotation(item.id, rotation: newRotation)
    }
}
