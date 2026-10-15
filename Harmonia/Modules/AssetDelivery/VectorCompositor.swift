import Foundation
import UIKit
import CoreGraphics

/// Precision rasterization engine that draws normalized vector composition frameworks
/// and telemetry overlays directly into high-resolution pixel buffers (up to 48MP: 8064 x 6048).
public enum VectorCompositor {
    
    /// Bakes the active composition rule and telemetry metadata onto a captured photo.
    public static func bakeCompositionOverlay(
        onto baseImage: UIImage,
        rule: CompositionRule,
        lineStyle: LineStyle,
        isFlippedHorizontally: Bool,
        isFlippedVertically: Bool,
        rotationDegrees: Double,
        horizonRollDegrees: Double,
        focalLength: AppConfiguration.FocalLength
    ) -> UIImage {
        let size = baseImage.size
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Render at 1:1 sensor pixel fidelity
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        let outputImage = renderer.image { context in
            let cgContext = context.cgContext
            
            // 1. Draw base photo
            baseImage.draw(at: .zero)
            
            // 2. Set up transformed coordinate space for vector overlay
            cgContext.saveGState()
            
            // Move origin to center for rotation and flips
            cgContext.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            
            // Apply scale/flip
            cgContext.scaleBy(
                x: isFlippedHorizontally ? -1.0 : 1.0,
                y: isFlippedVertically ? -1.0 : 1.0
            )
            
            // Apply rotation
            cgContext.rotate(by: CGFloat(rotationDegrees * .pi / 180.0))
            
            // Move origin back to top-left of the image bounds
            cgContext.translateBy(x: -size.width * 0.5, y: -size.height * 0.5)
            
            // Draw composition rule path
            drawCompositionPath(rule: rule, in: CGRect(origin: .zero, size: size), lineStyle: lineStyle, context: cgContext)
            
            cgContext.restoreGState()
            
            // 3. Draw Watermark / Telemetry Badge in bottom-left corner
            drawTelemetryStamp(
                rule: rule,
                focalLength: focalLength,
                horizonRoll: horizonRollDegrees,
                imageSize: size,
                context: cgContext
            )
        }
        
        return outputImage
    }
    
    // MARK: - Vector Path Drawing
    private static func drawCompositionPath(
        rule: CompositionRule,
        in rect: CGRect,
        lineStyle: LineStyle,
        context: CGContext
    ) {
        let w = rect.width
        let h = rect.height
        
        // Anti-glare shadow pass (outer dark halo)
        context.setStrokeColor(UIColor.black.withAlphaComponent(0.45).cgColor)
        context.setLineWidth(rect.width * 0.0035 + 2.0)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        appendRulePaths(rule: rule, w: w, h: h, context: context)
        context.strokePath()
        
        // Primary vibrant color stroke pass
        let strokeColor: UIColor
        switch lineStyle.colorType {
        case .studioRed: strokeColor = UIColor(red: 0.95, green: 0.20, blue: 0.20, alpha: 0.9)
        case .appleGold: strokeColor = UIColor(red: 0.98, green: 0.78, blue: 0.25, alpha: 0.9)
        case .polarWhite: strokeColor = UIColor.white.withAlphaComponent(0.9)
        }
        
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(rect.width * 0.0035) // Scales proportionally with resolution
        
        appendRulePaths(rule: rule, w: w, h: h, context: context)
        context.strokePath()
    }
    
