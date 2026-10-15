import SwiftUI
import UIKit

/// Apple Human Interface Guidelines-compliant design tokens for Harmonia Camera.
public enum AppTheme {
    
    // MARK: - Colors
    public enum Colors {
        /// Primary true black for camera letterboxing and controls (OLED true black)
        public static let deepBlack = Color(red: 0.03, green: 0.03, blue: 0.03)
        
        /// Studio Red for classical composition guidelines
        public static let studioRed = Color(red: 0.95, green: 0.20, blue: 0.20)
        
        /// Apple Gold for fine-art Fibonacci and Golden Triangles
        public static let appleGold = Color(red: 0.98, green: 0.78, blue: 0.25)
        
        /// Polar White for clean minimalist grids
        public static let polarWhite = Color.white
        
        /// Level Active Green (when device hits 0.0° level)
        public static let levelLockedGreen = Color(red: 0.20, green: 0.88, blue: 0.40)
        
        /// Subtle 1px anti-glare halo for vector line contrast
        public static let lineDarkHalo = Color.black.opacity(0.35)
        
        /// Control surface frosted glass
        public static let controlSurface = Color(white: 0.12, opacity: 0.65)
        
        /// Shutter outer ring
        public static let shutterRing = Color.white.opacity(0.85)
        public static let shutterCore = Color.white
    }
    
    // MARK: - Typography
    public enum Typography {
        public static let focalButton = Font.system(size: 13, weight: .bold, design: .rounded)
        public static let coachPill = Font.system(size: 13, weight: .semibold, design: .default)
        public static let ruleLabel = Font.system(size: 12, weight: .medium, design: .default)
        public static let degreeLabel = Font.system(size: 11, weight: .semibold, design: .monospaced)
    }
    
    // MARK: - Haptic Feedback Engine
    public enum Haptics {
        public static func snapLevel() {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.prepare()
            generator.impactOccurred(intensity: 0.9)
        }
        
        public static func shutterSnap() {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 1.0)
        }
        
        public static func selectionChanged() {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}
