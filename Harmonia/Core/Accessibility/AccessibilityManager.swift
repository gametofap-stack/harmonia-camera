import Foundation
import UIKit
import SwiftUI

/// Accessibility and VoiceOver coordinator adhering to Apple Human Interface Guidelines.
/// Provides spoken telemetry, screen reader announcements, and semantic accessibility descriptions.
public enum AccessibilityManager {
    
    // MARK: - VoiceOver Spoken Announcements
    public static func announceRuleChanged(_ rule: CompositionRule) {
        let announcement = "Active composition framework: \(rule.rawValue). \(description(for: rule))"
        postAnnouncement(announcement)
    }
    
    public static func announceLevelLocked() {
        postAnnouncement("Horizon level locked at zero degrees.")
    }
    
    public static func announceFocalLengthChanged(_ focal: AppConfiguration.FocalLength) {
        postAnnouncement("Lens switched to \(focal.label), \(focal.focalEquivalent) equivalent.")
    }
    
    public static func announceSmartCoachSuggestion(_ recommendation: SmartCoachRecommendation) {
        let announcement = "Smart Coach suggests: \(recommendation.suggestedRule.rawValue) with \(recommendation.suggestedFocalLength.label) lens."
        postAnnouncement(announcement)
    }
    
    private static func postAnnouncement(_ text: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }
    
    // MARK: - Semantic Rule Descriptions for Blind & Low-Vision Users
    public static func description(for rule: CompositionRule) -> String {
        switch rule {
        case .ruleOfThirds:
            return "Divides frame into nine equal rectangles with four power-point intersections for asymmetrical balance."
        case .harmonicArmature:
            return "Fourteen-line classical Renaissance grid connecting all corners, midpoints, and reciprocal diagonals."
        case .fibonacciSpiral:
            return "Logarithmic golden spiral curling into an off-center focal point based on the golden ratio."
        case .phiGrid:
            return "Golden ratio grid with a narrower center column for natural balance."
        case .goldenTriangles:
            return "Diagonal corner line with two right-angle perpendicular lines creating four dynamic triangles."
        case .dynamicSymmetry:
            return "Baroque and sinister intersecting diagonals creating rhythmic multi-subject balance."
        case .symmetry:
            return "Centered vertical and horizontal crosshairs for reflections and architectural balance."
        case .vanishingPoint:
            return "Linear perspective lines radiating from a single horizon point for dramatic depth."
        case .leadingLines:
            return "Diagonal pathway lines leading inward from bottom corners toward the subject."
        case .framingDepth:
            return "Inner border frame with corner brackets for shooting through foreground elements."
        case .landscapeDepth:
            return "Three horizontal layers separating foreground, midground, and background."
        case .fillTheFrame:
            return "Tight subject margin boundaries to eliminate distracting backgrounds."
        case .negativeSpace:
            return "Asymmetrical focal zone offset by open breathing space."
        case .linesAndPatterns:
            return "Rhythmic parallel diagonal lines for architectural facades and repetitive textures."
        case .leftToRight:
            return "Narrative visual flow sweeping from lower-left to upper-right following natural reading motion."
        }
    }
}
