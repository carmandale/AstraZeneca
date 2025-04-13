//
//  ASCOPresenceView.swift
//  AstraZeneca
//

import SwiftUI

// MARK: - Data Structures
struct PresentationData: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let color: Color
}

// MARK: - Main View
struct ASCOPresenceView: View {
    
    // Debug to show background colors
    let debugEnabled: Bool = false
    
    // Corner radii for individual items
    let itemCornerRadius: CGFloat = 12
    
    // Unified vertical spacing for left panel items
    let leftPanelSpacing: CGFloat = 24
    
    // Desired widths for the side panels
    let leftPanelWidth: CGFloat = 500
    let rightPanelWidth: CGFloat = 230
    
    // Animation state variable
    @State private var animateChart: Bool = false
    
    // Data for Pie Chart and Legend
    let presentationData: [PresentationData] = [
        PresentationData(name: "LBA Special Session",   count: 1,  color: .ascoPurple),
        PresentationData(name: "Plenaries",             count: 2,  color: .magentaDark),
        PresentationData(name: "Oral Presentations",    count: 8,  color: .ascoYellow),
        PresentationData(name: "Rapid Orals",           count: 8,  color: .magentaDark),
        PresentationData(name: "Posters",               count: 73, color: .limeGreen),
        PresentationData(name: "Online Only",           count: 24, color: .teal),
        PresentationData(name: "Clinical Science Symposiums", count: 3, color: .ascoPurple),
        PresentationData(name: "Education Session",     count: 1,  color: .purple2)
    ]
    
    // Tumor Type Icons
    let tumorIcons = ["lung", "breast", "kidney", "head", "ovary", "intestines", "drop"]
    let depth: CGFloat = 40
    
    var body: some View {
        // Main container: header then 3-column layout
        VStack(alignment: .leading, spacing: 24) {
            
            // Header
            HStack {
                Text("Presence of AstraZeneca at ASCO")
                    .font(.extraLargeTitle2)
                    .fontWeight(.semibold)
                Spacer()
                Image("ASCO")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            
            // 3-column layout
            HStack(alignment: .center, spacing: 40) {
                
                // LEFT PANEL
                VStack(alignment: .leading, spacing: leftPanelSpacing) {
                    
                    // 1) Tumor Types
                    StatItemView(value: 8, outerCornerRadius: itemCornerRadius) {
                        TumorTypeDetailView(tumorIcons: tumorIcons)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
//                    .overlay(Rectangle().stroke(Color.red, lineWidth: 2))
                    
                    // 2) Approved Medicines
                    StatItemView(value: 8, outerCornerRadius: itemCornerRadius) {
                        Text("Approved Medicines")
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                    }
//                    .overlay(Rectangle().stroke(Color.red, lineWidth: 2))
                    
                    
                    // 3) Pipeline Molecules
                    StatItemView(value: 17, outerCornerRadius: itemCornerRadius) {
                        Text("Pipeline Molecules")
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                    }
//                    .overlay(Rectangle().stroke(Color.red, lineWidth: 2))
                    
                    // 4) Abstracts
                    StatItemView(value: 119, outerCornerRadius: itemCornerRadius) {
                        Text("Abstracts")
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                    }
//                    .overlay(Rectangle().stroke(Color.red, lineWidth: 2)) 
                }
                .frame(width: leftPanelWidth, alignment: .leading)
                .background(debugEnabled ? Color.red.opacity(0.3) : Color.clear)
                
                // CENTER PANEL (Chart)
                Image("chart")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .background(debugEnabled ? Color.green.opacity(0.3) : Color.clear)
                    .offset(z: animateChart ? depth * 3 : 0)
                    .shadow(radius: 5, x: 5, y: 5)
                    .onAppear {
                        withAnimation(.easeOut(duration: 2.0)) {
                            animateChart = true
                        }
                    }
                
                // RIGHT PANEL (Legend)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(presentationData) { item in
                        LegendItemView(item: item, outerCornerRadius: itemCornerRadius)
                    }
                }
                .frame(width: rightPanelWidth, alignment: .center)
                .background(debugEnabled ? Color.blue.opacity(0.3) : Color.clear)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("ASCO Presence")

        .ornament(attachmentAnchor: .scene(.bottom)) {
            NavigationLink {
                OncologyPortfolioView()
            } label: {
                Label("Continue", systemImage: "chevron.right")
            }
            .labelStyle(.titleAndIcon)
            .glassBackgroundEffect() // Apply glass effect to the ornament content
        }
    }
}

// MARK: - Supporting Views

// Tumor Type Label + Icons
struct TumorTypeDetailView: View {
    let tumorIcons: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tumor Types")
                .font(.title2)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                ForEach(tumorIcons, id: \.self) { iconName in
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 34)
                }
            }
        }
        // Minimal extra padding so you see the content “centered”
        .padding(.vertical, 4)
        // Fill the space given by the parent
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StatItemView<Content: View>: View {
    let value: Int
    let outerCornerRadius: CGFloat
    let content: Content
    let depth: CGFloat = 10
    
    // Same uniform padding on top/bottom/left/right
    private let internalPadding: CGFloat = 12
    
    // Gap between the purple number box and text/icons
    private let gapBetweenBoxAndText: CGFloat = 16
    
    init(
        value: Int,
        outerCornerRadius: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.value = value
        // Multiply the corner radius by 1.5, as you do in the legend
        self.outerCornerRadius = outerCornerRadius * 1.5
        self.content = content()
    }
    
    var body: some View {
        // Nested corner math
        let innerCornerRadius = max(0, outerCornerRadius - internalPadding)
        
        HStack(spacing: gapBetweenBoxAndText) {
            
            // Purple number box, left-aligned
            Text("\(value)")
                .font(.system(size: 44, weight: .heavy))
                .frame(maxWidth: 130, maxHeight: .infinity, alignment: .center)
                .padding(.vertical, 4)
                .background(Color.magentaDark)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: innerCornerRadius))
            
            // Whatever label/icons you pass in
            content
        }
        .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
        .padding(internalPadding)
        .background(Color.charcoal.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: outerCornerRadius)
            .inset(by: 0.64)
            .stroke(.white.opacity(0.4), lineWidth: 1.28158)
        )
        .clipShape(RoundedRectangle(cornerRadius: outerCornerRadius))
        .offset(z: depth)
        .shadow(radius: 5, x: 5, y: 5)
    }
}

/// Single Legend Item + Color Box
struct LegendItemView: View {
    let item: PresentationData
    let outerCornerRadius: CGFloat
    let depth: CGFloat = 20
    
    private let internalPadding: CGFloat = 4
    
    var body: some View {
        let innerCornerRadius = max(0, outerCornerRadius - internalPadding)
        
        HStack(spacing: 8) {
            // Color box with count
            ZStack {
                RoundedRectangle(cornerRadius: innerCornerRadius)
                    .fill(item.color)
                    .frame(width: 48, height: 30)
                
                Text("\(item.count)")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            
            // Text label
            Text(item.name)
                .font(.callout)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(internalPadding)
        .background(Color.charcoal.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: outerCornerRadius)
            .inset(by: 0.64)
            .stroke(.white.opacity(0.4), lineWidth: 1.28158)
        )
        .clipShape(RoundedRectangle(cornerRadius: outerCornerRadius))
        .offset(z: depth)
        .shadow(radius: 5, x: 5, y: 5)
    }
}

// MARK: - Preview
#Preview {
    ASCOPresenceView()
}
