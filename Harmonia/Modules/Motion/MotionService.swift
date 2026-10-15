import Foundation
import CoreMotion
import UIKit
import Combine

/// Hardware-accelerated motion engine tracking device attitude, horizon level,
/// and camera perspective stance at 60 Hz via CMMotionManager.
public final class MotionService: ObservableObject, MotionServiceProtocol {
    
    // MARK: - Published State
    @Published public private(set) var pitchDegrees: Double = 0.0
    @Published public private(set) var rollDegrees: Double = 0.0
    @Published public private(set) var isLevel: Bool = false
    @Published public private(set) var cameraStance: CameraStance = .neutral
    @Published public var isLevelIndicatorVisible: Bool = true
    
    // MARK: - Core Motion Properties
    private let motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()
    
    // Haptic state tracking
    private var hasFiredHapticForCurrentLevelState: Bool = false
    private let snapThreshold: Double = AppConfiguration.Performance.levelSnapThresholdDegrees // 0.35°
    private let hapticResetThreshold: Double = 1.0 // Must tilt 1.0° away before re-arming
    
    public init() {
        motionQueue.name = "com.apple.harmonia.motionQueue"
        motionQueue.maxConcurrentOperationCount = 1
        motionQueue.qualityOfService = .userInteractive
    }
    
    // MARK: - Lifecycle
    public func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            // Simulator or hardware without motion sensors
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / AppConfiguration.Performance.motionUpdateFrequencyHz
        motionManager.showsDeviceMovementDisplay = false
        
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: motionQueue) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }
            self.processMotionData(motion)
        }
    }
    
    public func stopMotionUpdates() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    // MARK: - Attitude & Kinetic Processing
    private func processMotionData(_ motion: CMDeviceMotion) {
        // Roll: Side-to-side tilt in degrees (-180° ... +180°)
        // Pitch: Front-to-back tilt in degrees (-90° ... +90°)
        let rawRoll = motion.attitude.roll * (180.0 / .pi)
        let rawPitch = motion.attitude.pitch * (180.0 / .pi)
        let gravityZ = motion.gravity.z
        
        // Normalize roll relative to portrait orientation
        let normalizedRoll = rawRoll
        let normalizedPitch = rawPitch
        
        // Level calculation
        let level = abs(normalizedRoll) <= snapThreshold
        
        // Camera Stance Classification
        let stance: CameraStance
        if abs(gravityZ) > 0.85 {
            stance = .flatLay
        } else if normalizedPitch > 25.0 {
            stance = .lowAngle
        } else if normalizedPitch < -25.0 {
            stance = .highAngle
        } else {
            stance = .neutral
        }
        
        // Haptic Trigger Logic
        if level {
            if !hasFiredHapticForCurrentLevelState {
                DispatchQueue.main.async {
                    AppTheme.Haptics.snapLevel()
                }
                hasFiredHapticForCurrentLevelState = true
            }
        } else if abs(normalizedRoll) > hapticResetThreshold {
            hasFiredHapticForCurrentLevelState = false
        }
        
        // Dispatch to Main Thread
        DispatchQueue.main.async {
            self.rollDegrees = normalizedRoll
            self.pitchDegrees = normalizedPitch
            self.isLevel = level
            self.cameraStance = stance
        }
    }
}
