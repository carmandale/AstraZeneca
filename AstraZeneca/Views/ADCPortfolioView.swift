import SwiftUI

// --- Data Models, Colors, Helpers (PhaseHeaderView, DashedLine) remain the same ---
// MARK: - Data Models (Specific to this View)
struct ADCTrial: Identifiable {
    let id = UUID()
    let name: String
    let targetPayload: String
    let activePhases: Set<Phase>
    let tumorTypes: String
}

enum Phase: Int, CaseIterable, Comparable {
    case phase1 = 1
    case phase2 = 2
    case phase3 = 3

    static func < (lhs: Phase, rhs: Phase) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Colors (adjust as needed)
let backgroundColor = Color(white: 0.25)
let containerColor = Color(white: 0.35)
let headerBackgroundColor = Color(white: 0.5)
let trialInfoBackgroundColor = Color(white: 0.5)
let progressBarColor = Color.yellow // Use Color(hex:"...") if you have specific hex codes
let textColor = Color.white
let subtitleColor = Color.white.opacity(0.8)

// MARK: - Helper Views

// View for the Phase/Tumor Headers
struct PhaseHeaderView: View {
    let title: String
    let width: CGFloat

    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(textColor)
            .frame(width: width, height: 25, alignment: .center) // Ensure center alignment
            .background(headerBackgroundColor)
            .cornerRadius(5)
    }
}

// View for Dashed Vertical Lines
struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}


// MARK: - View for a Single Trial Row (REVISED BAR LOGIC)
struct ADCTrialRowView: View {
    let trial: ADCTrial
    let trialInfoWidth: CGFloat
    let phaseColumnWidth: CGFloat
    let tumorColumnWidth: CGFloat
    let columnSpacing: CGFloat

    // --- REVISED barMetrics Calculation ---
    private var barMetrics: (width: CGFloat, offset: CGFloat) {
        guard !trial.activePhases.isEmpty else { return (0, 0) }

        let sortedPhases = trial.activePhases.sorted()
        guard let firstPhase = sortedPhases.first,
              let lastPhase = sortedPhases.last else { return (0, 0) }

        // Index (0-based) of the first phase column
        let firstPhaseIndex = CGFloat(firstPhase.rawValue - 1)
        // Index (0-based) of the last phase column
        let lastPhaseIndex = CGFloat(lastPhase.rawValue - 1)

        // Calculate start offset relative to the beginning of the entire phase area
        // Offset = Index * (Column Width + Spacing)
        let startOffset = firstPhaseIndex * (phaseColumnWidth + columnSpacing)

        // Calculate width
        // Width = (Number of phases spanned) * Column Width + (Number of gaps spanned) * Spacing
        let phasesSpanned = lastPhaseIndex - firstPhaseIndex + 1
        let gapsSpanned = max(0, phasesSpanned - 1) // Number of gaps *between* spanned phases

        let barWidth = (phasesSpanned * phaseColumnWidth) + (gapsSpanned * columnSpacing)

        // --- Visual Inset Adjustment ---
        // Apply a small inset from the left edge of the calculated start
        // and reduce the width slightly to prevent sticking out on the right.
        // Tweak these values (e.g., 2, 3, 4) to match the visual gap.
        let visualInset: CGFloat = 3
        let adjustedOffset = startOffset + visualInset
        let adjustedWidth = max(0, barWidth - (visualInset * 2)) // Ensure width isn't negative

        return (adjustedWidth, adjustedOffset)
    }
    // --- End REVISED barMetrics ---


    private var phaseDetailText: String? {
        if trial.name == "Trial 1" && trial.activePhases == [.phase1, .phase2] {
             return "GEMINI phase 2:\nAZD0901 + rilvegostomig\n1L CLDN18.2+ gastric"
        }
        return nil
    }


