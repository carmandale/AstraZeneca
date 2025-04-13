//
//  EfficacyTrialView.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/10/25.
//

import SwiftUI

// Slide 5: Efficacy Trial View
struct EfficacyTrialView: View {
    var body: some View {
        ZStack {
            // Set a background color (similar to other views)

            VStack(spacing: 20) {
                // Keep the original title text
                HStack {
                    Text("Trial 7 preliminary efficacy across tumor types")
                        .font(.extraLargeTitle2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white) // Use white text on dark background
                        .padding(.top) // Add some top padding
                        .padding(.horizontal, 40) // Add horizontal padding
                    Spacer()
                }

                // Display the 'scans' image
                Image("scans") // Assuming 'scans.svg' is in your assets
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom) // Add some bottom padding
                    .padding(.horizontal, 10) // Add horizontal padding

                Spacer() // Push content towards the top if image isn't filling
            }
            .padding(.horizontal) // Add horizontal padding to the VStack
            // .padding(40)
        }
        .navigationTitle("Trial 7 Efficacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Simple placeholder for previewing image areas if needed
// (Keeping this struct definition in case it's used elsewhere,
// but it's removed from the main body of EfficacyTrialView)
//struct ScanImagePlaceholder: View {
//    enum MarkPosition { case left, right, none }
//    var markPosition: MarkPosition = .none
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color.gray.opacity(0.5))
//                .frame(height: 100) // Example height
//
//            if markPosition != .none {
//                Circle()
//                    .fill(Color.red)
//                    .frame(width: 10, height: 10)
//                    .padding(5)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: markPosition == .left ? .topLeading : .topTrailing)
//            }
//        }
//    }
//}

// MARK: - Preview
#Preview(windowStyle: .plain) {
    EfficacyTrialView()
}
