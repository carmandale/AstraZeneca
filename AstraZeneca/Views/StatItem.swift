//
//  StatItem.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/10/25.
//

import SwiftUI

// MARK: - Helper Views

struct StatItem: View {
    let number: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(number)
                .font(.headline)
                .foregroundColor(color)
            
            Text(label)
                .font(.subheadline)
        }
    }
}

struct TrialItem: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

struct GridTrialRow: View {
    let trials: [TrialItem]
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(trials) { trial in
                Text(trial.name)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(trial.color)
                    .foregroundColor(.white)
            }
        }
    }
}

struct CategoryTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(color)
            .foregroundColor(.white)
    }
}

struct ADCTrialRow: View {
    let trialName: String
    let phaseOneWidth: CGFloat
    let phaseTwoWidth: CGFloat
    let phaseThreeWidth: CGFloat
    let tumorTypes: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Trial name
            Text(trialName)
                .font(.caption)
                .frame(width: 90, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            // Phase 1 bar
            if phaseOneWidth > 0 {
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: phaseOneWidth, height: 30)
            }
            
            // Phase 2 bar
            if phaseTwoWidth > 0 {
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: phaseTwoWidth, height: 30)
            }
            
            // Phase 3 bar
            if phaseThreeWidth > 0 {
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: phaseThreeWidth, height: 30)
            }
            
            Spacer()
            
            // Tumor types
            Text(tumorTypes)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .frame(width: 150, alignment: .leading)
        }
        .frame(height: 50)
    }
}

struct ScanImagePlaceholder: View {
    enum MarkPosition {
        case left, center, right
    }
    
    let markPosition: MarkPosition
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 80)
            
            switch markPosition {
            case .left:
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .offset(x: -30, y: 0)
            case .center:
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 20, height: 20)
            case .right:
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .offset(x: 30, y: 0)
            }
        }
    }
}
