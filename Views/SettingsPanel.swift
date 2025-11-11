import SwiftUI

/// Settings panel for configuring floor plan scale and units
struct SettingsPanel: View {
    @ObservedObject var floorPlan: FloorPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)

            Divider()

            // Floor plan name
            VStack(alignment: .leading, spacing: 4) {
                Text("Floor Plan Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Name", text: $floorPlan.name)
                    .textFieldStyle(.roundedBorder)
            }

            Divider()

            // Measurement unit
            VStack(alignment: .leading, spacing: 8) {
                Text("Measurement Unit")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("Unit", selection: $floorPlan.unit) {
                    ForEach(FloorPlan.MeasurementUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.radioGroup)
            }

            Divider()

            // Scale
            VStack(alignment: .leading, spacing: 8) {
                Text("Scale")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Zoom:")
                    Slider(value: $floorPlan.scale, in: 1...10, step: 0.5)
                    Text(String(format: "%.1f px/in", floorPlan.scale))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Statistics
            VStack(alignment: .leading, spacing: 8) {
                Text("Statistics")
                    .font(.caption)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Total Walls:")
                        Spacer()
                        Text("\(floorPlan.walls.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Length:")
                        Spacer()
                        Text(totalLength)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.caption)
            }

            Spacer()

            // Actions
            VStack(spacing: 8) {
                Button(action: {
                    floorPlan.clearAll()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All Walls")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .frame(width: 250)
    }

    private var totalLength: String {
        let total = floorPlan.walls.reduce(0) { $0 + $1.length }
        return floorPlan.formatMeasurement(total)
    }
}
