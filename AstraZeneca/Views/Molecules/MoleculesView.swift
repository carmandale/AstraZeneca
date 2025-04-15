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
            let textWidth = min(max(proxy.size.width * 0.4, 300), 500)
            let imageWidth = min(max(proxy.size.width - textWidth, 300), 700)
            
            ZStack {
                HStack(spacing: 60) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("HER2, Trastuzumab, and Pertuzumab Interaction")
                            .font(.system(size: 50, weight: .bold))
                            .padding(.bottom, 15)
                            .accessibilitySortPriority(4)
                        
                        Text("HER2 (Human Epidermal growth factor Receptor 2) is a protein that promotes the growth of cancer cells. In some breast cancers, the HER2 gene makes too many copies of itself, leading to overexpression of HER2 receptors on cancer cells, known as HER2-positive breast cancer.\n\nTrastuzumab (Herceptin) is a monoclonal antibody that binds to domain IV of the HER2 receptor, preventing activation and marking the cell for immune destruction. Pertuzumab (Perjeta) binds to a different region, domain II, blocking HER2 from pairing with other HER receptors. Together, these antibodies provide a comprehensive blockade of HER2 signaling, improving treatment outcomes.")
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
