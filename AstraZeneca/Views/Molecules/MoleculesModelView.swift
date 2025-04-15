//
//  MoleculesModelView.swift
//  AstraZeneca
//
//  Created on 4/14/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

/// The 3D model view for HER2 and Trastuzumab molecules.
struct MoleculesModelView: View {
    @Environment(MoleculesViewModel.self) private var viewModel
    @Environment(AppModel.self) private var appModel
    
    // State for gestures
    @State private var rotationAngle = Angle(degrees: 0)
    @State private var dragOffset: CGSize = .zero
    @State private var startAngle: Angle? = nil
    @State private var entityToRotate: Entity? // Holds reference to rotationEntity
    @State private var rotationVelocity = SIMD3<Float>(0, 0, 0)
    @State private var isDragging: Bool = false
    @State private var lastUpdateTime: CFTimeInterval = CACurrentMediaTime()
    @State private var timer: Timer?
    
    // State to hold references to RealityKit entities created in make
    @State private var parentEntity: Entity? = nil
    @State private var rotationEntity: Entity? = nil
    
    var body: some View {
        RealityView { content in
            // --- Make Closure: Setup Static Scene --- 
            Logger.debug("RealityView make: Setting up parent/rotation entities.")
            // Create parent and rotation entities
            let parentEntity = Entity()
            parentEntity.name = "ViewRoot"
            parentEntity.scale = [0.2, 0.2, 0.2]
            let rotationEntity = Entity()
            rotationEntity.name = "RotationContainer"
            parentEntity.addChild(rotationEntity)
            content.add(parentEntity)
            
            // Store references for updates
            self.entityToRotate = rotationEntity // Store for gesture
            Logger.debug("RealityView make: Stored references to parent/rotation entities.")
            
            // Model loading is handled by the ViewModel via .task
            
        } update: { content in
            // --- Update Closure --- 
            guard let parentEntityFromContent = content.entities.first,
                  let rotationEntityFromContent = parentEntityFromContent.children.first else {
                // Log if we can't even get the basic structure from content
                Logger.error("RealityView update: Could not find parent or rotation entity FROM CONTENT.")
                return 
            }
            
            // Log IDs for comparison (optional, but useful)
            // Logger.debug("Update: rotationEntity from Content ID: \(rotationEntityFromContent.id), @State rotationEntity ID: \(self.rotationEntity?.id ?? 0)")
            
            // Use the rotation entity obtained from the content for checks and modification
            let currentRotationEntity = rotationEntityFromContent 

            // 1. Ensure Model is in Scene if Loaded
            // Log status before the check
            Logger.debug("Update check: isLoaded=\(viewModel.isModelLoaded), rootEntityExists=\(viewModel.rootEntity != nil)")
            
            if viewModel.isModelLoaded, let modelRoot = viewModel.rootEntity {
                 // Log entering the 'isLoaded' block
                 Logger.debug("Update check: Model IS loaded.")
                 
                 // Check if the model is *not* currently a child of the rotation entity from content
                 let isAlreadyChild = currentRotationEntity.children.contains(where: { $0 === modelRoot })
                 Logger.debug("Update check: Is model already a child? \(isAlreadyChild)")
                 
                 if !isAlreadyChild {
                    Logger.debug("RealityView update: Model loaded but not in scene. Attempting to add to rotationEntity (ID: \(currentRotationEntity.id)).")
                    currentRotationEntity.addChild(modelRoot) // Add to the entity from content
                    
                    // Verify immediately after adding
                    let addedSuccessfully = currentRotationEntity.children.contains(where: { $0 === modelRoot })
                    Logger.debug("RealityView update: Added model. Verification check: \(addedSuccessfully)")
                    
                    if addedSuccessfully {
                         // --- Debug: Inspect Hierarchy After Adding --- 
                         Logger.debug("\n--- Inspecting Hierarchy After Adding to Scene --- (Root: \(modelRoot.name))")
                         inspectEntityHierarchy(modelRoot)
                         Logger.debug("--- End Hierarchy Inspection ---")
                         // --- End Debug ---

                        // Trigger initial animation AFTER adding to scene
                        Task {
                             Logger.debug("RealityView update: Triggering initial updateDisplayModeState after adding model.")
                             await updateDisplayModeState()
                         }
                    } else {
                         Logger.error("RealityView update: FAILED to add modelRoot as child to rotationEntity.")
                    }
                 } else {
                      // Logger.debug("RealityView update: Model already in scene.") // Can be noisy
                 }
            } else {
                 Logger.debug("Update check: Model IS NOT loaded or rootEntity is nil.")
            }
            
            // 2. Apply Rotation (using entity from content) - REMOVED
            // let rotationY = simd_quatf(angle: Float(rotationAngle.radians), axis: [0, 1, 0])
            // currentRotationEntity.transform.rotation = rotationY
            
            // 3. Apply Synchronous State (using entity from content)
            if viewModel.isModelLoaded && currentRotationEntity.children.contains(where: { $0 === viewModel.rootEntity }) {
                 applyModelStateSynchronously()
            }
        }
        .task { 
             Logger.debug("View .task: Triggering viewModel.loadModel()")
             await viewModel.loadModel()
         }
        .onChange(of: rotationAngle) { newValue in
            // Apply rotation to the entityToRotate when the angle changes
            guard let entity = entityToRotate else { return }
            Logger.debug("onChange(rotationAngle): Applying rotation.")
            let rotationY = simd_quatf(angle: Float(newValue.radians), axis: [0, 1, 0])
            entity.transform.rotation = rotationY
         }
        .onChange(of: viewModel.displayMode) { newValue in
            Logger.debug("Display mode changed. Triggering async updateDisplayModeState.")
            Task {
                 await updateDisplayModeState()
             }
        }
        .gesture(
            // Keep DragGesture for rotation - Updates @State rotationAngle
            DragGesture()
                .targetedToEntity(viewModel.gestureTargetEntity ?? Entity())
                .onChanged { value in
                    // Cancel any existing rotation animation
                    timer?.invalidate()
                    timer = nil
                    
                    // Calculate drag delta and time delta
                    let now = CACurrentMediaTime()
                    let timeDelta = Float(now - lastUpdateTime)
                    
                    // Convert drag to rotation
                    let rotationDelta = SIMD2<Double>(Double(value.translation.width - dragOffset.width), 
                                                     Double(value.translation.height - dragOffset.height))
                    dragOffset = value.translation
                    
                    // Apply rotation delta to state (Use Double for Angle math)
                    rotationAngle += Angle(radians: rotationDelta.x * 0.01) 
                    // Limit pitch rotation (x-axis)
                    let limitedPitch = min(max(rotationAngle.radians, -0.5), 0.5)
                    rotationAngle = Angle(radians: limitedPitch) // Convert back to Angle
                    
                    // Update rotation velocity based on delta
                    let deltaTime = max(0.001, now - lastUpdateTime) // Use the 'now' declared earlier
                    rotationVelocity.x = Float(rotationDelta.x / deltaTime) // Convert result to Float for SIMD
                    rotationVelocity.y = Float(rotationDelta.y / deltaTime) // Convert result to Float for SIMD
                    lastUpdateTime = now
                    
                    isDragging = true
                }
                .onEnded { _ in
                    isDragging = false
                    startContinuousRotation() // Momentum
                }
        )
        .gesture(
             // Keep simplified TapGesture 
             TapGesture()
                 .targetedToAnyEntity()
                 .onEnded { value in
                    let hitEntity = value.entity
                    // ... debug inspection ...
                    Task { 
                         await handleTap(on: hitEntity)
                     }
                 }
         )
        .onDisappear {
            // Clean up timer
            timer?.invalidate()
            timer = nil
        }
        .onAppear {
            Logger.debug("MoleculesModelView appeared.")
            // If model is already loaded but view is appearing again, ensure state is correct.
            if viewModel.isModelLoaded {
                Task {
                    await applyModelStateSynchronously()
                }
            }
        }
        .onDisappear {
            Logger.debug("MoleculesModelView disappeared. Resetting isShowingMolecules flag.")
            // Reset the flag in AppModel when this specific window closes
            appModel.isShowingMolecules = false
        }
    }
    