    private static func appendRulePaths(rule: CompositionRule, w: CGFloat, h: CGFloat, context: CGContext) {
        switch rule {
        case .ruleOfThirds:
            context.move(to: CGPoint(x: w / 3.0, y: 0)); context.addLine(to: CGPoint(x: w / 3.0, y: h))
            context.move(to: CGPoint(x: 2.0 * w / 3.0, y: 0)); context.addLine(to: CGPoint(x: 2.0 * w / 3.0, y: h))
            context.move(to: CGPoint(x: 0, y: h / 3.0)); context.addLine(to: CGPoint(x: w, y: h / 3.0))
            context.move(to: CGPoint(x: 0, y: 2.0 * h / 3.0)); context.addLine(to: CGPoint(x: w, y: 2.0 * h / 3.0))
            
        case .symmetry:
            context.move(to: CGPoint(x: w * 0.5, y: 0)); context.addLine(to: CGPoint(x: w * 0.5, y: h))
            context.move(to: CGPoint(x: 0, y: h * 0.5)); context.addLine(to: CGPoint(x: w, y: h * 0.5))
            context.addEllipse(in: CGRect(x: w * 0.5 - 40, y: h * 0.5 - 40, width: 80, height: 80))
            
        case .harmonicArmature:
            context.move(to: CGPoint(x: 0, y: 0)); context.addLine(to: CGPoint(x: w, y: h))
            context.move(to: CGPoint(x: w, y: 0)); context.addLine(to: CGPoint(x: 0, y: h))
            context.move(to: CGPoint(x: w * 0.5, y: 0)); context.addLine(to: CGPoint(x: w * 0.5, y: h))
            context.move(to: CGPoint(x: 0, y: h * 0.5)); context.addLine(to: CGPoint(x: w, y: h * 0.5))
            context.move(to: CGPoint(x: 0, y: 0)); context.addLine(to: CGPoint(x: w * 0.5, y: h))
            context.move(to: CGPoint(x: w, y: 0)); context.addLine(to: CGPoint(x: w * 0.5, y: h))
            context.move(to: CGPoint(x: 0, y: h)); context.addLine(to: CGPoint(x: w * 0.5, y: 0))
            context.move(to: CGPoint(x: w, y: h)); context.addLine(to: CGPoint(x: w * 0.5, y: 0))
            
        case .vanishingPoint:
            let vp = CGPoint(x: w * 0.5, y: h * 0.45)
            context.move(to: CGPoint(x: 0, y: vp.y)); context.addLine(to: CGPoint(x: w, y: vp.y))
            context.move(to: vp); context.addLine(to: CGPoint(x: 0, y: h))
            context.move(to: vp); context.addLine(to: CGPoint(x: w * 0.25, y: h))
            context.move(to: vp); context.addLine(to: CGPoint(x: w * 0.5, y: h))
            context.move(to: vp); context.addLine(to: CGPoint(x: w * 0.75, y: h))
            context.move(to: vp); context.addLine(to: CGPoint(x: w, y: h))
            
        default:
            // Standard Thirds fallback for other geometries
            context.move(to: CGPoint(x: w / 3.0, y: 0)); context.addLine(to: CGPoint(x: w / 3.0, y: h))
            context.move(to: CGPoint(x: 2.0 * w / 3.0, y: 0)); context.addLine(to: CGPoint(x: 2.0 * w / 3.0, y: h))
            context.move(to: CGPoint(x: 0, y: h / 3.0)); context.addLine(to: CGPoint(x: w, y: h / 3.0))
            context.move(to: CGPoint(x: 0, y: 2.0 * h / 3.0)); context.addLine(to: CGPoint(x: w, y: 2.0 * h / 3.0))
        }
    }
    
    // MARK: - Telemetry Stamp
    private static func drawTelemetryStamp(
        rule: CompositionRule,
        focalLength: AppConfiguration.FocalLength,
        horizonRoll: Double,
        imageSize: CGSize,
        context: CGContext
    ) {
        let stampText = "HARMONIA · \(rule.rawValue.uppercased()) · \(focalLength.label) (\(focalLength.focalEquivalent)) · \(String(format: "%+.1f°", -horizonRoll))"
        let fontSize = max(imageSize.width * 0.016, 18.0)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.85),
            .strokeColor: UIColor.black.withAlphaComponent(0.6),
            .strokeWidth: -2.0
        ]
        
        let attributedString = NSAttributedString(string: stampText, attributes: attributes)
        let margin: CGFloat = imageSize.width * 0.04
        let origin = CGPoint(x: margin, y: imageSize.height - margin - fontSize * 1.5)
        
        attributedString.draw(at: origin)
    }
}
