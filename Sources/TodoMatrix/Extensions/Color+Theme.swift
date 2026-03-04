import SwiftUI
import AppKit

extension Color {
    static let q1Border = Color(hex: "FF3B30")
    static let q2Border = Color(hex: "FF9500")
    static let q3Border = Color(hex: "007AFF")
    static let q4Border = Color(hex: "8E8E93")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Quadrant {
    var borderColor: Color {
        switch self {
        case .q1: return .q1Border
        case .q2: return .q2Border
        case .q3: return .q3Border
        case .q4: return .q4Border
        }
    }
}
