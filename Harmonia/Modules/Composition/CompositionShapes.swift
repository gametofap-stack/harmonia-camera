import SwiftUI
import CoreGraphics

// MARK: - 1. Rule of Thirds Shape
public struct RuleOfThirdsShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Vertical lines
        path.move(to: CGPoint(x: w / 3.0, y: 0))
        path.addLine(to: CGPoint(x: w / 3.0, y: h))
        path.move(to: CGPoint(x: 2.0 * w / 3.0, y: 0))
        path.addLine(to: CGPoint(x: 2.0 * w / 3.0, y: h))
        
        // Horizontal lines
        path.move(to: CGPoint(x: 0, y: h / 3.0))
        path.addLine(to: CGPoint(x: w, y: h / 3.0))
        path.move(to: CGPoint(x: 0, y: 2.0 * h / 3.0))
        path.addLine(to: CGPoint(x: w, y: 2.0 * h / 3.0))
        
        return path
    }
}

// MARK: - 2. Harmonic Armature (The Classical 14-Line Web)
public struct HarmonicArmatureShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let tl = CGPoint(x: 0, y: 0)
        let tr = CGPoint(x: w, y: 0)
        let bl = CGPoint(x: 0, y: h)
        let br = CGPoint(x: w, y: h)
        
        let midTop = CGPoint(x: w * 0.5, y: 0)
        let midBottom = CGPoint(x: w * 0.5, y: h)
        let midLeft = CGPoint(x: 0, y: h * 0.5)
        let midRight = CGPoint(x: w, y: h * 0.5)
        
        // 1 & 2. Main Corner Diagonals
        path.move(to: tl); path.addLine(to: br)
        path.move(to: tr); path.addLine(to: bl)
        
        // 3 & 4. Edge Midpoint Bisectors
        path.move(to: midTop); path.addLine(to: midBottom)
        path.move(to: midLeft); path.addLine(to: midRight)
        
        // 5, 6, 7, 8. Corner to Opposite Edge Midpoints (Harmonic Reciprocals)
        path.move(to: tl); path.addLine(to: midBottom)
        path.move(to: tr); path.addLine(to: midBottom)
        path.move(to: bl); path.addLine(to: midTop)
        path.move(to: br); path.addLine(to: midTop)
        
        // 9, 10, 11, 12. Corner to Side Midpoints
        path.move(to: tl); path.addLine(to: midRight)
        path.move(to: bl); path.addLine(to: midRight)
        path.move(to: tr); path.addLine(to: midLeft)
        path.move(to: br); path.addLine(to: midLeft)
        
        // 13 & 14. Inner Diamond
        path.move(to: midTop); path.addLine(to: midRight)
        path.addLine(to: midBottom); path.addLine(to: midLeft)
        path.closeSubpath()
        
        return path
    }
}

// MARK: - 3. Fibonacci Spiral (Golden Spiral)
public struct FibonacciSpiralShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Bounding Golden Rectangles & Spiral Arc
        // Golden Ratio subdivisions:
        let phi = CGRect.phiReciprocal // ~0.618
        
        var currentRect = CGRect(x: 0, y: 0, width: w, height: h)
        
        // Approximate the logarithmic curve through 7 golden rectangle steps
        var originX = 0.0
        var originY = 0.0
        var currentW = w
        var currentH = h
        
        // Step 1: Left Square
        let sq1W = currentH
        path.addArc(center: CGPoint(x: sq1W, y: currentH), radius: sq1W, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        // Golden rectangles outline
        path.move(to: CGPoint(x: w * phi, y: 0))
        path.addLine(to: CGPoint(x: w * phi, y: h))
        path.move(to: CGPoint(x: w * phi, y: h * (1.0 - phi)))
        path.addLine(to: CGPoint(x: w, y: h * (1.0 - phi)))
        
        // Draw the iconic continuous golden spiral
        path.move(to: CGPoint(x: 0, y: h))
        path.addCurve(
            to: CGPoint(x: w * phi, y: 0),
            control1: CGPoint(x: 0, y: h * 0.45),
            control2: CGPoint(x: w * 0.25, y: 0)
        )
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.62),
            control1: CGPoint(x: w * 0.85, y: 0),
            control2: CGPoint(x: w, y: h * 0.35)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.65, y: h),
            control1: CGPoint(x: w, y: h * 0.85),
            control2: CGPoint(x: w * 0.85, y: h)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.58, y: h * 0.68),
            control1: CGPoint(x: w * 0.55, y: h),
            control2: CGPoint(x: w * 0.55, y: h * 0.75)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.68, y: h * 0.60),
            control1: CGPoint(x: w * 0.60, y: h * 0.62),
            control2: CGPoint(x: w * 0.65, y: h * 0.60)
        )
        
        return path
    }
}

