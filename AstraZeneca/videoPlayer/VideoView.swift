//
//  VideoView.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/13/25.
//

import SwiftUI

// Video view that shows details and a play button, following DestinationVideo pattern
struct VideoView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(PlayerModel.self) private var playerModel
    
    // State for showing loading indicator
    @State private var isLoadingVideo = false
    // State for title animation
    @State private var animateTitle: Bool = false
    
    // Define the depth for the title animation
    let titleDepth: CGFloat = 60
    
    // Function to play the video using the unified method
    private func playVideo() {
        guard !isLoadingVideo else { return } // Prevent double taps
        
        isLoadingVideo = true // Show loading indicator
        print("Play button tapped, showing loading indicator.")
        
        // Use the pre-loading method in AppModel
        appModel.playVideo(playerModel: playerModel)
        
        // Note: isLoadingVideo doesn't need to be manually reset to false here,
        // because this whole VideoView will likely be removed from the hierarchy
        // when the presentation changes to .fullWindow, automatically cleaning up the state.
    }
    
    var body: some View {
        ZStack { // Root ZStack for layering

            // Background Image - Should fill naturally in visionOS
            Image("jose-collage-bg")
                .resizable()
                .scaledToFill() 
            
            // Remove Title Image from here
            
//            Spacer() // Spacer BEFORE VStack for vertical centering

            // Original content VStack (Title + Text + Button)
            VStack(alignment: .leading, spacing: 30) {
                // Title Image *inside* the VStack
                Spacer()
                Image("jose-collage-title")
                    .resizable()
                    .scaledToFit() // Use scaledToFit
                    // Apply animated offset
                    .offset(z: animateTitle ? titleDepth : 0)

                Text("Discover José Baselga's transformative impact on precision medicine and cancer care, inspiring medical innovation and shaping AstraZeneca's commitment to healthcare excellence.")
                    .font(.body)
                    .multilineTextAlignment(.leading) // Changed paragraph alignment to .leading
                    // Make text white or a light color for contrast
                    .foregroundStyle(.white.opacity(0.9)) 
                    .padding(.bottom, 30) 
                
                // Centered play button area with loading indicator
                HStack {
                    Spacer()
                    
                    // Use a Button for proper interaction handling
                    Button(action: playVideo) {
                        // ZStack remains the button's label
                        ZStack {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100) 
                                .foregroundColor(.white.opacity(isLoadingVideo ? 0.4 : 0.85)) // Dim button when loading
                            
                            if isLoadingVideo {
                                ProgressView()
                                    .controlSize(.large) 
                                    .tint(.white) 
                            }
                        }
                    }
                    // Use original press-only style
                    .buttonStyle(ScaleOnPressButtonStyle())
                    .contentShape(.circle) // Keep circular shape
                    // Apply visionOS custom hover effect with correct syntax
                    .hoverEffect { effect, isActive, proxy in 
                        // Apply animation *around* the scale effect
                        effect
                            .animation(.spring()) { // << REMOVED value: isActive
                                $0.scaleEffect(isActive ? 1.1 : 1.0) // << Scale effect inside closure
                            }
                    }
                    .disabled(isLoadingVideo) // Keep disabled state
                    
                    Spacer()
                }
                Spacer() // << Added Spacer back inside VStack
                // Button remains centered due to HStack spacers
            }
            .frame(width: 550, height: 700)
            .offset(z: 20)
            // Apply positioning padding to the VStack
            .padding(.leading, 340) 
            .padding(.trailing, 40) 
            // Trigger animation when the VStack appears
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    animateTitle = true
                }
            }

//            Spacer() // Spacer AFTER VStack for vertical centering

        }
        // Keep navigation title outside the ZStack
        .navigationTitle("José Baselga: Cancer's Fiercest Opponent") 
    }
}

// Reverted ButtonStyle for scale effect on PRESS ONLY
struct ScaleOnPressButtonStyle: ButtonStyle {
    // REMOVE @Binding var isHovering: Bool

    func makeBody(configuration: Configuration) -> some View {
        // Logic depends only on configuration.isPressed
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0) // Scale down when pressed
            .animation(.snappy, value: configuration.isPressed) // Animate press only
    }
}

#Preview {
    // Provide mock or default instances for environment objects
    VideoView()
        .environment(AppModel()) // Assuming AppModel has a default initializer
        .environment(PlayerModel()) // Assuming PlayerModel has a default initializer
}


