//
//  MoleculesViewModel.swift
//  AstraZeneca
//
//  Created on 4/14/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

/// Manages state for the molecule models
@Observable
class MoleculesViewModel {
    /// Current display mode for the molecules
    var displayMode: ModelDisplayMode = .her2Only
    
    /// References to model entities for programmatic control
    var rootEntity: Entity?
    var her2Entity: Entity?
    var trastuzumabEntity: Entity?
    var pertuzumabEntity: Entity?
    var gestureTargetEntity: Entity?
    
    /// Animation constants
    let fadeInDuration: TimeInterval = 0.5
    let fadeOutDuration: TimeInterval = 0.3
    let moveDuration: TimeInterval = 0.75
    
    /// Helper computed properties
    var showingHER2: Bool {
        displayMode == .her2Only || displayMode == .combined
    }
    
    var showingTrastuzumab: Bool {
        displayMode == .trastuzumabOnly || displayMode == .combined
    }
    
    var showingPertuzumab: Bool {
        displayMode == .pertuzumabOnly || displayMode == .combined
    }
    
    /// Flag to track if the model has been loaded
    var isModelLoaded = false
    
    // State for tap animations
    var her2IsMoved = false
    var trastuzumabIsMoved = false
    var pertuzumabIsMoved = false
    
    @MainActor // Ensure updates to Published properties happen on main actor
    func loadModel() async {
        // Prevent reloading if already loaded
        guard !isModelLoaded else {
            Logger.debug("Model already loaded.")
            return
        }
        
        Logger.debug("ViewModel attempting to load model...")
        do {
            // Load the entity directly, it returns non-optional Entity or throws
            let loadedRootEntity = try await Entity(named: "Assets/Molecules/HER2Model", in: realityKitContentBundle)
            
            // If loading succeeds, proceed:
            Logger.debug("ViewModel: Loaded HER2Model Complete")
            self.rootEntity = loadedRootEntity // Store the loaded entity

            // Find references to HER2, Trastuzumab and Pertuzumab entities
            if let her2 = loadedRootEntity.findEntity(named: "HER2") {
                Logger.debug("ViewModel: Found HER2 Entity")
                self.her2Entity = her2
            } else { Logger.debug("ViewModel: Could not find 'HER2' entity in loaded model.") }

            if let trastuzumab = loadedRootEntity.findEntity(named: "Trastuzumab") {
                Logger.debug("ViewModel: Found Trastuzumab Entity")
                self.trastuzumabEntity = trastuzumab
            } else { Logger.debug("ViewModel: Could not find 'Trastuzumab' entity in loaded model.") }

            if let pertuzumab = loadedRootEntity.findEntity(named: "Pertuzumab") {
                Logger.debug("ViewModel: Found Pertuzumab Entity")
                self.pertuzumabEntity = pertuzumab
            } else { Logger.debug("ViewModel: Could not find 'Pertuzumab' entity in loaded model.") }

            // Set initial opacity to 0 for all molecules using the extension
            Logger.debug("ViewModel: Setting initial opacities to 0.0")
            self.her2Entity?.opacity = 0.0
            self.trastuzumabEntity?.opacity = 0.0
            self.pertuzumabEntity?.opacity = 0.0
            
            // --- Find Gesture Target for Rotation ---
            if let target = loadedRootEntity.findEntity(named: "gestureTarget") {
                self.gestureTargetEntity = target
                Logger.debug("ViewModel: Found and assigned gestureTarget entity.")
            } else {
                Logger.error("ViewModel: Could not find entity named 'gestureTarget' within CompleteStructure.")
            }

            // Mark the model as loaded - this will trigger RealityView.update
            Logger.debug("ViewModel: Model Loaded successfully.")
            self.isModelLoaded = true
            // Note: Initial animation trigger will now need to happen in RealityView.update

        } catch {
             Logger.error("ViewModel: Error loading HER2Model: \(error)")
             // Optionally set an error state here
        }
    }
}

/// The different display modes for the molecular model
enum ModelDisplayMode {
    case her2Only
    case trastuzumabOnly 
    case pertuzumabOnly
    case combined
    case exploded
}