// MARK: - 4. Phi Grid
public struct PhiGridShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let p1 = 0.3819660113 // 1 - (1 / 1.6180339887)
        let p2 = 0.6180339887 // 1 / 1.6180339887
        
        // Vertical lines
        path.move(to: CGPoint(x: w * p1, y: 0))
        path.addLine(to: CGPoint(x: w * p1, y: h))
        path.move(to: CGPoint(x: w * p2, y: 0))
        path.addLine(to: CGPoint(x: w * p2, y: h))
        
        // Horizontal lines
        path.move(to: CGPoint(x: 0, y: h * p1))
        path.addLine(to: CGPoint(x: w, y: h * p1))
        path.move(to: CGPoint(x: 0, y: h * p2))
        path.addLine(to: CGPoint(x: w, y: h * p2))
        
        return path
    }
}

// MARK: - 5. Golden Triangles
public struct GoldenTrianglesShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Main corner diagonal
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w, y: 0))
        
        // Perpendicular lines from remaining corners meeting diagonal at 90°
        // For a rectangle with aspect ratio R = h/w, intersection point of perpendicular from (0,0):
        let r = h / w
        let x1 = (r * r) / (1 + r * r) * w
        let y1 = h - (x1 * (h / w))
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.36))
        
        path.move(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.64))
        
        return path
    }
}

// MARK: - 6. Dynamic Symmetry
public struct DynamicSymmetryShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Baroque & Sinister Diagonals
        path.move(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: w, y: h))
        path.move(to: CGPoint(x: 0, y: h)); path.addLine(to: CGPoint(x: w, y: 0))
        
        // Reciprocal intersections
        path.move(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.36))
        path.move(to: CGPoint(x: w, y: 0)); path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.36))
        path.move(to: CGPoint(x: 0, y: h)); path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.64))
        path.move(to: CGPoint(x: w, y: h)); path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.64))
        
        // Vertical and horizontal inner eyes
        path.move(to: CGPoint(x: w * 0.36, y: 0)); path.addLine(to: CGPoint(x: w * 0.36, y: h))
        path.move(to: CGPoint(x: w * 0.64, y: 0)); path.addLine(to: CGPoint(x: w * 0.64, y: h))
        
        return path
    }
}

// MARK: - 7. Symmetry
public struct SymmetryShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Vertical Centerline
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w * 0.5, y: h))
        
        // Horizontal Centerline
        path.move(to: CGPoint(x: 0, y: h * 0.5))
        path.addLine(to: CGPoint(x: w, y: h * 0.5))
        
        // Center crosshair ring
        let center = CGPoint(x: w * 0.5, y: h * 0.5)
        path.addEllipse(in: CGRect(x: center.x - 24, y: center.y - 24, width: 48, height: 48))
        
        return path
    }
}

// MARK: - 8. Vanishing Point (One-Point Perspective)
public struct VanishingPointShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let vp = CGPoint(x: w * 0.5, y: h * 0.45)
        
        // Horizon line
        path.move(to: CGPoint(x: 0, y: vp.y))
        path.addLine(to: CGPoint(x: w, y: vp.y))
        
        // Radiating perspective lines
        path.move(to: vp); path.addLine(to: CGPoint(x: 0, y: h))
        path.move(to: vp); path.addLine(to: CGPoint(x: w * 0.25, y: h))
        path.move(to: vp); path.addLine(to: CGPoint(x: w * 0.5, y: h))
        path.move(to: vp); path.addLine(to: CGPoint(x: w * 0.75, y: h))
        path.move(to: vp); path.addLine(to: CGPoint(x: w, y: h))
        
        // Upper radiating lines
        path.move(to: vp); path.addLine(to: CGPoint(x: 0, y: 0))
        path.move(to: vp); path.addLine(to: CGPoint(x: w, y: 0))
        
        // Center focal ring
        path.addEllipse(in: CGRect(x: vp.x - 8, y: vp.y - 8, width: 16, height: 16))
        
        return path
    }
}

// MARK: - 9. Leading Lines
public struct LeadingLinesShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Primary converging diagonal lines
        path.move(to: CGPoint(x: 0, y: h))
        path.addCurve(
            to: CGPoint(x: w * 0.48, y: h * 0.35),
            control1: CGPoint(x: w * 0.15, y: h * 0.75),
            control2: CGPoint(x: w * 0.35, y: h * 0.55)
        )
        
        path.move(to: CGPoint(x: w, y: h))
        path.addCurve(
            to: CGPoint(x: w * 0.52, y: h * 0.35),
            control1: CGPoint(x: w * 0.85, y: h * 0.75),
            control2: CGPoint(x: w * 0.65, y: h * 0.55)
        )
        
        // Secondary outer edge sweep
        path.move(to: CGPoint(x: 0, y: h * 0.70))
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.35))
        
        path.move(to: CGPoint(x: w, y: h * 0.70))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.35))
        
        return path
    }
}