    // Start continuous rotation with momentum
    private func startContinuousRotation() {
        timer?.invalidate()
        
        // Only start if we have meaningful velocity
        let velocityMagnitude = sqrt(
            rotationVelocity.x * rotationVelocity.x +
            rotationVelocity.y * rotationVelocity.y
        )
        
        if velocityMagnitude < 0.0001 {
            return
        }
        
        // Create a timer for smooth animation
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            // Apply friction to gradually reduce velocity
            rotationVelocity *= 0.95
            
            // Apply velocity to rotation angle
            rotationAngle += Angle(radians: Double(rotationVelocity.x) * 0.01) // Convert velocity component to Double
            
            // Limit pitch rotation (x-axis)
            let limitedPitch = min(max(rotationAngle.radians, -0.5), 0.5)
            rotationAngle = Angle(radians: limitedPitch) // Convert back to Angle
            
            // Stop when velocity becomes very small
            let currentMagnitude = sqrt(
                rotationVelocity.x * rotationVelocity.x +
                rotationVelocity.y * rotationVelocity.y
            )
            
            if currentMagnitude < 0.0001 {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    // Synchronous state update function - ONLY ensures target entities are enabled
    private func applyModelStateSynchronously() {
        // Ensure entities that should be visible in the current displayMode state are enabled,
        // allowing animations to target them.
        Logger.debug("Applying model state synchronously (Ensuring target entities are enabled based on displayMode)")

        if viewModel.showingHER2 { viewModel.her2Entity?.isEnabled = true }
        if viewModel.showingTrastuzumab { viewModel.trastuzumabEntity?.isEnabled = true }
        if viewModel.showingPertuzumab { viewModel.pertuzumabEntity?.isEnabled = true }
        
        // Opacity is now handled by updateModelState triggered initially and by displayMode change
    }

    // Update model entities based on current DISPLAY MODE state (ANIMATED)
    // Renamed for clarity - this handles display mode changes
    @MainActor
    private func updateDisplayModeState() async {
        Logger.debug("Updating model state for DISPLAY MODE change with animations")

        await withTaskGroup(of: Void.self) { group in
            // --- HER2 ---
            if let her2Entity = viewModel.her2Entity {
                 // Read displayMode property needed inside the tasks beforehand
                 let shouldShow = viewModel.showingHER2
                
                 if shouldShow {
                    // Ensure enabled AND set initial opacity before animating
                    her2Entity.isEnabled = true
                    her2Entity.components.set(OpacityComponent(opacity: 1.0)) // Set immediately
                    Logger.debug("HER2 set to enabled and opacity 1.0 directly.")
                    
                    // Animate Fade In (might do nothing if already 1.0, but safe)
                    group.addTask {
                        Logger.debug("HER2 fade-in animation task starting.")
                        await her2Entity.fadeOpacity(to: 1.0, duration: viewModel.fadeInDuration)
                        Logger.debug("HER2 fade-in animation task finished.")
                    }
                    // Animate Position to ZERO (no exploded view)
                    group.addTask {
                        let targetPosition = SIMD3<Float>.zero // Always animate to center
                        let currentPosition = her2Entity.position
                        let delta = targetPosition - currentPosition
                        // Only animate if not already at target (avoids tiny movements)
                        if length_squared(delta) > 0.00001 {
                             // await her2Entity.animatePosition(to: delta, duration: viewModel.moveDuration, timing: .easeInOut)
                             // Logger.debug("HER2 position animation task starting.") // Re-enable if needed
                             // await her2Entity.animatePosition(to: delta, duration: viewModel.moveDuration, timing: .easeInOut)
                             // Logger.debug("HER2 position animation task finished.") // Re-enable if needed
                        } else {
                            Logger.debug("HER2 already at target position, skipping position animation.")
                        }
                    }
                } else {
                    // Animate Fade Out (No disabling afterwards)
                     group.addTask {
                        Logger.debug("HER2 fade-out animation task starting.")
                        await her2Entity.fadeOpacity(to: 0.0, duration: viewModel.fadeOutDuration)
                        Logger.debug("HER2 faded out for display mode change.")
                    }
                }
            } else {
                 Logger.debug("updateDisplayModeState: viewModel.her2Entity is nil")
            }

            // --- Trastuzumab ---
            if let trastuzumabEntity = viewModel.trastuzumabEntity {
                 let shouldShow = viewModel.showingTrastuzumab

                 if shouldShow {
                     // Ensure enabled AND set initial opacity before animating
                     trastuzumabEntity.isEnabled = true
                     trastuzumabEntity.components.set(OpacityComponent(opacity: 1.0)) // Set immediately
                     Logger.debug("Trastuzumab set to enabled and opacity 1.0 directly.")

                     group.addTask {
                         Logger.debug("Trastuzumab fade-in animation task starting.")
                         await trastuzumabEntity.fadeOpacity(to: 1.0, duration: viewModel.fadeInDuration)
                         Logger.debug("Trastuzumab fade-in animation task finished.")
                    }
                     // Animate Position to ZERO (no exploded view)
                     group.addTask {
                        let targetPosition = SIMD3<Float>.zero
                        let currentPosition = trastuzumabEntity.position
                        let delta = targetPosition - currentPosition
                         if length_squared(delta) > 0.00001 {
                            // Logger.debug("Trastuzumab position animation task starting.")
                            await trastuzumabEntity.animatePosition(to: delta, duration: viewModel.moveDuration, timing: .easeInOut)
                            // Logger.debug("Trastuzumab position animation task finished.")
                        } else {
                            Logger.debug("Trastuzumab already at target position, skipping position animation.")
                        }
                    }
                 } else {
                     group.addTask {
                         Logger.debug("Trastuzumab fade-out animation task starting.")
                         await trastuzumabEntity.fadeOpacity(to: 0.0, duration: viewModel.fadeOutDuration)
                         Logger.debug("Trastuzumab faded out for display mode change.")
                    }
                }
            } else {
                 Logger.debug("updateDisplayModeState: viewModel.trastuzumabEntity is nil")
            }

            // --- Pertuzumab ---
            if let pertuzumabEntity = viewModel.pertuzumabEntity {
                 let shouldShow = viewModel.showingPertuzumab

                 if shouldShow {
                    // Ensure enabled AND set initial opacity before animating
                    pertuzumabEntity.isEnabled = true
                    pertuzumabEntity.components.set(OpacityComponent(opacity: 1.0)) // Set immediately
                    Logger.debug("Pertuzumab set to enabled and opacity 1.0 directly.")

                    group.addTask {
                         Logger.debug("Pertuzumab fade-in animation task starting.")
                         await pertuzumabEntity.fadeOpacity(to: 1.0, duration: viewModel.fadeInDuration)
                         Logger.debug("Pertuzumab fade-in animation task finished.")
                    }
                    // Animate Position to ZERO (no exploded view)
                    group.addTask {
                        let targetPosition = SIMD3<Float>.zero
                        let currentPosition = pertuzumabEntity.position
                        let delta = targetPosition - currentPosition
                         if length_squared(delta) > 0.00001 {
                            // Logger.debug("Pertuzumab position animation task starting.")
                            await pertuzumabEntity.animatePosition(to: delta, duration: viewModel.moveDuration, timing: .easeInOut)
                            // Logger.debug("Pertuzumab position animation task finished.")
                        } else {
                             Logger.debug("Pertuzumab already at target position, skipping position animation.")
                        }
                     }
                 } else {
                     group.addTask {
                         Logger.debug("Pertuzumab fade-out animation task starting.")
                         await pertuzumabEntity.fadeOpacity(to: 0.0, duration: viewModel.fadeOutDuration)
                         Logger.debug("Pertuzumab faded out for display mode change.")
                    }
                }
            } else {
                 Logger.debug("updateDisplayModeState: viewModel.pertuzumabEntity is nil")
            }
        }
        Logger.debug("Display Mode Animations complete")
    }
    
    // NEW function to handle tap gestures
    @MainActor
    private func handleTap(on hitEntity: Entity) async { 
        // Immediately ignore taps on the dedicated rotation target
        guard hitEntity.name != "gestureTarget" else {
            Logger.debug("Tap gesture hit the 'gestureTarget' entity, ignoring.")
            return
        }

        // Function to find the relevant molecule entity by checking against stored references
        func findTargetMolecule(_ startEntity: Entity) -> Entity? {
            var currentEntity: Entity? = startEntity
            while let entity = currentEntity {
                // Check if the current entity in the hierarchy IS one of the target molecule entities BY NAME
                if entity.name == "HER2" {
                    return entity // Return the entity found in the hierarchy
                }
                if entity.name == "Trastuzumab" {
                    return entity // Return the entity found in the hierarchy
                }
                if entity.name == "Pertuzumab" {
                    return entity // Return the entity found in the hierarchy
                }
                // If no match, move up to the parent
                currentEntity = entity.parent
            }
            return nil // Reached root without finding a match by name
        }
        
        // Find the molecule entity by walking up from the raycast hit
        guard let moleculeEntity = findTargetMolecule(hitEntity) else {
            Logger.debug("Raycast hit '\(hitEntity.name)' but no target molecule (HER2/Trastuzumab/Pertuzumab) found in its hierarchy by reference.")
            return
        }
        
        Logger.debug("Target molecule identified via raycast + hierarchy walk: \(moleculeEntity.name)")
        let moveDistance: Float = 0.125
        let animationDuration: TimeInterval = 0.4 // Adjust as needed
        
        // Use the found moleculeEntity for the animation logic
        switch moleculeEntity.name {
        case "HER2":
            // Ensure we use the identified entity, though viewModel reference might be redundant now
            // Guard let her2 = viewModel.her2Entity else { return }
            let deltaX = viewModel.her2IsMoved ? -moveDistance : moveDistance
            let delta = SIMD3<Float>(deltaX, 0, 0)
            await moleculeEntity.animatePosition(to: delta, duration: animationDuration, timing: .easeInOut)
            viewModel.her2IsMoved.toggle()
            Logger.debug("HER2 moved. IsMoved: \(viewModel.her2IsMoved)")
            
        case "Trastuzumab":
            // Guard let trastuzumab = viewModel.trastuzumabEntity else { return }
            let deltaX = viewModel.trastuzumabIsMoved ? moveDistance : -moveDistance // Moves left initially
            let delta = SIMD3<Float>(deltaX, 0, 0)
            await moleculeEntity.animatePosition(to: delta, duration: animationDuration, timing: .easeInOut)
            viewModel.trastuzumabIsMoved.toggle()
             Logger.debug("Trastuzumab moved. IsMoved: \(viewModel.trastuzumabIsMoved)")

        case "Pertuzumab":
            // Guard let pertuzumab = viewModel.pertuzumabEntity else { return }
            let deltaX = viewModel.pertuzumabIsMoved ? moveDistance : -moveDistance // Moves left initially
            let delta = SIMD3<Float>(deltaX, 0, 0)
            await moleculeEntity.animatePosition(to: delta, duration: animationDuration, timing: .easeInOut)
            viewModel.pertuzumabIsMoved.toggle()
             Logger.debug("Pertuzumab moved. IsMoved: \(viewModel.pertuzumabIsMoved)")

        default:
            // This case should technically not be reached due to the findTargetMolecule guard
            Logger.error("Reached default case in handleTap unexpectedly for entity: \(moleculeEntity.name)")
            break
        }
    }
    
    // Debug utility to inspect entity hierarchies (from user)
    private func inspectEntityHierarchy(_ entity: Entity, level: Int = 0, showComponents: Bool = true) {
        let indent = String(repeating: "  ", count: level)
        // Use Logger instead of print for consistency
        Logger.debug("\(indent)Entity: \(entity.name) (ID: \(entity.id))") 
        if showComponents {
            // Map component types to strings for logging
            let componentTypes = entity.components.map { String(describing: type(of: $0)) }.joined(separator: ", ")
            Logger.debug("\(indent)Components: [\(componentTypes)]")
        }
        
        for child in entity.children {
            inspectEntityHierarchy(child, level: level + 1, showComponents: showComponents)
        }
    }
}

