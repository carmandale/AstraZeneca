import AVKit
import SwiftUI
import Foundation

/// The presentation modes the player supports.
enum Presentation {
    /// Presents the player as a child of a parent user interface.
    case inline
    /// Presents the player in full-window exclusive mode.
    case fullWindow
}

/// A model object that manages the playback of video.
@MainActor @Observable class PlayerModel {
    /// A Boolean value that indicates whether playback is currently active.
    private(set) var isPlaying = false
    
    /// A Boolean value that indicates whether playback of the current item is complete.
    private(set) var isPlaybackComplete = false
    
    /// The presentation in which to display the current media.
    private(set) var presentation: Presentation = .inline
    
    /// An object that manages the playback of a video's media.
    var player: AVPlayer
    
    /// The currently presented platform-specific video player user interface.
    ///
    /// The life cycle of an `AVPlayerViewController` object is different than a typical view controller. In addition
    /// to displaying the video player UI within your app, the view controller also manages the presentation of the media
    /// outside your app's UI such as when using AirPlay, Picture in Picture, or docked full window. To ensure the view
    /// controller instance is preserved in these cases, the app stores a reference to it here
    /// as an environment-scoped object.
    private var playerUI: AnyObject?
    
    /// An optional delegate object for player functionality
    public var playerUIDelegate: AnyObject?
    
    init() {
        self.player = AVPlayer()
        configureAudioSession()
    }
    
    /// Creates a new player view controller object.
    func makePlayerUI() -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        playerUI = controller
        return controller
    }
    
    /// Loads a video for playback from the specified URL.
    /// - Parameters:
    ///   - url: The URL of the video to load.
    ///   - presentation: The style in which to present the player.
    func loadVideo(url: URL, presentation: Presentation = .inline) {
        isPlaybackComplete = false
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        // Set the presentation, which typically presents the player full window.
        self.presentation = presentation
        
        // Configure audio experience based on presentation mode
        configureAudioExperience(for: presentation)
    }
    
    /// Loads a pre-created AVPlayerItem for playback.
    /// - Parameters:
    ///   - item: The AVPlayerItem to load.
    ///   - presentation: The style in which to present the player.
    func loadPreparedItem(item: AVPlayerItem, presentation: Presentation) {
        isPlaybackComplete = false
        player.replaceCurrentItem(with: item) // Use the provided item
        // Reset player head time to beginning if needed
        player.seek(to: .zero)
        
        self.presentation = presentation
        // Configure audio experience based on presentation mode
        configureAudioExperience(for: presentation)
        print("PlayerModel loaded prepared AVPlayerItem.")
    }
    
    /// Starts video playback.
    func play() {
        isPlaying = true
        player.play()
    }
    
    /// Pauses video playback.
    func pause() {
        isPlaying = false
        player.pause()
    }
    
    /// Sets the presentation mode for the player.
    func setPresentation(_ presentation: Presentation) {
        self.presentation = presentation
        // Configure audio experience based on presentation mode
        configureAudioExperience(for: presentation)
    }
    
    /// Clears any loaded media and resets the player model to its default state.
    func reset() {
        player.replaceCurrentItem(with: nil)
        playerUI = nil
        playerUIDelegate = nil
        isPlaying = false
        isPlaybackComplete = false
        
        Task {
            presentation = .inline
        }
    }
    
    /// Configures the spatial audio experience based on presentation mode.
    private func configureAudioExperience(for presentation: Presentation) {
        do {
            let experience: AVAudioSessionSpatialExperience
            switch presentation {
            case .inline:
                // Set a small, focused sound stage when watching in inline mode
                experience = .headTracked(soundStageSize: .small, anchoringStrategy: .automatic)
            case .fullWindow:
                // Set a large sound stage size when viewing in docked mode
                experience = .headTracked(soundStageSize: .large, anchoringStrategy: .automatic)
            }
            try AVAudioSession.sharedInstance().setIntendedSpatialExperience(experience)
        } catch {
            print("Unable to set spatial experience: \(error.localizedDescription)")
        }
    }
    
    /// Configures the basic audio session for video playback.
    private func configureAudioSession() {
        do {
            // Configure the audio session for playback. Set the `moviePlayback` mode
            // to reduce the audio's dynamic range to help normalize audio levels.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        } catch {
            print("Unable to set spatial experience: \(error.localizedDescription)")
        }
    }
} 