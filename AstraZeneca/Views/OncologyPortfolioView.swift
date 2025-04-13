import SwiftUI

// MARK: - Data Models
struct Trial: Identifiable {
    let id = UUID()
    let number: Int
    let category: String // e.g., "ADC", "RC", "TDR", "IO", "Immune Engager", "Cell Therapy", "Epigenetics"
    let isInitiating: Bool
    let drugName: String? // Optional, for the rightmost section
    let target: String?   // Optional, for the rightmost section

    var color: Color {
        switch category {
        case "ADC": return Color(red: 0.82, green: 0.20, blue: 0.44) // Magenta
        case "RC": return Color(red: 0.25, green: 0.27, blue: 0.27) // Charcoal
        case "TDR": return Color(red: 0.00, green: 0.20, blue: 0.42) // Navy Blue
        case "DDR": return Color(red: 0.44, green: 0.00, blue: 0.33) // Purple
        case "IO": return Color(red: 0.65, green: 0.89, blue: 0.93) // Sky Blue
        case "Immune Engager": return Color(red: 0.76, green: 0.84, blue: 0) // Lime Green
        case "Cell Therapy": return Color(red: 0.94, green: 0.67, blue: 0) // Asco Yellow
        case "Epigenetics": return Color(red: 0.24, green: 0.06, blue: 0.33) // Asco Purple
        default: return .gray
        }
    }
}

// MARK: - Trial View
struct TrialView: View {
    let trial: Trial

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(trial.color)
                .frame(height: 40) // Maintain fixed height for consistency

