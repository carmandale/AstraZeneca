//
//  AppModel.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/9/25.
//

import SwiftUI
import Foundation

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    // MARK: - Video Player State
    
    /// The presentation modes for the app's UI
    enum Presentation {
        /// Normal app UI with tabs
        case normal
        /// Full-window video player
        case fullWindow
    }
    
    /// Current presentation mode of the app
    var presentation: Presentation = .normal
    
    /// URL of the current video to play
    private(set) var currentVideoURL: URL? = nil
    
    /// Video title for display
    let videoTitle = "AstraZeneca Corporate Video"
    
    /// Video description for display
    let videoDescription = "Learn more about AstraZeneca's mission, values, and commitment to advancing healthcare."
    
    // MARK: - Molecules Window State
    
    /// Whether the volumetric molecules window is currently showing
    var isShowingMolecules: Bool = false
    
    init() {
        print("Initializing AppModel...")
        // Load the video at startup so it's always available
        if let url = Bundle.main.url(forResource: "AZ_owl", withExtension: "mov") {
            currentVideoURL = url
            print("currentVideoURL = \(url)")
        } else {
            print("Error: Could not find AZ_owl.mov in bundle.")
        }
    }

    /// Prepares and shows the video player.
    /// This is the main entry point for playing the video from any view.
    func playVideo(playerModel: PlayerModel) {
        guard let url = currentVideoURL else {
            print("Error: No video URL available to play")
            return
        }
        
        // Load the video into the player
        playerModel.loadVideo(url: url, presentation: .fullWindow)
        
        // Switch to full-window presentation mode
        presentation = .fullWindow
        
        // Start playback
        playerModel.play()
        
        print("Video playback started with URL: \(url)")
    }

    /// Hides the video player and resets the presentation
    func stopVideo() {
        // Reset to normal presentation
        presentation = .normal
    }
}
