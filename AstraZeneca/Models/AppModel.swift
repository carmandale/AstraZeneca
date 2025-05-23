//
//  AppModel.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/9/25.
//

import SwiftUI
import Foundation
import AVFoundation

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
    /// Pre-prepared player item for faster loading
    private var preparedPlayerItem: AVPlayerItem? = nil
    
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
            // Create AVPlayerItem here for pre-loading
            preparedPlayerItem = AVPlayerItem(url: url)
            print("currentVideoURL = \(url)")
            print("AVPlayerItem prepared.")
        } else {
            print("Error: Could not find AZ_owl.mov in bundle.")
        }
    }

    /// Prepares and shows the video player using the preloaded item.
    func playVideo(playerModel: PlayerModel) {
        // Use the prepared item instead of the URL
        guard let item = preparedPlayerItem else {
            print("Error: No prepared player item available")
            return
        }
        
        // Tell PlayerModel to load using the item
        playerModel.loadPreparedItem(item: item, presentation: .fullWindow)
        
        // Switch to full-window presentation mode
        presentation = .fullWindow
        
        // Start playback
        playerModel.play()
        
        print("Video playback initiated with prepared item.")
    }

    /// Hides the video player and resets the presentation
    func stopVideo() {
        // Reset to normal presentation asynchronously to avoid update cycle conflicts
        DispatchQueue.main.async {
            self.presentation = .normal
            print("Presentation reset to normal.")
        }
        // Consider if playerModel.reset() needs to be called here or is handled by the player view dismissal
    }
}
