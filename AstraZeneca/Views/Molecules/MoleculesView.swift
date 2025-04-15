//
//  MoleculesView.swift
//  AstraZeneca
//
//  Created for AstraZeneca on 4/14/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

/// Model display depths
private let modelDepth: Double = 200

/// A detail view that presents information about HER2, Trastuzumab, and Pertuzumab molecules.
struct MoleculesView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(MoleculesViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        GeometryReader { proxy in
            let textWidth = min(max(proxy.size.width * 0.6, 300), 500)
            let imageWidth = min(max(proxy.size.width - textWidth, 300), 700)
            
            ZStack {
                HStack(spacing: 60) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image("AZ-logo") // This is the 2D logo, part of main content
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 80)
                            .padding(.bottom, 20)
                        
                        Text("Targeting HER2: Precision Therapies in Action")
                            .font(.system(size: 50, weight: .bold))
                            .padding(.bottom, 5)
                            .accessibilitySortPriority(5)
                        
                        Text("Unlocking New Potential with Trastuzumab and Pertuzumab")
                            .font(.system(size: 30, weight: .semibold))
                            .padding(.bottom, 15)
                            .accessibilitySortPriority(4)
                        
                        Text("HER2 (Human Epidermal Growth Factor Receptor 2) drives aggressive tumor growth in certain breast cancers. AstraZeneca's targeted therapies, Trastuzumab (Herceptin) and Pertuzumab (Perjeta), selectively bind to HER2 receptors, disrupting cancer cell signaling pathways. By precisely blocking receptor interactions, these treatments significantly improve clinical outcomes for patients with HER2-positive breast cancer.")
                            .padding(.bottom, 24)
                            .accessibilitySortPriority(3)
                        
                        // Add link to AstraZeneca Oncology
                        Link("AstraZeneca Oncology",
                             destination: URL(string: "https://www.astrazeneca.com/our-therapy-areas/oncology.html")!)
                            .font(.headline)
                            .padding(.bottom, 24)
                    }
                    .frame(width: textWidth, alignment: .leading)
                    
                    // 3D Model area
                    VStack(spacing: 30) {
                        // Toggle button to open the volumetric window
                        // Only show the button if the model isn't supposed to be showing yet.
                        if !appModel.isShowingMolecules {
                            Button {
                                appModel.isShowingMolecules = true
                                openWindow(id: "molecules")
                            } label: {
                                Label("Open 3D Model", systemImage: "cube.transparent")
                            }
                            .buttonStyle(.bordered)
                            .font(.title3)
                        }
                    }
                    .frame(width: imageWidth, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding([.leading, .trailing], 70)
        .padding(.bottom, 24)
    }
}
