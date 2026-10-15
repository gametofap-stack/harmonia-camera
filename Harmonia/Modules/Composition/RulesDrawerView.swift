import SwiftUI

/// Bottom sheet drawer providing categorized browsing, selection, and customization
/// across all 15 classical and modern composition frameworks.
public struct RulesDrawerView: View {
    @ObservedObject var environment: AppEnvironment
    @Binding var isPresented: Bool
    @State private var selectedEducationRule: CompositionRule?
    
    public init(environment: AppEnvironment, isPresented: Binding<Bool>) {
        self.environment = environment
        self._isPresented = isPresented
    }
    
    private let categories = [
        "Standard Grids",
        "Classical & Fine Art",
        "Perspective & Geometry",
        "Visual Flow & Space"
    ]
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Drag Indicator
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)
            
            // Title & Close Button
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Composition Frameworks")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("15 artistic rules for framing and visual balance")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Style Customization Bar (Color & Opacity)
            styleCustomizationBar
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            
            // Dual-Save Reference Toggle for Artists and Review
            Toggle(isOn: $environment.shouldBakeCompositionReference) {
                HStack(spacing: 8) {
                    Image(systemName: "square.2.layers.3d")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.appleGold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Save Composition Reference Copy")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Saves an annotated copy with the guide lines baked in")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .tint(AppTheme.Colors.appleGold)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Categorized Rules List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(categories, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(category.uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.Colors.appleGold)
                                .padding(.horizontal, 20)
                            
                            let rules = CompositionRule.allCases.filter { $0.category == category }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(rules) { rule in
                                        RuleCard(
                                            rule: rule,
                                            isSelected: environment.activeRule == rule,
                                            lineColor: environment.lineStyle.colorType,
                                            onSelect: { environment.selectRule(rule) },
                                            onInfoTap: { selectedEducationRule = rule }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .background(
            Color(red: 0.08, green: 0.08, blue: 0.09)
                .ignoresSafeArea()
        )
        .presentationDetents([.medium, .fraction(0.85)])
        .presentationDragIndicator(.hidden)
        .sheet(item: $selectedEducationRule) { rule in
            RuleEducationView(rule: rule)
        }
    }
    
    // MARK: - Style Customization Bar
    private var styleCustomizationBar: some View {
        HStack(spacing: 16) {
            Text("Guide Color:")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            ForEach(LineStyle.LineColor.allCases, id: \.self) { colorType in
                Button(action: {
                    AppTheme.Haptics.selectionChanged()
                    environment.lineStyle.colorType = colorType
                }) {
                    Circle()
                        .fill(colorFor(colorType))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: environment.lineStyle.colorType == colorType ? 2.5 : 0)
                        )
                }
            }
            
            Spacer()
            
            // Quick Flip & Rotate in Drawer
            HStack(spacing: 12) {
                Button(action: { environment.flipHorizontal() }) {
                    Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(environment.isFlippedHorizontally ? AppTheme.Colors.appleGold : .white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: { environment.rotate90Degrees() }) {
                    Image(systemName: "rotate.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func colorFor(_ type: LineStyle.LineColor) -> Color {
        switch type {
        case .studioRed: return AppTheme.Colors.studioRed
        case .appleGold: return AppTheme.Colors.appleGold
        case .polarWhite: return AppTheme.Colors.polarWhite
        }
    }
}

// MARK: - Rule Card Component
private struct RuleCard: View {
    let rule: CompositionRule
    let isSelected: Bool
    let lineColor: LineStyle.LineColor
    let onSelect: () -> Void
    let onInfoTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onSelect) {
                // Mini Thumbnail Vector Representation
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 90, height: 68)
                    
                    thumbnailShape(for: rule)
                        .stroke(
                            isSelected ? resolvedColor : Color.white.opacity(0.4),
                            lineWidth: isSelected ? 1.5 : 1.0
                        )
                        .frame(width: 74, height: 54)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ? AppTheme.Colors.appleGold : Color.white.opacity(0.1),
                            lineWidth: isSelected ? 2.0 : 1.0
                        )
                )
            }
            
            // Rule Title & Info Button
            HStack(spacing: 4) {
                Text(rule.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    .lineLimit(1)
                
                Button(action: onInfoTap) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.Colors.appleGold.opacity(0.8))
                }
            }
            .frame(width: 90)
        }
    }
    
    private var resolvedColor: Color {
        switch lineColor {
        case .studioRed: return AppTheme.Colors.studioRed
        case .appleGold: return AppTheme.Colors.appleGold
        case .polarWhite: return AppTheme.Colors.polarWhite
        }
    }
    
    @ViewBuilder
    private func thumbnailShape(for rule: CompositionRule) -> some Shape {
        switch rule {
        case .ruleOfThirds: RuleOfThirdsShape()
        case .harmonicArmature: HarmonicArmatureShape()
        case .fibonacciSpiral: FibonacciSpiralShape()
        case .phiGrid: PhiGridShape()
        case .goldenTriangles: GoldenTrianglesShape()
        case .dynamicSymmetry: DynamicSymmetryShape()
        case .symmetry: SymmetryShape()
        case .vanishingPoint: VanishingPointShape()
        case .leadingLines: LeadingLinesShape()
        case .framingDepth: FramingDepthShape()
        case .landscapeDepth: LandscapeDepthShape()
        case .fillTheFrame: FillTheFrameShape()
        case .negativeSpace: NegativeSpaceShape()
        case .linesAndPatterns: LinesAndPatternsShape()
        case .leftToRight: LeftToRightShape()
        }
    }
}