    var body: some View {
        // Use an HStack where spacing is controlled by the items' frames and explicit Spacers
        HStack(spacing: 0) {
            // 1. Trial Info Box
            VStack(alignment: .center, spacing: 2) {
                Text(trial.name)
                    .font(.system(size: 11, weight: .bold))
                Text(trial.targetPayload)
                    .font(.system(size: 9))
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(textColor)
            .padding(.vertical, 8)
            .frame(width: trialInfoWidth) // Enforce width
            .background(trialInfoBackgroundColor)
            .cornerRadius(8)

            Spacer().frame(width: columnSpacing) // Explicit Spacer for gap

            // 2. Phase Bars Area
            ZStack(alignment: .leading) { // Align content to leading edge
                // Background placeholder for the entire phase area (optional for debugging)
                // Rectangle().fill(.red.opacity(0.1))

                // The progress bar itself, positioned using offset
                Capsule()
                    .fill(progressBarColor)
                    .frame(width: barMetrics.width, height: 15)
                    .offset(x: barMetrics.offset) // Offset calculated relative to ZStack's leading edge

                // Optional: Text overlay next to bar
                 if let detailText = phaseDetailText {
                     Text(detailText)
                         .font(.system(size: 8))
                         .foregroundColor(textColor.opacity(0.9))
                         .lineLimit(3)
                         .fixedSize(horizontal: false, vertical: true)
                         // Position text relative to the END of the bar + padding
                         .offset(x: barMetrics.offset + barMetrics.width + 5, y: -2) // Adjust offset as needed
                 }
            }
            // Frame the ZStack to the exact total width of all phase columns + gaps BETWEEN them
            .frame(width: (phaseColumnWidth * CGFloat(Phase.allCases.count)) + (columnSpacing * CGFloat(Phase.allCases.count - 1)),
                   alignment: .leading) // Ensure ZStack itself aligns left

            Spacer().frame(width: columnSpacing) // Explicit Spacer for gap

            // 3. Tumor Types Text
            Text(trial.tumorTypes)
                .font(.system(size: 10))
                .foregroundColor(textColor)
                .frame(width: tumorColumnWidth, alignment: .leading) // Enforce width and alignment
                .lineLimit(nil) // Allow text to wrap fully
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion based on content

        }
        .frame(height: 65, alignment: .center) // Align items vertically centered in the row
    }
}


// MARK: - Main Portfolio View (REVISED DASHLINE LOGIC)
struct ADCPortfolioView: View {

    // --- Column Layout Configuration ---
    // Tweak these slightly if needed based on visual comparison
    let trialInfoWidth: CGFloat = 70
    let phaseColumnWidth: CGFloat = 80
    let tumorColumnWidth: CGFloat = 150
    let columnSpacing: CGFloat = 10 // The gap BETWEEN columns
    // --- End Configuration ---

    // Sample Data (No Changes)
    let adcTrials: [ADCTrial] = [
        ADCTrial(name: "Trial 1", targetPayload: "Claudin 18.2\nMMAE", activePhases: [.phase1, .phase2], tumorTypes: "Gastric, GEJ,\npancreatic"),
        ADCTrial(name: "Trial 1", targetPayload: "Claudin 18.2\nMMAE", activePhases: [.phase1], tumorTypes: "Endometrial, ova\nrian,\nbreast, biliary"),
        ADCTrial(name: "Trial 1", targetPayload: "Claudin 18.2\nMMAE", activePhases: [.phase1], tumorTypes: "NSCLC, HNSCC,\nCRC"),
        ADCTrial(name: "Trial 1", targetPayload: "Claudin 18.2\nMMAE", activePhases: [.phase1], tumorTypes: "Ovarian, NSCLC"),
        ADCTrial(name: "Trial 1", targetPayload: "Claudin 18.2\nMMAE", activePhases: [.phase1], tumorTypes: "R/R multiple\nmyeloma"),
        ADCTrial(name: "Trial 1", targetPayload: "Claudin 18.2\nMMAE", activePhases: [.phase1], tumorTypes: "Acute myelocytic\nleukemia,\nmyelodysplastic\nsyndrome")
    ]


    var body: some View {
        ZStack {
            // Remove ScrollView and its contents
            // Replace with a simple VStack
            VStack(spacing: 20) {
                HStack {
                    Text("Growing our portfolio of differentiated ADCs") // Use full text
                        .font(.extraLargeTitle2)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor)
                        .padding(.horizontal, 40) // Add horizontal padding
                    Spacer()
                }

                Image("portfolio") // Assuming "portfolio.svg" is in your assets
                    .resizable()
                    .scaledToFit() // Keep aspect ratio
                    .padding(.horizontal, 10) // Add horizontal padding

            }
            .padding()
        }
        .navigationTitle("ADC Portfolio") // Add navigation title
        .navigationBarTitleDisplayMode(.inline) // Set display mode
    }
}



struct ADCPortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        ADCPortfolioView()
            .previewLayout(.fixed(width: 1200, height: 700))
            .preferredColorScheme(.dark)
    }
}
