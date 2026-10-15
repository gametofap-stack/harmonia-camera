import SwiftUI
import Combine

/// Central observable state coordinator for Harmonia, binding all modular subsystems together.
@MainActor
public final class AppEnvironment: ObservableObject {
    
    // MARK: - Subsystems
    public let cameraService = CameraService()
    public let motionService = MotionService()
    public let intelligenceService = IntelligenceService()
    public let assetDeliveryService = AssetDeliveryService()
    public let thermalGovernor = ThermalGovernor()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published State
    @Published public var activeFocalLength: AppConfiguration.FocalLength = .standard
    @Published public var activeRule: CompositionRule = .ruleOfThirds
    @Published public var isFlippedHorizontally: Bool = false
    @Published public var isFlippedVertically: Bool = false
    @Published public var rotationAngleDegrees: Double = 0.0
    @Published public var lineStyle: LineStyle = .default
    
    // Camera Subsystem State
    @Published public var isCameraRunning: Bool = false
    @Published public var isTorchActive: Bool = false
    @Published public var cameraErrorMessage: String?
    
    // Motion state
    @Published public var pitchDegrees: Double = 0.0
    @Published public var rollDegrees: Double = 0.0
    @Published public var isLevel: Bool = false
    @Published public var currentStance: CameraStance = .neutral
    @Published public var isLevelIndicatorVisible: Bool = true
    
    // Smart Coach AI state
    @Published public var isSmartCoachEnabled: Bool = true
    @Published public var smartCoachRecommendation: SmartCoachRecommendation?
    
    // Asset Delivery & Review State
    @Published public var isCapturing: Bool = false
    @Published public var shouldBakeCompositionReference: Bool = true
    @Published public var recentThumbnail: UIImage?
    @Published public var isQuickReviewPresented: Bool = false
    @Published public var thermalBadge: String?
    
    public init() {
        setupBindings()
        attachVisionPipeline()
    }
    
    private func attachVisionPipeline() {
        let visionQueue = DispatchQueue(label: "com.apple.harmonia.visionIngestQueue", qos: .userInitiated)
        cameraService.attachVisionSampleBufferDelegate(intelligenceService, queue: visionQueue)
    }
    
    private func setupBindings() {
        // Camera bindings
        cameraService.$isRunning
            .receive(on: DispatchQueue.main)
            .assign(to: &$isCameraRunning)
        
        cameraService.$isTorchActive
            .receive(on: DispatchQueue.main)
            .assign(to: &$isTorchActive)
        
        cameraService.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$cameraErrorMessage)
            
        // Motion bindings
        motionService.$pitchDegrees
            .receive(on: DispatchQueue.main)
            .assign(to: &$pitchDegrees)
            
        motionService.$rollDegrees
            .receive(on: DispatchQueue.main)
            .assign(to: &$rollDegrees)
            
        motionService.$isLevel
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLevel)
            
        motionService.$cameraStance
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentStance)
            
        // Intelligence / Smart Coach bindings
        intelligenceService.$currentRecommendation
            .receive(on: DispatchQueue.main)
            .assign(to: &$smartCoachRecommendation)
            
        // Asset Delivery bindings
        assetDeliveryService.$recentThumbnail
            .receive(on: DispatchQueue.main)
            .assign(to: &$recentThumbnail)
            
        // Wire Camera Captured Data to Asset Delivery Pipeline
        cameraService.onPhotoDataCaptured = { [weak self] fileData in
            guard let self = self else { return }
            Task {
                do {
                    try await self.assetDeliveryService.deliverCapturedPhoto(
                        data: fileData,
                        rule: self.activeRule,
                        lineStyle: self.lineStyle,
                        isFlippedH: self.isFlippedHorizontally,
                        isFlippedV: self.isFlippedVertically,
                        rotation: self.rotationAngleDegrees,
                        horizonRoll: self.rollDegrees,
                        focalLength: self.activeFocalLength,
                        bakeReference: self.shouldBakeCompositionReference
                    )
                } catch {
                    self.cameraErrorMessage = error.localizedDescription
                }
            }
        }
        
        // Thermal Governor bindings
        thermalGovernor.$thermalStatusBadge
            .receive(on: DispatchQueue.main)
            .assign(to: &$thermalBadge)
    }
    
    // MARK: - Lifecycle
    public func startCamera() async {
        motionService.startMotionUpdates()
        do {
            try await cameraService.startSession()
        } catch {
            self.cameraErrorMessage = error.localizedDescription
        }
    }
    
    public func stopCamera() async {
        motionService.stopMotionUpdates()
        await cameraService.stopSession()
    }
    
    public func toggleLevelIndicator() {
        AppTheme.Haptics.selectionChanged()
        isLevelIndicatorVisible.toggle()
    }
    
    // MARK: - User Actions
    public func selectFocalLength(_ focalLength: AppConfiguration.FocalLength) {
        AppTheme.Haptics.selectionChanged()
        activeFocalLength = focalLength
        AccessibilityManager.announceFocalLengthChanged(focalLength)
        
        Task {
            do {
                try await cameraService.setFocalLength(focalLength)
            } catch {
                self.cameraErrorMessage = error.localizedDescription
            }
        }
    }
    
    public func toggleTorch() {
        AppTheme.Haptics.selectionChanged()
        Task {
            do {
                try await cameraService.toggleTorch()
            } catch {
                self.cameraErrorMessage = error.localizedDescription
            }
        }
    }
    
    public func triggerCapture() {
        AppTheme.Haptics.shutterSnap()
        isCapturing = true
        
        Task {
            do {
                try await cameraService.capturePhoto(bakeComposition: shouldBakeCompositionReference)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.isCapturing = false
                }
            } catch {
                self.cameraErrorMessage = error.localizedDescription
                self.isCapturing = false
            }
        }
    }
    
    public func selectRule(_ rule: CompositionRule) {
        AppTheme.Haptics.selectionChanged()
        activeRule = rule
        AccessibilityManager.announceRuleChanged(rule)
    }
    
    public func flipHorizontal() {
        AppTheme.Haptics.selectionChanged()
        isFlippedHorizontally.toggle()
    }
    
    public func flipVertical() {
        AppTheme.Haptics.selectionChanged()
        isFlippedVertically.toggle()
    }
    
    public func rotate90Degrees() {
        AppTheme.Haptics.selectionChanged()
        rotationAngleDegrees = (rotationAngleDegrees + 90.0).truncatingRemainder(dividingBy: 360.0)
    }
    
    public func applySmartCoachRecommendation() {
        guard let recommendation = smartCoachRecommendation else { return }
        AppTheme.Haptics.snapLevel()
        activeRule = recommendation.suggestedRule
        activeFocalLength = recommendation.suggestedFocalLength
        AccessibilityManager.announceSmartCoachSuggestion(recommendation)
    }
}
