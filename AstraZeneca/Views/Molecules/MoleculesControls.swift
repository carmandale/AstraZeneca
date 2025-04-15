//
//  MoleculesControls.swift
//  AstraZeneca
//
//  Created on 4/14/25.
//

import SwiftUI

/// Controls that people can use to manipulate the molecules in a volumetric window.
struct MoleculesControls: View {
    @Environment(MoleculesViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        Picker("View", selection: $viewModel.displayMode) {
            Text("HER2").tag(ModelDisplayMode.her2Only)
            Text("Trastuzumab").tag(ModelDisplayMode.trastuzumabOnly)
            Text("Pertuzumab").tag(ModelDisplayMode.pertuzumabOnly)
            Text("Combined").tag(ModelDisplayMode.combined)
        }
        .pickerStyle(.segmented)
        .padding(12)
        .glassBackgroundEffect(in: .rect(cornerRadius: 50))
        .alignmentGuide(.controlPanelGuide) { context in
            context[HorizontalAlignment.center]
        }
        .accessibilitySortPriority(2)
    }
}

