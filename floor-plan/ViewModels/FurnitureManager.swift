import Foundation
import SwiftUI

class FurnitureManager: ObservableObject {
    @Published var items: [FurnitureItem] = []
    @Published var selectedItemId: UUID?
    @Published var gridSettings = GridSettings()
    
    let undoManager = UndoManager()
    
    func addItem(_ item: FurnitureItem, useUndo: Bool = true) {
        if useUndo {
            let command = AddFurnitureCommand(item: item, manager: self)
            undoManager.executeCommand(command)
        } else {
            items.append(item)
        }
    }
    
    func removeItem(_ id: UUID, useUndo: Bool = true) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        
        if useUndo {
            let command = RemoveFurnitureCommand(item: item, manager: self)
            undoManager.executeCommand(command)
        } else {
            items.removeAll { $0.id == id }
            if selectedItemId == id {
                selectedItemId = nil
            }
        }
    }
    
    func updateItemPosition(_ id: UUID, position: CGPoint, useUndo: Bool = false) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        
        if useUndo, let oldPosition = items.first(where: { $0.id == id })?.position {
            let command = MoveFurnitureCommand(
                itemId: id,
                oldPosition: oldPosition,
                newPosition: position,
                manager: self
            )
            undoManager.executeCommand(command)
        } else {
            items[index].position = position
        }
    }
    
    func updateItemRotation(_ id: UUID, rotation: Double) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].rotation = rotation
    }
    
    func checkCollision(for item: FurnitureItem, excludingId: UUID? = nil) -> Bool {
        let itemRect = CGRect(
            x: item.position.x - item.width / 2,
            y: item.position.y - item.height / 2,
            width: item.width,
            height: item.height
        )
        
        for existingItem in items {
            if existingItem.id == excludingId || existingItem.id == item.id {
                continue
            }
            
            let existingRect = CGRect(
                x: existingItem.position.x - existingItem.width / 2,
                y: existingItem.position.y - existingItem.height / 2,
                width: existingItem.width,
                height: existingItem.height
            )
            
            if itemRect.intersects(existingRect) {
                return true
            }
        }
        
        return false
    }
    
    func selectItem(_ id: UUID?) {
        selectedItemId = id
    }
    
    func deleteSelected() {
        if let id = selectedItemId {
            removeItem(id)
        }
    }
}
