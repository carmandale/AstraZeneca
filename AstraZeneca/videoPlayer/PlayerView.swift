import SwiftUI

/// A view that presents the video player.
struct PlayerView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(PlayerModel.self) private var playerModel
    
    var body: some View {
        SystemPlayerView()
            .onAppear {
                // Start playback when the view appears
                print("PlayerView is appearing and play is called!")
                
                // Ensure proper video is loaded
                if let url = appModel.currentVideoURL {
                    // Make sure we're in full window presentation mode
                    playerModel.setPresentation(.fullWindow)
                    playerModel.play()
                }
            }
    }
}
