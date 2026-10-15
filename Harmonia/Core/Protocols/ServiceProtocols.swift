import Foundation
import CoreGraphics
import AVFoundation

// MARK: - Camera Service Protocol
public protocol CameraServiceProtocol: AnyObject {
    var isRunning: Bool { get }
    var currentFocalLength: AppConfiguration.FocalLength { get }
    var isTorchActive: Bool { get }
    
    func startSession() async throws
    func stopSession() async
    func setFocalLength(_ focalLength: AppConfiguration.FocalLength) async throws
    func toggleTorch() async throws
    func capturePhoto(bakeComposition: Bool) async throws
}

// MARK: - Composition Service Protocol
public protocol CompositionServiceProtocol: AnyObject {
    var activeRule: CompositionRule { get set }
    var isFlippedHorizontally: Bool { get set }
    var isFlippedVertically: Bool { get set }
    var rotationAngleDegrees: Double { get set }
    var lineStyle: LineStyle { get set }
    
    func flipHorizontal()
    func flipVertical()
    func rotate90Degrees()
    func resetTransforms()
}

// MARK: - Motion Service Protocol
public protocol MotionServiceProtocol: AnyObject {
    var pitchDegrees: Double { get }
    var rollDegrees: Double { get }
    var isLevel: Bool { get }
    var cameraStance: CameraStance { get }
    
    func startMotionUpdates()
    func stopMotionUpdates()
}

// MARK: - Intelligence / Smart Coach Protocol
public protocol IntelligenceServiceProtocol: AnyObject {
    var isSmartCoachEnabled: Bool { get set }
    var currentRecommendation: SmartCoachRecommendation? { get }
    
    func analyzePixelBuffer(_ pixelBuffer: CVPixelBuffer) async
}

// MARK: - Common Data Contracts
public enum CompositionRule: String, CaseIterable, Identifiable {
    case ruleOfThirds = "Rule of Thirds"
    case harmonicArmature = "Harmonic Armature"
    case fibonacciSpiral = "Fibonacci Spiral"
    case phiGrid = "Phi Grid"
    case goldenTriangles = "Golden Triangles"
    case dynamicSymmetry = "Dynamic Symmetry"
    case symmetry = "Symmetry"
    case vanishingPoint = "Vanishing Point"
    case leadingLines = "Leading Lines"
    case framingDepth = "Framing Depth"
    case landscapeDepth = "Landscape Depth"
    case fillTheFrame = "Fill the Frame"
    case negativeSpace = "Negative Space"
    case linesAndPatterns = "Lines & Patterns"
    case leftToRight = "Left to Right"
    
    public var id: String { rawValue }
    
    public var category: String {
        switch self {
        case .ruleOfThirds, .phiGrid, .symmetry:
            return "Standard Grids"
        case .harmonicArmature, .dynamicSymmetry, .goldenTriangles:
            return "Classical & Fine Art"
        case .fibonacciSpiral, .vanishingPoint, .leadingLines:
            return "Perspective & Geometry"
        case .framingDepth, .landscapeDepth, .fillTheFrame, .negativeSpace, .linesAndPatterns, .leftToRight:
            return "Visual Flow & Space"
        }
    }
}

public enum CameraStance: String {
    case neutral = "Eye Level"
    case lowAngle = "Low Angle (Worm's-Eye)"
    case highAngle = "High Angle (Bird's-Eye)"
    case flatLay = "Flat-Lay (Top-Down)"
}

public struct SmartCoachRecommendation: Equatable {
    public let suggestedRule: CompositionRule
    public let suggestedFocalLength: AppConfiguration.FocalLength
    public let confidenceScore: Double // 0.0 to 1.0
    public let rationale: String
    
    public init(
        suggestedRule: CompositionRule,
        suggestedFocalLength: AppConfiguration.FocalLength,
        confidenceScore: Double,
        rationale: String
    ) {
        self.suggestedRule = suggestedRule
        self.suggestedFocalLength = suggestedFocalLength
        self.confidenceScore = confidenceScore
        self.rationale = rationale
    }
}

public struct LineStyle: Equatable {
    public var colorType: LineColor
    public var strokeWidth: CGFloat
    public var opacity: Double
    
    public enum LineColor: String, CaseIterable {
        case studioRed = "Studio Red"
        case appleGold = "Apple Gold"
        case polarWhite = "Polar White"
    }
    
    public static let `default` = LineStyle(
        colorType: .studioRed,
        strokeWidth: 1.5,
        opacity: 0.85
    )
}
