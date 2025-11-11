import SwiftUI

struct ContentView: View {
    @StateObject private var floorPlan = FloorPlan()
    @State private var selectedView: ViewMode = .floorPlan

    enum ViewMode: String, CaseIterable {
        case floorPlan = "Floor Plan"
        case elevations = "Elevations"
    }

    var body: some View {
        NavigationSplitView {
            // Settings sidebar
            SettingsPanel(floorPlan: floorPlan)
        } detail: {
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Picker("View", selection: $selectedView) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)

                    Spacer()

                    Text(floorPlan.name)
                        .font(.headline)

                    Spacer()

                    HStack(spacing: 12) {
                        Button(action: {
                            // Save functionality
                            saveFloorPlan()
                        }) {
                            Label("Save", systemImage: "square.and.arrow.down")
                        }

                        Button(action: {
                            // Load functionality
                            loadFloorPlan()
                        }) {
                            Label("Load", systemImage: "folder")
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                // Main content area
                Group {
                    switch selectedView {
                    case .floorPlan:
                        FloorPlanCanvasView(floorPlan: floorPlan)
                    case .elevations:
                        AllElevationsView(floorPlan: floorPlan)
                    }
                }
            }
        }
        .navigationTitle("Floor Plan Designer")
    }

    // MARK: - File Operations

    private func saveFloorPlan() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "\(floorPlan.name).json"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let data = try encoder.encode(floorPlan)
                    try data.write(to: url)
                } catch {
                    print("Error saving floor plan: \(error)")
                }
            }
        }
    }

    private func loadFloorPlan() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false

        panel.begin { response in
            if response == .OK, let url = panel.urls.first {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let loadedPlan = try decoder.decode(FloorPlan.self, from: data)

                    // Update current floor plan
                    floorPlan.walls = loadedPlan.walls
                    floorPlan.name = loadedPlan.name
                    floorPlan.scale = loadedPlan.scale
                    floorPlan.unit = loadedPlan.unit
                } catch {
                    print("Error loading floor plan: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
