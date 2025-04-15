//
//  MoleculesWindow.swift
//  AstraZeneca
//
//  Created on 4/14/25.
//

import SwiftUI

/// The molecules content for a volumetric window.
struct MoleculesWindow: View {
    @Environment(AppModel.self) private var appModel
    @Environment(MoleculesViewModel.self) private var viewModel

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .controlPanelGuide, vertical: .bottom)) {
            // 3D model view
            MoleculesModelView()
                .environment(viewModel)
                .alignmentGuide(.controlPanelGuide) { context in
                    context[HorizontalAlignment.center]
                }
            
            // Controls at the bottom
            MoleculesControls()
                .offset(y: -70)
        }
        .onDisappear {
            appModel.isShowingMolecules = false
        }
    }
}

extension HorizontalAlignment {
    /// A custom alignment to center the control panel under the molecules model.
    private struct ControlPanelAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    /// A custom alignment guide to center the control panel under the molecules model.
    static let controlPanelGuide = HorizontalAlignment(
        ControlPanelAlignment.self
    )
}

//#Preview {
//    MoleculesWindow()
//        .environment(AppModel())
//}
