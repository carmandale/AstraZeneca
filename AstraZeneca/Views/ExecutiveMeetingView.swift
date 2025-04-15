//
//  ExecutiveMeetingView.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

// Slide 1: Executive Meeting View
struct ExecutiveMeetingView: View {
    // Access to models
    @Environment(AppModel.self) private var appModel
    @Environment(PlayerModel.self) private var playerModel

    // State for animation sequence
    @State private var showProgressView = true // Start with ProgressView
    @State private var logoEntity: Entity? = nil // Reference to loaded logo
    @State private var showLogoLayer = true // New state to control layer visibility
    @State private var isReady = false // Existing state for main content

    // Function to play the welcome video using the unified method
    private func playWelcomeVideo() {
        appModel.playVideo(playerModel: playerModel)
    }
    
    var body: some View {
        ZStack { // Root ZStack

            // Conditionally display main content view
            if isReady {
                mainContentView
            }

            // Conditionally display logo animation layer
            if showLogoLayer {
                logoAnimationLayer
            }

        } // End Root ZStack
        .ornament(attachmentAnchor: .scene(.bottom)) {
             if isReady {
                ornamentContentView // Use computed property for ornament
             }
        }
        .onAppear {
             // Task logic remains the same
             Task { 
                 Logger.debug("onAppear Task: Starting logo sequence.")
                 while self.logoEntity == nil { /* wait */ 
                    guard !Task.isCancelled else { return }
                    try? await Task.sleep(for: .milliseconds(100))
                 }
                 guard let targetLogoEntity = self.logoEntity else { /* error */ 
                     await MainActor.run { self.showProgressView = false; self.showLogoLayer = false; self.isReady = true }; return 
                 }
                 await MainActor.run { self.showProgressView = false }
                 await targetLogoEntity.fadeOpacity(to: 1.0, duration: 0.75) // Fade In
                 try? await Task.sleep(for: .seconds(2.5)) // Pause Visible (Increased)
                 await targetLogoEntity.fadeOpacity(to: 0.0, duration: 0.75) // Fade Out
                 Logger.debug("Logo faded out (await finished).")
                 let pauseAfterFadeOut: TimeInterval = 0.8
                 Logger.debug("Pausing for \(pauseAfterFadeOut)s after fade await...")
                 try? await Task.sleep(for: .seconds(pauseAfterFadeOut)) // Increased pause duration
                 await MainActor.run { self.showLogoLayer = false }
                 Logger.debug("Logo layer hidden.")
                 await MainActor.run { self.isReady = true } // Show main content
                 Logger.debug("onAppear Task: Sequence complete.")
            }
        }
    }
    
    // MARK: - Computed View Properties
    
    /// Main content view (HStack with text and portal)
    private var mainContentView: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left Column
            VStack(alignment: .leading, spacing: 15) {
                Image("AZ-logo") // This is the 2D logo, part of main content
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80) 
                    .padding(.bottom, 20)
                
                Group {
                    Text("Welcome to the AstraZeneca\nSenior Executive Meeting\nwith Oncology Experts")
                        .font(.extraLargeTitle2) 
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true) 
                        .lineLimit(nil) 
                        .padding(.bottom, 10)
                    
                    Text("No recordings, screenshots or photos are permitted for any part of the meeting")
                        .font(.caption) 
                        .foregroundColor(.gray)
                    
