//
//  MoleculesToggle.swift
//  AstraZeneca
//
//  Created on 4/14/25.
//

import SwiftUI

/// A toggle that activates or deactivates the molecules volumetric window.
struct MoleculesToggle: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Button("View Model") {
            // Set state to indicate the window is being shown
            appModel.isShowingMolecules = true
            // Open the window
            openWindow(id: "molecules")
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    MoleculesToggle()
        .environment(AppModel())
}
