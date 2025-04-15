# Molecules Tab Implementation Plan for visionOS 2

## Overview
This document outlines the plan to implement a new "Molecules" tab in the AstraZeneca visionOS 2 application. The tab will focus on HER2 and Trastuzumab interaction, featuring a 2D information view that transitions to an interactive 3D model viewer.

## Current Application Structure
- The app uses a `TabView` structure in `ContentView.swift` with 4 existing tabs
- Current tabs: Welcome, ASCO Presence, ADC Portfolio, and Watch Video

## Implementation Requirements
Based on the PRD documents and the reference project, we need to:
1. Create a new tab called "Molecules"
2. Display HER2 and Trastuzumab interaction information in a 2D view
3. Provide a transition to an interactive 3D model viewer
4. Follow the UI pattern shown in the "Hello World" example

## Implementation Steps

### 1. Create the Basic Molecules View

```swift
// MoleculesView.swift
import SwiftUI
import RealityKit

@Observable
class MoleculesViewModel {
    // Model state for the molecules view
    var isShowingModel: Bool = false
    
    // References to model entities for programmatic control
    var her2Entity: Entity?
    var trastuzumabEntity: Entity?
    var interactionPoints: [Entity] = []
    
    // Current display mode
    var displayMode: ModelDisplayMode = .combined
    
    // Helper computed properties
    var showingHER2: Bool {
        displayMode == .her2Only || displayMode == .combined || displayMode == .exploded
    }
    
    var showingTrastuzumab: Bool {
        displayMode == .trastuzumabOnly || displayMode == .combined || displayMode == .exploded
    }
    
    var isExplodedView: Bool {
        displayMode == .exploded
    }
}

enum ModelDisplayMode {
    case her2Only
    case trastuzumabOnly 
    case combined
    case exploded
}

struct MoleculesView: View {
    @State private var viewModel = MoleculesViewModel()
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack {
            // Header with back button (similar to reference project)
            HStack {
                Button(action: {
                    // Go back to main info if showing model
                    if viewModel.isShowingModel {
                        viewModel.isShowingModel = false
                    }
                }) {
                    Image(systemName: "chevron.left")
                    Text("A Day in the Life")
                }
                .opacity(viewModel.isShowingModel ? 1 : 0)
                
                Spacer()
            }
            .padding()
            
            if !viewModel.isShowingModel {
                // 2D Information View
                MoleculesInfoView(viewModel: viewModel)
            } else {
                // 3D Model View
                MoleculesModelView(viewModel: viewModel)
            }
        }
    }
}
```

### 2. Create the 2D Information View

```swift
// Part of MoleculesView.swift
struct MoleculesInfoView: View {
    var viewModel: MoleculesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("HER2 and Trastuzumab Interaction")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You can't see it, but the HER2 protein and Trastuzumab antibody work together to play a crucial role in breast cancer treatment. HER2-positive breast cancer is characterized by the overexpression of HER2 receptors on cancer cells.")
                .font(.title3)
            
            Text("HER2 (Human Epidermal growth factor Receptor 2) is a protein that promotes the growth of cancer cells. In some breast cancers, the HER2 gene makes too many copies of itself, and too many HER2 receptors are made. This is called HER2-positive breast cancer.")
                .padding(.vertical)
            
            Text("Trastuzumab (Herceptin) is a monoclonal antibody that attaches to HER2 receptors on the surface of breast cancer cells. This blocks the receptors, preventing them from receiving growth signals and slowing the growth and spread of the cancer.")
            
            Link("AstraZeneca Oncology", destination: URL(string: "https://www.astrazeneca.com/our-therapy-areas/oncology.html")!)
                .font(.headline)
                .padding(.top)
            
            Spacer()
            
            Button("View Model") {
                viewModel.isShowingModel = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

### 3. Create the 3D Model Viewer with Programmatic Control

```swift
// Part of MoleculesView.swift
struct MoleculesModelView: View {
    @ObservedObject var viewModel: MoleculesViewModel
    @State private var rotationAngle: Float = 0.0
    