                    Text("AstraZeneca may not necessarily agree with the views and opinions expressed by the participating physicians and does not recommend any treatment or course of action.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true) 
                        .lineLimit(nil) 
                        .padding(.vertical, 5)
                        .padding(.trailing, 10)
                    
                    Text("Some presentations may contain data on products and/or uses that are not approved for or currently under investigation and/or development. AstraZeneca pipeline products are investigational products and as such, are not approved by the FDA & Drug Administration, the European Medicines Agency or any other regulatory agency for the uses under investigation. Information regarding these investigational products should under no circumstances be regarded as a recommendation for their use.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true) 
                        .lineLimit(nil) 
                        .padding(.vertical, 5)
                        .padding(.trailing, 10)
                }
                
                Button(action: playWelcomeVideo) {
                    Label("Play Welcome Video", systemImage: "play.circle")
                }
                .font(.body)
                .fontWeight(.bold)
                .padding(10)
                .glassBackgroundEffect()
                .buttonStyle(ScaleOnPressButtonStyle())
                .hoverEffect { effect, isActive, proxy in
                    effect
                        .animation(.spring()) {
                            $0.scaleEffect(isActive ? 1.05 : 1.0)
                        }
                }
                .padding(.top, 10)
                
                Spacer() 
                
                HStack {
                    Text("VV/HQ/24-03300")
                        .font(.caption)
                        .padding(5)
                        .background(Color.yellow)
                        .foregroundColor(.black) 
                    
                    Spacer() 
                }
                
                Text("Date of preparation: April 2025. The meeting has been initiated, organized and funded by AstraZeneca")
                    .font(.system(size: 9)) 
                    .foregroundColor(.gray)

            }
            .frame(width: 650) // Keep frame width if needed
            
            Spacer()
            
            // Right Column: Image
            UIPortalView()
        }
        .padding(70) // Padding like backup
        
        .opacity(isReady ? 1 : 0) // Control fade-in of main content
        .animation(.easeInOut(duration: 0.75), value: isReady) // Animation for main content fade
        .navigationTitle("Executive Meeting Welcome")
        .navigationBarTitleDisplayMode(.inline)
        .transition(.opacity.animation(.easeInOut(duration: 0.75))) // Fade in the whole block
    }
    
    /// Logo animation layer (ZStack with RealityView and ProgressView)
    private var logoAnimationLayer: some View {
        ZStack {
            RealityView { content in
                do {
                    Logger.debug("RealityView make: Loading logo_scene.usda")
                    let loadedEntity = try await Entity(named: "Assets/logo/logo_scene", in: realityKitContentBundle)
                    loadedEntity.name = "RotatingLogo"

                    // Apply rotation
                    loadedEntity.components.set(RotationComponent())
                    Logger.debug("RealityView make: Added RotationComponent")

                    // Start invisible
                    loadedEntity.components.set(OpacityComponent(opacity: 0.0))
                    Logger.debug("RealityView make: Set initial opacity to 0")

                    content.add(loadedEntity)

                    // Store reference for animation control AFTER adding to content
                    await MainActor.run {
                         self.logoEntity = loadedEntity
                         Logger.debug("RealityView make: logoEntity state variable set.")
                    }

                } catch {
                    Logger.error("Failed to load 'logo_scene.usda': \(error)")
                    // Handle error: Skip logo, show main content
                    await MainActor.run {
                        self.showProgressView = false 
                        self.showLogoLayer = false
                        self.isReady = true         
                    }
                }
            } update: { content in
                // No updates needed
            }
            .allowsHitTesting(false) // Should not interfere with interaction
            // Optional: Small offset to ensure it draws visually 'in front' when opaque
            // .offset(z: 5) 

            // ProgressView on top
            if showProgressView {
                ProgressView().controlSize(.large).transition(.opacity)
            }
        }
        .allowsHitTesting(showProgressView || (logoEntity?.components[OpacityComponent.self]?.opacity ?? 0 > 0))
    }
    
    /// Content for the bottom ornament
    private var ornamentContentView: some View {
        NavigationLink {
            ASCOPresenceView()
        } label: {
            Label("Continue", systemImage: "chevron.right")
        }
        .labelStyle(.titleAndIcon)
        .glassBackgroundEffect()
        .transition(.opacity.animation(.easeInOut(duration: 0.75))) // Fade in ornament
    }
}

//#Preview(windowStyle: .automatic) {
//    NavigationView { // Wrap in NavigationView for preview title visibility
//        ExecutiveMeetingView()
//            // Correct syntax for environment object injection
//            .environment(AppModel())
//    }
//}
