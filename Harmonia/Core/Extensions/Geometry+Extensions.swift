import Foundation
import CoreGraphics

public extension CGRect {
    /// Returns a point in absolute canvas space given a normalized unit coordinate (0.0 ... 1.0).
    func pointAt(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(
            x: minX + (width * x),
            y: minY + (height * y)
        )
    }
    
    /// The Golden Ratio constant (Phi = ~1.6180339887)
    static let phi: CGFloat = 1.6180339887
    
    /// Reciprocal of Phi (~0.6180339887)
    static let phiReciprocal: CGFloat = 1.0 / phi
}

public extension CGPoint {
    /// Applies horizontal flip within a normalized (0...1) unit box.
    func flippedHorizontally() -> CGPoint {
        CGPoint(x: 1.0 - x, y: y)
    }
    
    /// Applies vertical flip within a normalized (0...1) unit box.
    func flippedVertically() -> CGPoint {
        CGPoint(x: x, y: 1.0 - y)
    }
    
    /// Rotates point 90 degrees clockwise around center (0.5, 0.5) in unit space.
    func rotated90Clockwise() -> CGPoint {
        let cx: CGFloat = 0.5
        let cy: CGFloat = 0.5
        let relX = x - cx
        let relY = y - cy
        return CGPoint(x: cx - relY, y: cy + relX)
    }
}