            if let drugName = trial.drugName, let target = trial.target {
                VStack(spacing: 2) { // Reduced spacing
                    Text(drugName)
                        .font(.caption) // Slightly smaller might fit better
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.8) // Allow text to shrink slightly
                        .lineLimit(1)
                    Text(target)
                        .font(.caption2) // Keep caption2
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 4) // Add padding to prevent text touching edges
            } else {
                Text("Trial \(trial.number)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Phase Section View (Modified)
struct PhaseSectionView: View {
    let phase: Int
    let trials: [Trial]

    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    let depth: CGFloat = 10

    var body: some View {
        // Outer container for background and corner radius
        VStack(alignment: .leading, spacing: 0) {
            // Title with its own background
            Text(phase == 0 ? "REGISTERED" : "PHASE \(phase)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.black.opacity(0.4))
                .cornerRadius(5)
                .padding(.bottom, 10)

            // Grid for trials
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(trials) { trial in
                    // Conditional Navigation Links
                    if trial.number == 1 || trial.number == 2 {
                        NavigationLink(destination: ADCPortfolioView()) {
                            TrialView(trial: trial)
                        }
                        .buttonStyle(.plain)
                    } else if trial.number == 7 {
                        NavigationLink(destination: EfficacyTrialView()) {
                            TrialView(trial: trial)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Display non-clickable trial
                        TrialView(trial: trial)
                    }
                }
            }

            // Footnote
            if trials.contains(where: { $0.isInitiating }) {
                Text("*Trial Initiating")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 5)
            }
        }
        .padding(8)
        .background(Color.charcoal.opacity(0.8))
        .cornerRadius(15)
        .frame(width: 290, alignment: .top)
        .offset(z: depth)
        .shadow(radius: 5, x: 5, y: 5)
    }
}

// MARK: - Main View
struct OncologyPortfolioView: View {
    
    // Corner radius for consistent appearance
    let containerCornerRadius: CGFloat = 25
    let phaseCornerRadius: CGFloat = 15
    
    // Spacing constants
    let horizontalSpacing: CGFloat = 40
    
    // Animation state variables
    @State private var animatePhase2: Bool = false
    @State private var animatePhase3: Bool = false
    @State private var animatePhase4: Bool = false
    
    // Sample data for each phase
    let phase1Trials: [Trial] = [
        Trial(number: 1, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 2, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 3, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 4, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 5, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 6, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 7, category: "Cell Therapy", isInitiating: true, drugName: nil, target: nil), // Has isInitiating = true
        Trial(number: 8, category: "Immune Engager", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 9, category: "Immune Engager", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 10, category: "Immune Engager", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 11, category: "Immune Engager", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 12, category: "Immune Engager", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 13, category: "Immune Engager", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 14, category: "Immune Engager", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 15, category: "TDR", isInitiating: false, drugName: nil, target: nil)
    ]

    let phase2Trials: [Trial] = [
        Trial(number: 16, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 17, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 18, category: "Epigenetics", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 19, category: "IO", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 20, category: "IO", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 21, category: "IO", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 22, category: "TDR", isInitiating: false, drugName: nil, target: nil)
    ]

    let phase3Trials: [Trial] = [
        Trial(number: 23, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 24, category: "ADC", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 25, category: "Epigenetics", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 26, category: "Epigenetics", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 27, category: "Epigenetics", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 28, category: "IO", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 29, category: "IO", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 30, category: "IO", isInitiating: false, drugName: nil, target: nil),
        Trial(number: 31, category: "IO", isInitiating: false, drugName: nil, target: nil)
    ]

    let phase4Trials: [Trial] = [
        Trial(number: 0, category: "ADC", isInitiating: false, drugName: "Trastuzumab deruxtecan", target: "(HER2)"),
        Trial(number: 0, category: "Epigenetics", isInitiating: false, drugName: "Osimertinib", target: "(EGFRm T790M)"),
        Trial(number: 0, category: "Epigenetics", isInitiating: false, drugName: "Olaparib", target: "(PARP)"),
        Trial(number: 0, category: "Epigenetics", isInitiating: false, drugName: "Acalabrutinib", target: "(BTK)"),
        Trial(number: 0, category: "Epigenetics", isInitiating: false, drugName: "Savolitinib", target: "(c-MET)"),
        Trial(number: 0, category: "IO", isInitiating: false, drugName: "Durvalumab", target: "(PD-L1)"), // Corrected category based on color
        Trial(number: 0, category: "Epigenetics", isInitiating: false, drugName: "Capivasertib", target: "(AKT)"),
        Trial(number: 0, category: "IO", isInitiating: false, drugName: "Tremelimumab", target: "(CTLA-4)") // Corrected category based on color
    ]

    var body: some View {
        ZStack {
            // Main VStack with precise leading alignment
            VStack(alignment: .leading, spacing: 10) {
                // Title at the top
                Text("Our diverse oncology and hematology portfolio")
                    .font(.extraLargeTitle2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
//                    .padding(.bottom, 4)
                
                Text("Select Trial 1, Trial 2, or Trial 7 to see more information")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.5))
                    .padding(.bottom, 20)
                
                // Phase sections row with exact spacing to fill width
                HStack(alignment: .top, spacing: horizontalSpacing) {
                    PhaseSectionView(phase: 1, trials: phase1Trials)
                        .frame(width: 270)
                    PhaseSectionView(phase: 2, trials: phase2Trials)
                        .frame(width: 270)
                        .offset(z: animatePhase2 ? 30 : 0)
                    PhaseSectionView(phase: 3, trials: phase3Trials)
                        .frame(width: 270)
                        .offset(z: animatePhase3 ? 60 : 0)
                    PhaseSectionView(phase: 0, trials: phase4Trials)
                        .frame(width: 270)
                        .offset(z: animatePhase4 ? 90 : 0)
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 2.0)) {
                        animatePhase2 = true
                        animatePhase3 = true
                        animatePhase4 = true
                    }
                }
                
//                Spacer()
                
                // Legend with right alignment
                HStack {
                    Spacer() // Push all items to the right
                    HStack(spacing: 15) {
                        legendItem(category: "ADC", color: Color(red: 0.82, green: 0.20, blue: 0.44))
                        legendItem(category: "RC", color: Color(red: 0.25, green: 0.27, blue: 0.27))
                        legendItem(category: "DDR", color: Color(red: 0.44, green: 0.00, blue: 0.33))
                        legendItem(category: "TDR", color: Color(red: 0.00, green: 0.20, blue: 0.42))
                        legendItem(category: "IO", color: Color(red: 0.65, green: 0.89, blue: 0.93))
                        legendItem(category: "Immune Engager", color: Color(red: 0.76, green: 0.84, blue: 0))
                        legendItem(category: "Cell Therapy", color: Color(red: 0.94, green: 0.67, blue: 0))
                        legendItem(category: "Epigenetics", color: Color(red: 0.24, green: 0.06, blue: 0.33))
                    }
                }
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("ADC Portfolio")
        }
    }
    
    // Helper function to create legend items
    private func legendItem(category: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 20, height: 20)
            
            Text(category)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

// MARK: - Preview
struct OncologyPortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        OncologyPortfolioView()
            .previewLayout(.device) // Use a realistic layout
            // .previewInterfaceOrientation(.landscapeLeft) // If intended for landscape
    }
}
