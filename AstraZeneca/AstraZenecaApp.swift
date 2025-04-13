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

    var body: some Scene {
        // Single window approach - content changes based on appModel.presentation
        WindowGroup(id: "mainWindow") {
            ContentView()
                .environment(appModel)
                .environment(playerModel)
        }
        // Optional: Set default size for the main window
        .defaultSize(width: 1280, height: 720)

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
