# Floor Plan Designer

A native macOS application for creating architectural floor plans with precise measurements and elevation views.

## Features

### Floor Plan View
- **Interactive Drawing**: Click and drag to draw walls on a grid-based canvas
- **Snap to Grid**: Automatically snaps to 12-inch (1-foot) grid for precise alignment
- **Real-time Measurements**: See wall dimensions as you draw
- **Scale Support**: Configurable scale (pixels per inch) for accurate representations
- **Unit Support**: Switch between Imperial (feet/inches) and Metric (meters/centimeters)

### Elevation Views
- **Four Directions**: Automatic generation of North, South, East, and West elevations
- **Wall Heights**: Configurable wall heights (default 8 feet)
- **Visual Representation**: Simple elevation drawings showing wall positions and heights

### Settings & Controls
- **Floor Plan Naming**: Name your floor plans for easy organization
- **Scale Adjustment**: Zoom in/out to adjust working scale
- **Statistics**: View total number of walls and cumulative length
- **Save/Load**: Export and import floor plans as JSON files

## Building the Project

### Requirements
- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Using Swift Package Manager

```bash
# Build the project
swift build

# Run the application
swift run
```

### Using Xcode

1. Open the project folder in Xcode
2. Select the FloorPlan scheme
3. Build and run (⌘R)

## Usage

### Drawing Walls
1. Click once to set the starting point of a wall
2. Drag to the ending point
3. Release to create the wall
4. Walls automatically snap to the grid for alignment

### Viewing Elevations
1. Switch to the "Elevations" tab using the segmented control
2. View all four elevation directions simultaneously
3. Walls perpendicular to each viewing direction are shown

### Saving and Loading
- **Save**: Click "Save" in the toolbar to export your floor plan as JSON
- **Load**: Click "Load" to import a previously saved floor plan

### Adjusting Settings
Use the left sidebar to:
- Change floor plan name
- Switch between Imperial and Metric units
- Adjust scale/zoom level
- View statistics
- Clear all walls

## Architecture

```
FloorPlan/
├── FloorPlanApp.swift          # App entry point
├── ContentView.swift           # Main view coordinator
├── Models/
│   ├── Wall.swift             # Wall data model
│   └── FloorPlan.swift        # Floor plan data model
└── Views/
    ├── FloorPlanCanvasView.swift  # 2D drawing canvas
    ├── ElevationView.swift        # Elevation view renderer
    └── SettingsPanel.swift        # Settings sidebar
```

## Data Model

### Wall
- Start and end points (CGPoint)
- Thickness (default 6 inches)
- Height (default 96 inches / 8 feet)
- Calculated length and angle

### Floor Plan
- Collection of walls
- Scale (pixels per inch)
- Measurement unit (Imperial/Metric)
- Name and metadata

## Future Enhancements

Potential features for future development:
- Door and window placement
- Room labeling and area calculation
- Multiple floor support
- 3D preview (basic wireframe)
- PDF export of plans and elevations
- Dimension lines and annotations
- Wall material/finish properties
- Furniture placement
- Print layouts

## License

All rights reserved
