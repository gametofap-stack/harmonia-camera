import SwiftUI

/// Precision optical horizon level indicator and camera angle telemetry overlay.
/// Features mechanical snap visualization, zero-drift rotation, and dynamic green level confirmation.
public struct HorizonLevelView: View {
    @ObservedObject var environment: AppEnvironment
    
    public init(environment: AppEnvironment) {
        self.environment = environment
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let centerY = h * 0.5
            let isLevel = environment.isLevel
            let roll = environment.rollDegrees
            
            ZStack {
                // Fixed Center Alignment Crosshair Reticle
                HStack(spacing: 40) {
                    // Left Fixed Tick
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 14, height: 1.5)
                    
                    // Center Reticle Dot
                    Circle()
                        .fill(isLevel ? AppTheme.Colors.levelLockedGreen : Color.white.opacity(0.5))
                        .frame(width: 4, height: 4)
                    
                    // Right Fixed Tick
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 14, height: 1.5)
                }
                .position(x: w * 0.5, y: centerY)
                
                // Dynamic Rotating Horizon Line
                HStack(spacing: 0) {
                    // Left dynamic horizon bar
                    Rectangle()
                        .fill(isLevel ? AppTheme.Colors.levelLockedGreen : Color.white.opacity(0.85))
                        .frame(width: w * 0.22, height: isLevel ? 2.0 : 1.5)
                    
                    Spacer()
                        .frame(width: 48) // Space around center reticle
                    
                    // Right dynamic horizon bar
                    Rectangle()
                        .fill(isLevel ? AppTheme.Colors.levelLockedGreen : Color.white.opacity(0.85))
                        .frame(width: w * 0.22, height: isLevel ? 2.0 : 1.5)
                }
                .position(x: w * 0.5, y: centerY)
                .rotationEffect(.degrees(-roll), anchor: .center)
                .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.86), value: roll)
                
                // Telemetry Readout & Stance Badge
                VStack(spacing: 4) {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        // Degree Readout
                        HStack(spacing: 4) {
                            Circle()
                                .fill(isLevel ? AppTheme.Colors.levelLockedGreen : AppTheme.Colors.appleGold)
                                .frame(width: 6, height: 6)
                            
                            Text(isLevel ? "0.0° LEVEL" : String(format: "%+.1f°", -roll))
                                .font(AppTheme.Typography.degreeLabel)
                                .foregroundColor(isLevel ? AppTheme.Colors.levelLockedGreen : .white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.65))
                        .cornerRadius(6)
                        
                        // Camera Stance Pill
                        if environment.currentStance != .neutral {
                            Text(environment.currentStance.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.65))
                                .cornerRadius(6)
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