// MARK: - 10. Framing Depth (Frame within a Frame)
public struct FramingDepthShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Inner frame boundary (15% inset)
        let insetX = w * 0.15
        let insetY = h * 0.15
        let innerRect = CGRect(x: insetX, y: insetY, width: w - (2 * insetX), height: h - (2 * insetY))
        path.addRect(innerRect)
        
        // Corner framing brackets
        let bracketSize: CGFloat = 24.0
        
        // Top-Left
        path.move(to: CGPoint(x: insetX, y: insetY + bracketSize))
        path.addLine(to: CGPoint(x: insetX, y: insetY))
        path.addLine(to: CGPoint(x: insetX + bracketSize, y: insetY))
        
        // Top-Right
        path.move(to: CGPoint(x: w - insetX - bracketSize, y: insetY))
        path.addLine(to: CGPoint(x: w - insetX, y: insetY))
        path.addLine(to: CGPoint(x: w - insetX, y: insetY + bracketSize))
        
        // Bottom-Left
        path.move(to: CGPoint(x: insetX, y: h - insetY - bracketSize))
        path.addLine(to: CGPoint(x: insetX, y: h - insetY))
        path.addLine(to: CGPoint(x: insetX + bracketSize, y: h - insetY))
        
        // Bottom-Right
        path.move(to: CGPoint(x: w - insetX - bracketSize, y: h - insetY))
        path.addLine(to: CGPoint(x: w - insetX, y: h - insetY))
        path.addLine(to: CGPoint(x: w - insetX, y: h - insetY - bracketSize))
        
        return path
    }
}

// MARK: - 11. Landscape Depth (3-Layer Foreground / Midground / Background)
public struct LandscapeDepthShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Horizon / Sky line (35% from top)
        path.move(to: CGPoint(x: 0, y: h * 0.35))
        path.addLine(to: CGPoint(x: w, y: h * 0.35))
        
        // Midground line (65% from top)
        path.move(to: CGPoint(x: 0, y: h * 0.65))
        path.addLine(to: CGPoint(x: w, y: h * 0.65))
        
        // Foreground anchor lines
        path.move(to: CGPoint(x: w * 0.30, y: h))
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.65))
        path.move(to: CGPoint(x: w * 0.70, y: h))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.65))
        
        return path
    }
}

// MARK: - 12. Fill the Frame
public struct FillTheFrameShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // 8% margin tight boundary
        let mX = w * 0.08
        let mY = h * 0.08
        let subjectBox = CGRect(x: mX, y: mY, width: w - 2 * mX, height: h - 2 * mY)
        path.addRect(subjectBox)
        
        // Corner emphasis markers
        let cLen: CGFloat = 32.0
        path.move(to: CGPoint(x: mX, y: mY + cLen))
        path.addLine(to: CGPoint(x: mX, y: mY))
        path.addLine(to: CGPoint(x: mX + cLen, y: mY))
        
        path.move(to: CGPoint(x: w - mX - cLen, y: mY))
        path.addLine(to: CGPoint(x: w - mX, y: mY))
        path.addLine(to: CGPoint(x: w - mX, y: mY + cLen))
        
        path.move(to: CGPoint(x: mX, y: h - mY - cLen))
        path.addLine(to: CGPoint(x: mX, y: h - mY))
        path.addLine(to: CGPoint(x: mX + cLen, y: h - mY))
        
        path.move(to: CGPoint(x: w - mX - cLen, y: h - mY))
        path.addLine(to: CGPoint(x: w - mX, y: h - mY))
        path.addLine(to: CGPoint(x: w - mX, y: h - mY - cLen))
        
        return path
    }
}

// MARK: - 13. Negative Space
public struct NegativeSpaceShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Focal subject cluster placed in the lower-right third
        let focalRect = CGRect(x: w * 0.60, y: h * 0.60, width: w * 0.35, height: h * 0.35)
        path.addRect(focalRect)
        
        // Breathing room guide lines spanning into empty space
        path.move(to: CGPoint(x: focalRect.minX, y: focalRect.minY))
        path.addLine(to: CGPoint(x: 0, y: focalRect.minY))
        
        path.move(to: CGPoint(x: focalRect.minX, y: focalRect.minY))
        path.addLine(to: CGPoint(x: focalRect.minX, y: 0))
        
        return path
    }
}

// MARK: - 14. Lines and Patterns
public struct LinesAndPatternsShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // 5 Parallel Diagonal Rhythm Lines
        let step = (w + h) / 6.0
        for i in 1...5 {
            let offset = CGFloat(i) * step
            path.move(to: CGPoint(x: offset - h, y: 0))
            path.addLine(to: CGPoint(x: offset, y: h))
        }
        
        return path
    }
}

// MARK: - 15. Left to Right
public struct LeftToRightShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Natural reading direction sweep (bottom-left to top-right)
        path.move(to: CGPoint(x: 0, y: h * 0.85))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.20),
            control1: CGPoint(x: w * 0.35, y: h * 0.80),
            control2: CGPoint(x: w * 0.65, y: h * 0.25)
        )
        
        // Directional anchor arrows
        path.move(to: CGPoint(x: w * 0.88, y: h * 0.16))
        path.addLine(to: CGPoint(x: w, y: h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.28))
        
        return path
    }
}
