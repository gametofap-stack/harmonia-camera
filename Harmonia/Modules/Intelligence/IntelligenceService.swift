import Foundation
import Vision
import AVFoundation
import UIKit
import Combine

/// Neural Engine-accelerated intelligent composition analyzer.
/// Evaluates video frames at a throttled 10 Hz rate using Apple's Vision framework
/// to auto-suggest optimal composition rules, focal lengths, and camera angles.
public final class IntelligenceService: NSObject, ObservableObject, IntelligenceServiceProtocol {
    
    // MARK: - Published State
    @Published public var isSmartCoachEnabled: Bool = true
    @Published public private(set) var currentRecommendation: SmartCoachRecommendation?
    @Published public private(set) var detectedSalientPoint: CGPoint?
    @Published public private(set) var detectedFaceRect: CGRect?
    
    // MARK: - Throttling & Queues
    private let visionQueue = DispatchQueue(label: "com.apple.harmonia.visionQueue", qos: .userInitiated)
    private var lastAnalyzedTimestamp: TimeInterval = 0
    private var isAnalyzingFrame: Bool = false
    private let sampleInterval: TimeInterval = AppConfiguration.Performance.visionSampleIntervalSeconds // 0.1s = 10 Hz
    
    // Vision Requests
    private lazy var faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private lazy var saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest()
    private lazy var contourRequest = VNDetectContoursRequest()
    
    public override init() {
        super.init()
        // Provide initial default recommendation
        self.currentRecommendation = SmartCoachRecommendation(
            suggestedRule: .ruleOfThirds,
            suggestedFocalLength: .standard,
            confidenceScore: 0.85,
            rationale: "Align main subject with intersection power points"
        )
    }
    
    // MARK: - Frame Ingestion & Analysis
    public func analyzePixelBuffer(_ pixelBuffer: CVPixelBuffer) async {
        guard isSmartCoachEnabled else { return }
        
        let now = CACurrentMediaTime()
        guard (now - lastAnalyzedTimestamp) >= sampleInterval else { return }
        guard !isAnalyzingFrame else { return }
        
        lastAnalyzedTimestamp = now
        isAnalyzingFrame = true
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        visionQueue.async { [weak self] in
            guard let self = self else { return }
            defer { self.isAnalyzingFrame = false }
            
            do {
                try handler.perform([
                    self.faceDetectionRequest,
                    self.saliencyRequest
                ])
                
                self.evaluateVisionResults()
            } catch {
                // Silently skip dropped frame
            }
        }
    }
    
    // MARK: - Heuristic Scoring Engine
    private func evaluateVisionResults() {
        var faceRect: CGRect?
        var salientPoint: CGPoint?
        
        // 1. Evaluate Human Faces
        let faces = faceDetectionRequest.results as? [VNFaceObservation] ?? []
        if let primaryFace = faces.first {
            faceRect = primaryFace.boundingBox
        }
        
        // 2. Evaluate Visual Saliency
        if let saliencyObservation = saliencyRequest.results?.first as? VNSaliencyImageObservation,
           let salientObject = saliencyObservation.salientObjects?.first {
            let bbox = salientObject.boundingBox
            salientPoint = CGPoint(x: bbox.midX, y: 1.0 - bbox.midY)
        }
        
        // 3. Compute Rule & Lens Recommendation
        let recommendation = computeBestRecommendation(faces: faces, salientPoint: salientPoint)
        
        // Dispatch to Main Actor
        DispatchQueue.main.async {
            self.detectedFaceRect = faceRect
            self.detectedSalientPoint = salientPoint
            self.currentRecommendation = recommendation
        }
    }
    
    private func computeBestRecommendation(
        faces: [VNFaceObservation],
        salientPoint: CGPoint?
    ) -> SmartCoachRecommendation {
        // SCENARIO A: Human Portrait Detected
        if let leadFace = faces.first {
            let faceArea = leadFace.boundingBox.width * leadFace.boundingBox.height
            
            if faceArea > 0.10 {
                // Close-Up Portrait -> Recommend 2x Lens (eliminates wide-angle facial distortion) + Fibonacci Spiral
                return SmartCoachRecommendation(
                    suggestedRule: .fibonacciSpiral,
                    suggestedFocalLength: .telephoto2x,
                    confidenceScore: 0.94,
                    rationale: "Close-up portrait detected. Switch to 2x (52mm) for natural facial proportions."
                )
            } else if faces.count >= 2 {
                // Group Photo -> Recommend Harmonic Armature + 1x Lens
                return SmartCoachRecommendation(
                    suggestedRule: .harmonicArmature,
                    suggestedFocalLength: .standard,
                    confidenceScore: 0.91,
                    rationale: "Group detected. Harmonic Armature unifies multiple subjects across the frame."
                )
            } else {
                // Environmental Portrait -> Rule of Thirds + 1x Lens
                return SmartCoachRecommendation(
                    suggestedRule: .ruleOfThirds,
                    suggestedFocalLength: .standard,
                    confidenceScore: 0.89,
                    rationale: "Portrait detected. Align the subject's lead eye along the upper third line."
                )
            }
        }
        
        // SCENARIO B: Saliency Position Analysis
        if let pt = salientPoint {
            // Check for Bilateral Symmetry (center x between 0.44 and 0.56)
            if abs(pt.x - 0.5) < 0.06 {
                return SmartCoachRecommendation(
                    suggestedRule: .symmetry,
                    suggestedFocalLength: .standard,
                    confidenceScore: 0.88,
                    rationale: "Centered subject detected. Use Symmetry to create balanced visual weight."
                )
            }
            
            // Check for Off-Center Dynamic Angles (Lower quadrants)
            if pt.y > 0.60 && (pt.x < 0.35 || pt.x > 0.65) {
                return SmartCoachRecommendation(
                    suggestedRule: .leadingLines,
                    suggestedFocalLength: .ultraWide,
                    confidenceScore: 0.86,
                    rationale: "Dynamic perspective detected. Use 0.5x Ultra-Wide to dramatize leading lines."
                )
            }
            
            // Check for Tight Macro / Close-Up
            if pt.x > 0.25 && pt.x < 0.75 && pt.y > 0.25 && pt.y < 0.75 {
                return SmartCoachRecommendation(
                    suggestedRule: .fillTheFrame,
                    suggestedFocalLength: .standard,
                    confidenceScore: 0.83,
                    rationale: "Close subject detected. Fill the frame to eliminate background distraction."
                )
            }
        }
        
        // SCENARIO C: Default Universal Framework
        return SmartCoachRecommendation(
            suggestedRule: .ruleOfThirds,
            suggestedFocalLength: .standard,
            confidenceScore: 0.80,
            rationale: "Standard scene. Rule of Thirds provides natural organic balance."
        )
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension IntelligenceService: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        Task {
            await self.analyzePixelBuffer(pixelBuffer)
        }
    }
}
