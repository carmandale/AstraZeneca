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
    
    // Function to play the video using the unified method
    private func playVideo() {
        appModel.playVideo(playerModel: playerModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Video title and description from AppModel
            Text(appModel.videoTitle)
                .font(.extraLargeTitle)
            
            Text(appModel.videoDescription)
                .font(.title2)
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
            
            // Video thumbnail with play button overlay
            ZStack {
                Image("AZ-logo") // Replace with actual video thumbnail if available
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                    .cornerRadius(12)
                
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white.opacity(0.8))
            }
            .onTapGesture {
                playVideo()
            }
            
            // Explicit play button
            Button(action: playVideo) {
                Label("Play Video", systemImage: "play.fill")
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(40)
        .navigationTitle("AstraZeneca Video")
    }
}
