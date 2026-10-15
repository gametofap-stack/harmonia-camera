import Foundation
import UIKit
import Combine

/// Adaptive system thermal governor for Harmonia Camera.
/// Dynamically scales Neural Engine Vision sampling and motion telemetry frequencies
/// to prevent device overheating and thermal throttling during extended outdoor shooting sessions.
public final class ThermalGovernor: ObservableObject {
    
    // MARK: - Published State
    @Published public private(set) var currentThermalState: ProcessInfo.ThermalState = .nominal
    @Published public private(set) var visionSampleIntervalSeconds: TimeInterval = AppConfiguration.Performance.visionSampleIntervalSeconds
    @Published public private(set) var isVisionPausedDueToThermals: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.currentThermalState = ProcessInfo.processInfo.thermalState
        evaluateThermalState(currentThermalState)
        startObservingThermalChanges()
    }
    
    // MARK: - Notifications
    private func startObservingThermalChanges() {
        NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.evaluateThermalState(ProcessInfo.processInfo.thermalState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Thermal State Evaluation
    private func evaluateThermalState(_ state: ProcessInfo.ThermalState) {
        self.currentThermalState = state
        
        switch state {
        case .nominal:
            // Full Performance: 10 Hz Vision sampling (every 100ms)
            self.visionSampleIntervalSeconds = 0.10
            self.isVisionPausedDueToThermals = false
            
        case .fair:
            // Moderate Thermal Load: 8 Hz Vision sampling (every 125ms)
            self.visionSampleIntervalSeconds = 0.125
            self.isVisionPausedDueToThermals = false
            
        case .serious:
            // Heavy Thermal Load: Scale down to 3 Hz (every 333ms) to prevent hardware throttling
            self.visionSampleIntervalSeconds = 0.333
            self.isVisionPausedDueToThermals = false
            
        case .critical:
            // Extreme Thermal Load: Pause background Neural Engine inference completely
            // Guarantees camera preview and photo capture remain locked at 60 FPS without crashing
            self.visionSampleIntervalSeconds = 1.0
            self.isVisionPausedDueToThermals = true
            
        @unknown default:
            self.visionSampleIntervalSeconds = 0.10
            self.isVisionPausedDueToThermals = false
        }
    }
    
    public var thermalStatusBadge: String? {
        switch currentThermalState {
        case .serious: return "Serious Thermals · AI Throttled"
        case .critical: return "Critical Thermals · AI Paused"
        default: return nil
        }
    }
}
