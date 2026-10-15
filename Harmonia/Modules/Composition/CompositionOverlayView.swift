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
    @ViewBuilder
    private var activeShapeView: some Shape {
        switch environment.activeRule {
        case .ruleOfThirds:
            RuleOfThirdsShape()
        case .harmonicArmature:
            HarmonicArmatureShape()
        case .fibonacciSpiral:
            FibonacciSpiralShape()
        case .phiGrid:
            PhiGridShape()
        case .goldenTriangles:
            GoldenTrianglesShape()
        case .dynamicSymmetry:
            DynamicSymmetryShape()
        case .symmetry:
            SymmetryShape()
        case .vanishingPoint:
            VanishingPointShape()
        case .leadingLines:
            LeadingLinesShape()
        case .framingDepth:
            FramingDepthShape()
        case .landscapeDepth:
            LandscapeDepthShape()
        case .fillTheFrame:
            FillTheFrameShape()
        case .negativeSpace:
            NegativeSpaceShape()
        case .linesAndPatterns:
            LinesAndPatternsShape()
        case .leftToRight:
            LeftToRightShape()
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
