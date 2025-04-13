//
//  ExecutiveMeetingView.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/10/25.
//

import SwiftUI

// Slide 1: Executive Meeting View
struct ExecutiveMeetingView: View {
    // Access to models
    @Environment(AppModel.self) private var appModel
    @Environment(PlayerModel.self) private var playerModel

    // Function to play the welcome video using the unified method
    private func playWelcomeVideo() {
        appModel.playVideo(playerModel: playerModel)
    }
    
    var body: some View {
        // Main Content - Two Columns HStack becomes the root element.
        HStack(alignment: .top, spacing: 20) { 
            // Left Column: Logo and Text
            VStack(alignment: .leading, spacing: 15) { // Align content left
                Image("AZ-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80) // Adjusted height slightly
                    .padding(.bottom, 20)
                
                Group {
                    Text("Welcome to the AstraZeneca\nSenior Executive Meeting\nwith Oncology Experts")
                        .font(.extraLargeTitle2) // Adjusted font size
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                        .lineLimit(nil) // Use as many lines as needed
                        .padding(.bottom, 10)
                    
                    Text("No recordings, screenshots or photos are permitted for any part of the meeting")
                        .font(.caption) // Adjusted font size
                        .foregroundColor(.gray)
                    
                    Text("AstraZeneca may not necessarily agree with the views and opinions expressed by the participating physicians and does not recommend any treatment or course of action.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                        .lineLimit(nil) // Use as many lines as needed
                        .padding(.vertical, 5)
                        .padding(.trailing, 10)
                    
                    Text("Some presentations may contain data on products and/or uses that are not approved for or currently under investigation and/or development. AstraZeneca pipeline products are investigational products and as such, are not approved by the FDA & Drug Administration, the European Medicines Agency or any other regulatory agency for the uses under investigation. Information regarding these investigational products should under no circumstances be regarded as a recommendation for their use.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                        .lineLimit(nil) // Use as many lines as needed
                        .padding(.vertical, 5)
                        .padding(.trailing, 10)
                }
                
                // Add the video player button here
                Button(action: playWelcomeVideo) {
                    Label("Play Welcome Video", systemImage: "play.circle")
                }
                .padding(.top, 10) // Add some spacing
                
                Spacer() // Pushes content to the top and bottom items to the bottom
                
                // Bottom items moved outside the Group and after Spacer to align at bottom
                HStack {
                    Text("VV/HQ/24-03300")
                        .font(.caption)
                        .padding(5)
                        .background(Color.yellow)
                        .foregroundColor(.black) // Ensure text is visible on yellow
                    
                    Spacer() // Pushes the yellow box to the left
                }
                
                Text("Date of preparation: April 2025. The meeting has been initiated, organized and funded by AstraZeneca")
                    .font(.system(size: 9)) // Using a custom size smaller than caption2
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 20)
            
            // Right Column: Image
            UIPortalView()
        }
        // Apply modifiers directly to the main HStack
        .navigationTitle("Executive Meeting Welcome")
        .navigationBarTitleDisplayMode(.inline)
        
        .padding(60) // Add padding around the entire HStack

        .ornament(attachmentAnchor: .scene(.bottom)) {
            NavigationLink {
                ASCOPresenceView()
            } label: {
                Label("Continue", systemImage: "chevron.right")
            }
            .labelStyle(.titleAndIcon)
            .glassBackgroundEffect() // Apply glass effect to the ornament content
        }
    }
}

//#Preview(windowStyle: .automatic) {
//    NavigationView { // Wrap in NavigationView for preview title visibility
//        ExecutiveMeetingView()
//            // Correct syntax for environment object injection
//            .environment(AppModel())
//    }
//}
