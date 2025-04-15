//
//  AstraZenecaApp.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/9/25.
//

import SwiftUI
import AVKit

@main
struct AstraZenecaApp: App {

    @State private var appModel = AppModel()
    @State private var playerModel = PlayerModel()
    @State private var viewModel = MoleculesViewModel()

    var body: some Scene {
        // Single window approach - content changes based on appModel.presentation
        WindowGroup(id: "mainWindow") {
            ContentView()
                .environment(appModel)
                .environment(playerModel)
                .environment(viewModel)
        }
        // Optional: Set default size for the main window
        .defaultSize(width: 1280, height: 720)
        
        // Molecules volumetric window
        WindowGroup(id: "molecules") {
            MoleculesWindow()
                .environment(appModel)
                .environment(viewModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
