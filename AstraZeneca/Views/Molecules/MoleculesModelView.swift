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
            parentEntity.scale = [0.4, 0.4, 0.4]
            let rotationEntity = Entity()
            rotationEntity.name = "RotationContainer"
            parentEntity.addChild(rotationEntity)
            content.add(parentEntity)
            
            // Store references for the .task closure
            self.parentEntity = parentEntity
            self.rotationEntity = rotationEntity
            
            self.parentEntity?.components.set(RotationComponent())
            
        } update: { content in

        }
        .installGestures()
        .task {
            Logger.debug("View .task: Triggering viewModel.loadModel()")
            await viewModel.loadModel() // Wait for loading to finish

            // --- NEW: Add model to scene after loading ---
            if viewModel.isModelLoaded {
                Logger.debug("View .task: Model is loaded. Attempting to add to scene.")

                // 1. Get the loaded model root from the ViewModel
                guard let loadedModelRoot = viewModel.rootEntity else {
                    Logger.error("View .task: Model loaded but viewModel.rootEntity is nil!")
                    return
                }

                // 2. Get the rotation entity created in 'make' (stored in @State)
                guard let targetRotationEntity = self.rotationEntity else {
                    // This might happen if .task runs before 'make' completes, though unlikely.
                    // Or if self.rotationEntity wasn't assigned correctly.
                    Logger.error("View .task: self.rotationEntity is nil. Cannot add model.")
                    return
                }

                // 3. Check if rotationEntity is actually in the scene (important!)
                //    Adding a child to an entity not yet in a scene can sometimes cause issues.
                //    The 'make' closure adds parentEntity (which contains rotationEntity) to 'content'.
                //    By the time loadModel finishes, rotationEntity should be in the scene.
                guard targetRotationEntity.scene != nil else {
                     Logger.error("View .task: self.rotationEntity exists but is not yet part of a scene.")
                     return
                }

                // 4. Check if the gesture target is ready in the ViewModel
                guard viewModel.gestureTargetEntity != nil else {
                    Logger.error("View .task: Model loaded but viewModel.gestureTargetEntity is nil!")
                    // Decide how to handle this - maybe proceed without gesture? Or log and return?
                    return
                }
                
                // 5. Add the loaded model to the rotation entity IF it's not already there
                //    (This check prevents adding it multiple times if the task were to re-run)
                if !targetRotationEntity.children.contains(where: { $0 === loadedModelRoot }) {
                    Logger.debug("View .task: Adding loadedModelRoot (ID: \(loadedModelRoot.id)) to rotationEntity (ID: \(targetRotationEntity.id)).")
                    targetRotationEntity.addChild(loadedModelRoot)

                    // Optional: Verify addition
                    let added = targetRotationEntity.children.contains(where: { $0 === loadedModelRoot })
                    Logger.debug("View .task: Model added successfully? \(added)")

                    // 6. Trigger initial state/animations now that the model is in the scene
                    Logger.debug("View .task: Triggering initial updateDisplayModeState.")
                    
                    await updateDisplayModeState()

                } else {
                    Logger.debug("View .task: Model root was already a child of rotationEntity.")
                }
            } else {
                Logger.error("View .task: viewModel.loadModel() completed but isModelLoaded is false.")
            }
        }
        .onChange(of: viewModel.displayMode) { oldValue, newValue in
            Logger.debug("Display mode changed. Triggering async updateDisplayModeState.")
            Task {
                 await updateDisplayModeState()
             }
        }
        .onAppear {
            Logger.debug("MoleculesModelView appeared.")
            // If model is already loaded but view is appearing again, ensure state is correct.
            if viewModel.isModelLoaded {
                Task {
                    applyModelStateSynchronously()
                }
            }
        }
        .onDisappear {
            Logger.debug("MoleculesModelView disappeared. Resetting isShowingMolecules flag.")
            // Reset the flag in AppModel when this specific window closes
            appModel.isShowingMolecules = false
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