    var body: some View {
        VStack {
            // 3D Model RealityView
            RealityView { content in
                // Load the combined model (with references)
                let modelEntity = try? await Entity.load(named: "HER2TrastuzumabCombined")
                
                if let modelEntity = modelEntity {
                    content.add(modelEntity)
                    
                    // Store references to sub-entities for later manipulation
                    if let her2 = modelEntity.findEntity(named: "HER2Protein") {
                        viewModel.her2Entity = her2
                    }
                    if let trastuzumab = modelEntity.findEntity(named: "TrastuzumabAntibody") {
                        viewModel.trastuzumabEntity = trastuzumab
                    }
                    
                    // Find and store interaction points
                    if let interactionPoint = modelEntity.findEntity(named: "InteractionPoint1") {
                        viewModel.interactionPoints.append(interactionPoint)
                        interactionPoint.isEnabled = false // Initially hidden
                    }
                    
                    // Add lighting
                    let lightEntity = Entity()
                    var light = PointLight()
                    light.intensity = 1000
                    light.attenuationRadius = 10
                    lightEntity.components[PointLightComponent.self] = PointLightComponent(light: light)
                    lightEntity.position = SIMD3<Float>(0, 1, 5)
                    content.add(lightEntity)
                }
            } update: { content in
                // Update based on current model state
                updateModelState()
                
                // Update rotation
                if let rootEntity = content.entities.first {
                    // Apply rotation from gestures
                    rootEntity.transform.rotation = simd_quatf(angle: rotationAngle, axis: SIMD3<Float>(0, 1, 0))
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Convert drag to rotation
                        let deltaX = Float(value.translation.width)
                        rotationAngle = deltaX * 0.01
                    }
            )
            
            // Model controls
            HStack(spacing: 20) {
                Button("HER2 Only") {
                    viewModel.displayMode = .her2Only
                    updateModelState()
                }
                .buttonStyle(.bordered)
                
                Button("Trastuzumab Only") {
                    viewModel.displayMode = .trastuzumabOnly
                    updateModelState()
                }
                .buttonStyle(.bordered)
                
                Button("Combined View") {
                    viewModel.displayMode = .combined
                    updateModelState()
                }
                .buttonStyle(.bordered)
                
                Button("Exploded View") {
                    viewModel.displayMode = .exploded
                    updateModelState()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    
    // Update model entities based on current display mode
    private func updateModelState() {
        // Control visibility
        viewModel.her2Entity?.isEnabled = viewModel.showingHER2
        viewModel.trastuzumabEntity?.isEnabled = viewModel.showingTrastuzumab
        
        // Control positioning for exploded view
        if viewModel.isExplodedView {
            viewModel.her2Entity?.position = SIMD3<Float>(-0.8, 0, 0)
            viewModel.trastuzumabEntity?.position = SIMD3<Float>(0.8, 0, 0)
            // Show interaction points
            viewModel.interactionPoints.forEach { $0.isEnabled = true }
        } else {
            // Normal positioning
            viewModel.her2Entity?.position = SIMD3<Float>(-0.3, 0, 0)
            viewModel.trastuzumabEntity?.position = SIMD3<Float>(0.3, 0, 0)
            // Hide interaction points
            viewModel.interactionPoints.forEach { $0.isEnabled = false }
        }
    }
}
```

### 4. Update ContentView.swift

```swift
// Update in ContentView.swift TabView section
TabView(selection: $selection) {
    NavigationStack {
        ExecutiveMeetingView()
    }
    .tag(1)
    .tabItem {
        Label("Welcome", systemImage: "house")
    }

    NavigationStack {
        ASCOPresenceView()
    }
    .tag(2)
    .tabItem {
        Label("ASCO Presence", systemImage: "person.3")
    }

    NavigationStack {
        OncologyPortfolioView()
    }
    .tag(3)
    .tabItem {
        Label("ADC Portfolio", systemImage: "briefcase")
    }
    
    // New Molecules Tab
    NavigationStack {
        MoleculesView()
    }
    .tag(4)
    .tabItem {
        Label("Molecules", systemImage: "atom")
    }
    
    // Video Player Tab - moved to tag 5
    NavigationStack {
        VideoView()
    }
    .tag(5)
    .tabItem {
        Label("Watch Video", systemImage: "play.circle.fill")
    }
}
```

## Technical Considerations

### USDA Scene Files Structure
We will use USDA scene files in the RealityKitContent folder with the following structure:

1. **Individual Model Files**:
   - `HER2Model.usda` - Contains just the HER2 protein 
   - `TrastuzumabModel.usda` - Contains just the Trastuzumab antibody

2. **Combined Reference Model**:
   - `HER2TrastuzumabCombined.usda` - References both individual models and includes interaction points

The combined model references the individual models and allows for programmatic control of visibility and positioning, eliminating the need for separate model files for different views.

### Programmatic Control Advantages
1. **More efficient asset management** - We only need 3 model files instead of 4
2. **Runtime flexibility** - We can animate transitions between states
3. **Dynamic interaction** - Easier to implement highlighting and annotations
4. **Easier to extend** - Can add more states or visual options without new model files

### Model Specifications
- HER2 protein should be colored blue
- Trastuzumab antibody should be colored pink or red
- Each model should be optimized for real-time rendering (< 100,000 polygons)
- Models will be derived from the Protein Data Bank file [PDB ID 1N8Z](https://www.rcsb.org/structure/1N8Z)

### Model Interaction
- Implement pinch gesture for zoom functionality
- Add tap gesture to show annotations when tapping on specific parts
- 360-degree rotation capability using drag gestures

## Next Steps

1. Create the `MoleculesView.swift` file in the Views directory
2. Ensure the placeholder USDA files are properly set up with references
3. Update ContentView.swift to include the new tab
4. Replace placeholder USDA files with detailed molecular models
5. Test the implementation on visionOS 2

## References
- [AstraZeneca Oncology](https://www.astrazeneca.com/our-therapy-areas/oncology.html)
- [RCSB Protein Data Bank](https://www.rcsb.org/)
