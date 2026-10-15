import SwiftUI

/// Renders the active composition framework with dynamic anti-glare contrast,
/// affine spatial transformations (flip/rotate), and resolution independence.
public struct CompositionOverlayView: View {
    @ObservedObject var environment: AppEnvironment
    
    public init(environment: AppEnvironment) {
        self.environment = environment
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Anti-glare contrast background halo (black translucent stroke)
                activeShapeView
                    .stroke(
                        AppTheme.Colors.lineDarkHalo,
                        style: StrokeStyle(lineWidth: environment.lineStyle.strokeWidth + 2.0, lineCap: .round, lineJoin: .round)
                    )
                
                // Primary high-visibility foreground vector stroke
                activeShapeView
                    .stroke(
                        lineColor(for: environment.lineStyle.colorType),
                        style: StrokeStyle(lineWidth: environment.lineStyle.strokeWidth, lineCap: .round, lineJoin: .round)
                    )
            }
            .opacity(environment.lineStyle.opacity)
            // Spatial Transformations
            .scaleEffect(
                x: environment.isFlippedHorizontally ? -1.0 : 1.0,
                y: environment.isFlippedVertically ? -1.0 : 1.0,
                anchor: .center
            )
            .rotationEffect(.degrees(environment.rotationAngleDegrees), anchor: .center)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: environment.activeRule)
            .animation(.spring(response: 0.30, dampingFraction: 0.75), value: environment.isFlippedHorizontally)
            .animation(.spring(response: 0.30, dampingFraction: 0.75), value: environment.isFlippedVertically)
            .animation(.spring(response: 0.30, dampingFraction: 0.75), value: environment.rotationAngleDegrees)
        }
        .allowsHitTesting(false) // Camera gesture touches pass straight through to viewfinder
    }
    
    // MARK: - Active Shape Router
    private var activeShapeView: AnyShape {
        switch environment.activeRule {
        case .ruleOfThirds:
            return AnyShape(RuleOfThirdsShape())
        case .harmonicArmature:
            return AnyShape(HarmonicArmatureShape())
        case .fibonacciSpiral:
            return AnyShape(FibonacciSpiralShape())
        case .phiGrid:
            return AnyShape(PhiGridShape())
        case .goldenTriangles:
            return AnyShape(GoldenTrianglesShape())
        case .dynamicSymmetry:
            return AnyShape(DynamicSymmetryShape())
        case .symmetry:
            return AnyShape(SymmetryShape())
        case .vanishingPoint:
            return AnyShape(VanishingPointShape())
        case .leadingLines:
            return AnyShape(LeadingLinesShape())
        case .framingDepth:
            return AnyShape(FramingDepthShape())
        case .landscapeDepth:
            return AnyShape(LandscapeDepthShape())
        case .fillTheFrame:
            return AnyShape(FillTheFrameShape())
        case .negativeSpace:
            return AnyShape(NegativeSpaceShape())
        case .linesAndPatterns:
            return AnyShape(LinesAndPatternsShape())
        case .leftToRight:
            return AnyShape(LeftToRightShape())
        }
    }
    
    // MARK: - Color Resolver
    private func lineColor(for type: LineStyle.LineColor) -> Color {
        switch type {
        case .studioRed:
            return AppTheme.Colors.studioRed
        case .appleGold:
            return AppTheme.Colors.appleGold
        case .polarWhite:
            return AppTheme.Colors.polarWhite
        }
    }
}
