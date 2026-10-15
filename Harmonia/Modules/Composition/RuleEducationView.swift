import SwiftUI

/// Educational encyclopedia and micro-coaching guide for all 15 composition rules.
/// Details historical origins (Renaissance, Golden Ratio), practical use-cases, and pro photographer tips.
public struct RuleEducationView: View {
    let rule: CompositionRule
    @Environment(\.dismiss) private var dismiss
    
    public init(rule: CompositionRule) {
        self.rule = rule
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Banner with Vector Visual
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(white: 0.12))
                            .frame(height: 180)
                        
                        thumbnailShape(for: rule)
                            .stroke(AppTheme.Colors.appleGold, lineWidth: 2)
                            .frame(width: 200, height: 140)
                    }
                    .padding(.top, 10)
                    
                    // Title & Category
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.category.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.Colors.appleGold)
                        
                        Text(rule.rawValue)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    // Historical Origin & Art Background
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Art History & Origin", systemImage: "book.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(historicalBackground(for: rule))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                    }
                    
                    // Best Scenarios
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Ideal Photographic Subjects", systemImage: "camera.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(idealSubjects(for: rule))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                    }
                    
                    // Pro Advice
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Principal Architect's Field Tip", systemImage: "lightbulb.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.appleGold)
                        
                        Text(fieldTip(for: rule))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                    }
                }
                .padding(20)
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.06).ignoresSafeArea())
            .navigationTitle("Rule Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.Colors.appleGold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Educational Knowledge Base
    private func historicalBackground(for rule: CompositionRule) -> String {
        switch rule {
        case .ruleOfThirds:
            return "First codified in 1797 by painter John Thomas Smith in 'Remarks on Rural Scenery'. Smith observed that dividing an artwork into 9 parts creates infinitely more aesthetic tension than placing subjects in the center."
        case .harmonicArmature:
            return "Used since the High Renaissance by masters including Leonardo da Vinci, Raphael, and later Edgar Degas. It uses the 14 fundamental diagonals and reciprocals of the frame to lock every subject into mathematical harmony."
        case .fibonacciSpiral:
            return "Derived from the Golden Ratio (phi ≈ 1.618), recognized since ancient Greece and formulated by Leonardo of Pisa (Fibonacci) in 1202. The logarithmic spiral mirrors natural organic growth patterns in shells, galaxies, and human faces."
        case .phiGrid:
            return "A golden-ratio alternative to the Rule of Thirds, dividing the canvas in a 1 : 0.618 : 1 ratio. It creates a subtler, more organic compositional balance favoured by classical portrait painters."
        case .goldenTriangles:
            return "Rooted in classical Greek geometric proportion, this rule introduces dynamic diagonal energy by dropping 90° perpendicular vectors across a main corner-to-corner diagonal."
        case .vanishingPoint:
            return "Pioneered in Florence by architect Filippo Brunelleschi around 1415, one-point perspective creates the optical illusion of 3D depth on a flat 2D plane by converging lines toward the horizon."
        case .symmetry:
            return "A timeless aesthetic principle present in classical Roman architecture and religious iconography, instilling a profound sense of calm, authority, and formal balance."
        default:
            return "A foundational compositional principle developed across centuries of visual arts to guide human visual perception and direct focal attention."
        }
    }
    
    private func idealSubjects(for rule: CompositionRule) -> String {
        switch rule {
        case .ruleOfThirds: return "Portraits, environmental portraits, trees, street photography, and single subjects in landscapes."
        case .harmonicArmature: return "Complex group portraits, architectural scenes, fine-art compositions, and multi-layered street shots."
        case .fibonacciSpiral: return "Close-up portraits, curving staircases, waves, flowers, architectural spirals, and dynamic motion."
        case .vanishingPoint: return "Long hallways, tree-lined avenues, bridges, highways, train tracks, and urban canyons."
        case .symmetry: return "Water reflections, cathedral ceilings, centered doorways, arches, and minimalist geometric portraits."
        case .landscapeDepth: return "Mountain vistas, ocean shorelines, and desert panoramas with prominent foreground foreground interest."
        case .fillTheFrame: return "Macro photography, textures, close-up facial crops, and food details."
        case .negativeSpace: return "Minimalist fine art, lone subjects in expansive skies, mist, snowfields, and calm open water."
        default: return "Universal visual storytelling across diverse lighting conditions."
        }
    }
    
    private func fieldTip(for rule: CompositionRule) -> String {
        switch rule {
        case .ruleOfThirds: return "Align the subject's primary eye on the upper intersection point. Never let the horizon cut exactly across the center unless deliberate."
        case .harmonicArmature: return "Use this when you have 3 or more subjects. Place key eyes or hand gestures along the reciprocal diagonals to connect them visually."
        case .fibonacciSpiral: return "Switch to the iPhone 15's 2x lens (52mm). Place the spiral's tight eye directly over the subject's lead iris to create an irresistible visual pull."
        case .vanishingPoint: return "Switch to 0.5x Ultra-Wide, lower the phone slightly below waist height, and anchor the vanishing point near the optical center."
        case .symmetry: return "Make sure your CoreMotion horizon level is snapped at exactly 0.0° green. Symmetrical photos look jarring if tilted even by 1 degree."
        default: return "Combine this framework with the built-in horizon level for maximum visual impact."
        }
    }
    
    private func thumbnailShape(for rule: CompositionRule) -> AnyShape {
        switch rule {
        case .ruleOfThirds: return AnyShape(RuleOfThirdsShape())
        case .harmonicArmature: return AnyShape(HarmonicArmatureShape())
        case .fibonacciSpiral: return AnyShape(FibonacciSpiralShape())
        case .phiGrid: return AnyShape(PhiGridShape())
        case .goldenTriangles: return AnyShape(GoldenTrianglesShape())
        case .dynamicSymmetry: return AnyShape(DynamicSymmetryShape())
        case .symmetry: return AnyShape(SymmetryShape())
        case .vanishingPoint: return AnyShape(VanishingPointShape())
        case .leadingLines: return AnyShape(LeadingLinesShape())
        case .framingDepth: return AnyShape(FramingDepthShape())
        case .landscapeDepth: return AnyShape(LandscapeDepthShape())
        case .fillTheFrame: return AnyShape(FillTheFrameShape())
        case .negativeSpace: return AnyShape(NegativeSpaceShape())
        case .linesAndPatterns: return AnyShape(LinesAndPatternsShape())
        case .leftToRight: return AnyShape(LeftToRightShape())
        }
    }
}
