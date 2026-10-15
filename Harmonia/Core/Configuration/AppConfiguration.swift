import Foundation
import CoreGraphics

/// Hardware and System Configuration tailored specifically for iPhone 15 imaging pipeline.
public enum AppConfiguration {
    
    // MARK: - App Identity
    public static let appName = "Harmonia"
    public static let appVersion = "1.0.0"
    public static let buildNumber = "1"
    
    // MARK: - iPhone 15 Camera Sensor Specifications
    public enum Sensor {
        /// Native aspect ratio of the 48MP Quad-Bayer sensor (4:3)
        public static let nativeAspectRatio: CGFloat = 4.0 / 3.0
        
        /// Native full sensor dimensions of the iPhone 15 Main camera (8064 x 6048 = ~48.7 MP)
        public static let mainSensorFullResolution = CGSize(width: 8064, height: 6048)
        
        /// Default binned resolution (24MP = 5712 x 4284)
        public static let default24MPResolution = CGSize(width: 5712, height: 4284)
        
        /// Standard binned resolution (12MP = 4032 x 3024)
        public static let standard12MPResolution = CGSize(width: 4032, height: 3024)
        
        /// Ultra-Wide sensor resolution (12MP)
        public static let ultraWideResolution = CGSize(width: 4032, height: 3024)
    }
    
    // MARK: - Focal Length Definitions
    public enum FocalLength: Float, CaseIterable, Identifiable {
        case ultraWide = 0.5   // 13mm equivalent (Built-in Ultra-Wide sensor)
        case standard = 1.0    // 26mm equivalent (Built-in 48MP Main sensor)
        case telephoto2x = 2.0  // 52mm equivalent (Lossless Quad-Pixel sensor crop)
        
        public var id: Float { rawValue }
        
        public var label: String {
            switch self {
            case .ultraWide: return "0.5x"
            case .standard: return "1x"
            case .telephoto2x: return "2x"
            }
        }
        
        public var focalEquivalent: String {
            switch self {
            case .ultraWide: return "13mm"
            case .standard: return "26mm"
            case .telephoto2x: return "52mm"
            }
        }
    }
    
    // MARK: - Performance & Refresh Budgets
    public enum Performance {
        /// Target rendering FPS for live viewfinder and vector overlays
        public static let targetViewfinderFPS: Int = 60
        
        /// Vision Intelligence frame sample rate (10 Hz = every 100ms) to preserve thermals and battery
        public static let visionSampleRateHz: Double = 10.0
        public static let visionSampleIntervalSeconds: Double = 1.0 / visionSampleRateHz
        
        /// CoreMotion sampling frequency in Hz
        public static let motionUpdateFrequencyHz: Double = 60.0
        
        /// Angular tolerance (in degrees) to trigger level snap haptic
        public static let levelSnapThresholdDegrees: Double = 0.35
    }
    
    // MARK: - Capture Preferences
    public enum CaptureMode {
        case highResolution48MP
        case balanced24MP
        case speedPrioritized12MP
    }
}
