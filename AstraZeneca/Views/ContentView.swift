//
//  ContentView.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent



struct ContentView: View {
    /// App-wide state
    @Environment(AppModel.self) private var appModel
    @Environment(PlayerModel.self) private var playerModel
    @Environment(MoleculesViewModel.self) private var viewModel
    
    @State private var selection = 1
    @State private var opacity: Double = 0.0  // Local opacity state

    var body: some View {
        // Switch content based on presentation state
        switch appModel.presentation {
        case .fullWindow:
            // Show the video player in full window mode
            PlayerView()
                .onAppear {
                    print("Showing PlayerView in full window presentation")
                    
                    // Make sure the video is loaded and playing
                    // This is a safety check in case we transition directly to this state
                    if playerModel.player.currentItem == nil {
                        appModel.playVideo(playerModel: playerModel)
                    }
                }
        
        case .normal:
            // Show the normal app UI with tabs
            TabView(selection: $selection) {
                NavigationStack {
                    ExecutiveMeetingView()
                }
                .tag(1)
                .tabItem {
                    Label("Welcome", systemImage: "house")
                }

                NavigationStack {
                    ASCOPresenceView()
                }
                .tag(2)
                .tabItem {
                    Label("ASCO Presence", systemImage: "person.3")
                }

                NavigationStack {
                    OncologyPortfolioView()
                }
                .tag(3)
                .tabItem {
                    Label("ADC Portfolio", systemImage: "briefcase")
                }
                
                // New Molecules Tab
                NavigationStack {
                    MoleculesView()
                        .environment(viewModel)
                }
                .tag(4)
                .tabItem {
                    Label("Molecules", systemImage: "atom")
                }
                
                // Video Player Tab - moved to tag 5
                NavigationStack {
                    VideoView()
                }
                .tag(5)
                .tabItem {
                    Label("Watch Video", systemImage: "play.circle.fill")
                }
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 1.0
                }
            }
        }
    }
}

extension View {
    func rotateRight(from degrees: Double) -> some View {
        self.rotationEffect(Angle(degrees: degrees))
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

//#Preview(windowStyle: .automatic) {
//    ContentView()
//        .environment(AppModel())
//}
