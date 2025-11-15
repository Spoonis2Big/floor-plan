import SwiftUI

@Observable
class RoomEditorViewModel {
    var rooms: [Room] = []
    var selectedRoomId: UUID?
    var drawingMode: DrawingMode = .select
    var currentWallStart: CGPoint?
    var snapToGrid: Bool = true
    var gridSize: CGFloat = 20
    
    var selectedRoom: Room? {
        get {
            rooms.first { $0.id == selectedRoomId }
        }
        set {
            if let newValue = newValue,
               let index = rooms.firstIndex(where: { $0.id == newValue.id }) {
                rooms[index] = newValue
            }
        }
    }
    
    enum DrawingMode {
        case select
        case drawWall
        case drawRoom
        case addDoor
        case addWindow
    }
    
    func addRoom(_ room: Room) {
        rooms.append(room)
        selectedRoomId = room.id
    }
    
    func deleteRoom(_ id: UUID) {
        rooms.removeAll { $0.id == id }
        if selectedRoomId == id {
            selectedRoomId = nil
        }
    }
    
    func startDrawingWall(at point: CGPoint) {
        let snappedPoint = snapToGrid ? snapPoint(point) : point
        currentWallStart = snappedPoint
    }
    
    func finishDrawingWall(at point: CGPoint) {
        guard let start = currentWallStart else { return }
        let snappedPoint = snapToGrid ? snapPoint(point) : point
        
        let wall = Wall(start: start, end: snappedPoint)
        
        if let selectedRoom = selectedRoom {
            var updatedRoom = selectedRoom
            updatedRoom.walls.append(wall)
            self.selectedRoom = updatedRoom
        } else {
            // Create new room with this wall
            let newRoom = Room(walls: [wall])
            addRoom(newRoom)
        }
        
        currentWallStart = nil
    }
    
    func cancelDrawing() {
        currentWallStart = nil
    }
    
    private func snapPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: round(point.x / gridSize) * gridSize,
            y: round(point.y / gridSize) * gridSize
        )
    }
}
