import Foundation

protocol Command {
    func execute()
    func undo()
}

class AddFurnitureCommand: Command {
    let item: FurnitureItem
    weak var manager: FurnitureManager?
    
    init(item: FurnitureItem, manager: FurnitureManager) {
        self.item = item
        self.manager = manager
    }
    
    func execute() {
        manager?.addItem(item)
    }
    
    func undo() {
        manager?.removeItem(item.id)
    }
}

class RemoveFurnitureCommand: Command {
    let item: FurnitureItem
    weak var manager: FurnitureManager?
    
    init(item: FurnitureItem, manager: FurnitureManager) {
        self.item = item
        self.manager = manager
    }
    
    func execute() {
        manager?.removeItem(item.id)
    }
    
    func undo() {
        manager?.addItem(item)
    }
}

class MoveFurnitureCommand: Command {
    let itemId: UUID
    let oldPosition: CGPoint
    let newPosition: CGPoint
    weak var manager: FurnitureManager?
    
    init(itemId: UUID, oldPosition: CGPoint, newPosition: CGPoint, manager: FurnitureManager) {
        self.itemId = itemId
        self.oldPosition = oldPosition
        self.newPosition = newPosition
        self.manager = manager
    }
    
    func execute() {
        manager?.updateItemPosition(itemId, position: newPosition)
    }
    
    func undo() {
        manager?.updateItemPosition(itemId, position: oldPosition)
    }
}

class UndoManager: ObservableObject {
    @Published private(set) var canUndo = false
    @Published private(set) var canRedo = false
    
    private var undoStack: [Command] = []
    private var redoStack: [Command] = []
    private let maxStackSize = 50
    
    func executeCommand(_ command: Command) {
        command.execute()
        undoStack.append(command)
        redoStack.removeAll()
        
        // Limit stack size
        if undoStack.count > maxStackSize {
            undoStack.removeFirst()
        }
        
        updateState()
    }
    
    func undo() {
        guard let command = undoStack.popLast() else { return }
        command.undo()
        redoStack.append(command)
        updateState()
    }
    
    func redo() {
        guard let command = redoStack.popLast() else { return }
        command.execute()
        undoStack.append(command)
        updateState()
    }
    
    private func updateState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
    
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateState()
    }
}
