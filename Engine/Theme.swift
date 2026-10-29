import SwiftUI

extension Color {
    /// 0xRRGGBB
    init(hex: UInt32, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: alpha)
    }
}

/// Design tokens shared by the shell and every lesson.
/// Blue = the thing being read, orange = the thing being worked out, green = the finished answer.
enum Theme {
    static let ink    = Color(hex: 0x17233a)
    static let blue   = Color(hex: 0x0a84ff)
    static let orange = Color(hex: 0xe86f00)
    static let green  = Color(hex: 0x1a9e62)
    static let muted  = Color(hex: 0x8391a6)
    static let canvas = Color(hex: 0xfffefa)
    static let page   = Color(hex: 0xe8edf2)
    static let line   = Color(hex: 0xe1e8ef)
    static let dash   = Color(hex: 0xcbd7e3)
    static let ghost  = Color(hex: 0xc0ccd8)
    static let body   = Color(hex: 0x34425a)
    static let sub    = Color(hex: 0x6b7a90)
    static let soft   = Color(hex: 0xeaf3ff)
    static let panel  = Color(hex: 0xf5f8fb)
    static let shadow = Color(hex: 0x17233a)

    /// Nunito in the web build. SF Rounded is the closest system face.
    static func round(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    /// DM Sans in the web build.
    static func text(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func weight(_ w: Int) -> Font.Weight {
        switch w {
        case ...400: return .regular
        case 401...500: return .medium
        case 501...600: return .semibold
        case 601...700: return .bold
        case 701...800: return .heavy
        default: return .black
        }
    }
}

/// Fixed design canvas. Every screen is authored at 1024 x 768 and scaled to fit.
enum Canvas {
    static let w: CGFloat = 1024
    static let h: CGFloat = 768
}
