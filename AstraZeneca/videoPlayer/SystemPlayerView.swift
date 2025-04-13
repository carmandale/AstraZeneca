import AVKit
import SwiftUI

/// A SwiftUI wrapper on `AVPlayerViewController`.
struct SystemPlayerView: UIViewControllerRepresentable {
    @Environment(PlayerModel.self) private var playerModel
    @Environment(AppModel.self) private var appModel
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        // Create a player view controller
        let controller = playerModel.makePlayerUI()
        
        // Basic configuration for visionOS
        controller.allowsPictureInPicturePlayback = true
        
        // Set the coordinator as delegate to handle player events
        controller.delegate = context.coordinator
        
        // Store the coordinator in the model
        playerModel.playerUIDelegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, 
                              context: Context) {
        // No updates needed as the player model handles state changes
    }
    
    // Create a coordinator to handle delegate calls
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        private var parent: SystemPlayerView
        
        init(_ parent: SystemPlayerView) {
            print("SystemPlayerView Coordinator init")
            self.parent = parent
        }
        
        // This is called when the player exits fullscreen mode
        nonisolated func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
            print("Player will end full screen presentation")
            
            // Reset app state on the main thread
            Task { @MainActor in
                // Reset player
                self.parent.playerModel.pause()
                self.parent.playerModel.setPresentation(.inline)
                
                // Switch app presentation back to normal
                self.parent.appModel.presentation = .normal
            }
        }
    }
}
