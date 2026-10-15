import SwiftUI

/// Interactive Smart Coach Recommendation Pill and Rationale Banner.
/// Provides one-tap application of AI-recommended composition rules and focal lengths.
public struct SmartCoachPillView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var isRationaleExpanded: Bool = false
    
    public init(environment: AppEnvironment) {
        self.environment = environment
    }
    
    public var body: some View {
        if environment.isSmartCoachEnabled, let rec = environment.smartCoachRecommendation {
            VStack(spacing: 6) {
                // Main Interactive Pill
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isRationaleExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        // AI Sparkle Indicator with subtle animated glow
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.Colors.appleGold)
                        
                        // Suggested Rule & Lens
                        Text("\(rec.suggestedRule.rawValue) · \(rec.suggestedFocalLength.label)")
                            .font(AppTheme.Typography.coachPill)
                            .foregroundColor(.white)
                        
                        // Chevron indicating expandability
                        Image(systemName: isRationaleExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.controlSurface)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.Colors.appleGold.opacity(0.5), lineWidth: 1.0)
                    )
                }
                
                // Expandable Rationale & One-Tap Apply Card
                if isRationaleExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("SMART COACH")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.Colors.appleGold)
                            
                            Spacer()
                            
                            Text("\(Int(rec.confidenceScore * 100))% Confidence")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Text(rec.rationale)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // One-Tap Apply Action Button
                        Button(action: {
                            environment.applySmartCoachRecommendation()
                            withAnimation {
                                isRationaleExpanded = false
                            }
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 13))
                                Text("Apply Rule & Lens")
                                    .font(.system(size: 12, weight: .bold))
                                Spacer()
                            }
                            .padding(.vertical, 7)
                            .background(AppTheme.Colors.appleGold)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: 290)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(white: 0.10, opacity: 0.95))
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}
