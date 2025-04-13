//
//  CustomColors.swift
//  AstraZeneca
//
//  Created by Dale Carman on 4/10/25.
//

import SwiftUI

// MARK: - Custom Colors
extension Color {
    static let magentaDark = Color(red: 0.51, green: 0, blue: 0.32)
    static let ascoPurple = Color(red: 0.24, green: 0.06, blue: 0.33)
    static let ascoYellow = Color(red: 0.94, green: 0.67, blue: 0)
    static let limeGreen = Color(red: 0.76, green: 0.84, blue: 0)
    static let teal = Color(red: 0.4, green: 0.82, blue: 0.87)
    static let purple2 = Color(red: 0.68, green: 0.33, blue: 0.87)
    static let charcoal    = Color(red: 0.25, green: 0.27, blue: 0.27)
    static let magenta     = Color(red: 0.82, green: 0.20, blue: 0.44)
    static let navyBlue    = Color(red: 0.00, green: 0.20, blue: 0.42)
    static let purple      = Color(red: 0.44, green: 0.00, blue: 0.33)
    static let skyBlue     = Color(red: 0.65, green: 0.89, blue: 0.93)
    static let customWhite = Color(red: 1.00, green: 1.00, blue: 1.00)
    static let yellow      = Color(red: 0.94, green: 0.67, blue: 0.28)
    
    // MARK: - Add Color Hex Initializer (if not already present) - (No Changes)
    
//    init(hex: String) {
//        // ... (same implementation as before)
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:(a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
//    }
}
