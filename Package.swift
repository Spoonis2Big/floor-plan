// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FloorPlan",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "FloorPlan",
            targets: ["FloorPlan"]
        )
    ],
    targets: [
        .executableTarget(
            name: "FloorPlan",
            path: ".",
            sources: [
                "FloorPlanApp.swift",
                "ContentView.swift",
                "Models/Wall.swift",
                "Models/FloorPlan.swift",
                "Views/FloorPlanCanvasView.swift",
                "Views/ElevationView.swift",
                "Views/SettingsPanel.swift"
            ]
        )
    ]
)
