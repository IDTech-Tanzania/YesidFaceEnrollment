import SwiftUI

extension Color {
    
    static let primaryColor = Color(hex: "1155cc")
    static let primaryBlack = Color(hex:"1c528f")
    static let light_white = Color(hex:"fefefe")
    static let success = Color(hex: "3ec28f")
    static let caption_or_label = Color(hex: "661c2648", alpha: 0.1)
    static let default_black = Color(hex:"000000")
    
    static let buttonLightBackGroundColor = Color(hex:"a0bbeb")
    
    static let cardCollapsedBackgroundColor = Color(hex:"fefffd")
    static let cardExpandedBackgroundColor = Color(hex:"fefffd")
    
    init(hex: String, alpha: Double = 1) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        
        let scanner = Scanner(string: cString)
        scanner.currentIndex = scanner.string.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(.sRGB, red: Double(r) / 0xff, green: Double(g) / 0xff, blue:  Double(b) / 0xff, opacity: alpha)
    }
}
