import SwiftUI

// Keep asset names identical to Flutter. Xcode resolves the 1×/3× image-set variants.
enum ShopTheme {
    static let blue = Color(hex: 0x025FCA)
    static let tabIndicatorUIColor = UIColor(red: 2.0 / 255, green: 95.0 / 255, blue: 202.0 / 255, alpha: 1)
    static let tabGlowUIColor = UIColor(red: 3.0 / 255, green: 122.0 / 255, blue: 1, alpha: 0.10)
    static let tabIndicator = Color(tabIndicatorUIColor)
    static let tabGlow = Color(tabGlowUIColor)
    static let brightBlue = Color(hex: 0x037AFF)
    static let background = Color(hex: 0xF7F9FA)
    static let paleBlue = Color(hex: 0xE6F1FF)
    static let text = Color(hex: 0x1C252E)
    static let muted = Color(hex: 0x919EAB)
    static let flash = Color(hex: 0xFF6948)
    static let red = Color(hex: 0xEF382F)
    static func font(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        let face = weight == .bold ? "Bold" : weight == .semibold ? "SemiBold" : "Regular"
        return .custom("Inter-\(face)", size: size)
    }
}
extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
    }
}
enum ShopFormat {
    static func money(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: value)) ?? String(value)) đ"
    }
    static func date(_ iso: String) -> String {
        let parts = iso.split(separator: "-")
        return parts.count == 3 ? "\(parts[2])/\(parts[1])/\(parts[0])" : iso
    }
}
