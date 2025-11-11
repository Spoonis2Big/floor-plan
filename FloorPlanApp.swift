import SwiftUI

@main
struct FloorPlanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Floor Plan") {
                    // Handle new floor plan
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
