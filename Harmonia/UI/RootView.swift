import SwiftUI

/// Root View for Harmonia Camera on iPhone 15.
/// Implements a sensor-locked 4:3 viewfinder with tactile top and bottom control bars.
public struct RootView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var isRulesDrawerPresented: Bool = false
    @State private var isQuickReviewPresented: Bool = false
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background true black (OLED)
                AppTheme.Colors.deepBlack
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Top Safe Bar (Dynamic Island Compatible)
                    VStack(spacing: 4) {
                        topControlBar
                        
                        // Thermal Throttling Telemetry Indicator
                        if let badge = env.thermalBadge {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                                Text(badge)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top > 0 ? geometry.safeAreaInsets.top : 12)
                    
                    Spacer(minLength: 0)
                    
                    // MARK: - 4:3 Sensor-Locked Viewfinder Container
                    let viewfinderWidth = geometry.size.width
                    let viewfinderHeight = viewfinderWidth * AppConfiguration.Sensor.nativeAspectRatio
                    
                    ZStack {
                        // Live Hardware-Accelerated Camera Viewfinder
                        CameraPreviewView(session: env.cameraService.captureSession)
                            .frame(width: viewfinderWidth, height: viewfinderHeight)
                            .clipped()
                        
                        // Live 15-Rule Composition Vector Overlay (Anti-Glare Dual-Stroke)
                        CompositionOverlayView(environment: env)
                            .frame(width: viewfinderWidth, height: viewfinderHeight)
                            .clipped()
                        
                        // Hardware Horizon Level & Telemetry Indicator
                        if env.isLevelIndicatorVisible {
                            HorizonLevelView(environment: env)
                                .frame(width: viewfinderWidth, height: viewfinderHeight)
                                .clipped()
                        }
                        
                        // Shutter Flash Animation Overlay
                        if env.isCapturing {
                            Color.white
                                .frame(width: viewfinderWidth, height: viewfinderHeight)
                                .transition(.opacity)
                        }
                        
                        // Fallback message when camera is inactive (e.g. simulator or initializing)
                        if !env.isCameraRunning {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.3))
                                Text(env.cameraErrorMessage ?? "Starting iPhone 15 Camera Engine...")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                        
                        // Active Composition Badge
                        VStack {
                            HStack {
                                Text(env.activeRule.rawValue)
                                    .font(.system(size: 11, weight: .semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                Spacer()
                            }
                            .padding(12)
                            Spacer()
                        }
                    }
                    .frame(width: viewfinderWidth, height: viewfinderHeight)
                    
                    Spacer(minLength: 0)
                    
                    // MARK: - Focal Length Selector (0.5x, 1x, 2x)
                    focalLengthSelector
                        .padding(.vertical, 12)
                    
                    // MARK: - Bottom Control Deck
                    bottomControlDeck
                        .padding(.horizontal, 24)
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 8 : 20)
                }
            }
        }
    }
    
    // MARK: - Top Control Bar
    private var topControlBar: some View {
        HStack(spacing: 12) {
            // Flash / Torch Toggle
            Button(action: { env.toggleTorch() }) {
                Image(systemName: env.isTorchActive ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 15))
                    .foregroundColor(env.isTorchActive ? AppTheme.Colors.appleGold : .white)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.controlSurface)
                    .clipShape(Circle())
            }
            
            // Horizon Level Toggle
            Button(action: { env.toggleLevelIndicator() }) {
                Image(systemName: "gyroscope")
                    .font(.system(size: 15))
                    .foregroundColor(env.isLevelIndicatorVisible ? AppTheme.Colors.levelLockedGreen : .white.opacity(0.4))
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.controlSurface)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Interactive Smart Coach Recommendation Pill with Rationale Sheet
            SmartCoachPillView(environment: env)
            
            Spacer()
            
            // Flip/Transform Button
            Button(action: { env.flipHorizontal() }) {
                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.controlSurface)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Focal Length Selector
    private var focalLengthSelector: some View {
        HStack(spacing: 16) {
            ForEach(AppConfiguration.FocalLength.allCases) { focal in
                let isSelected = env.activeFocalLength == focal
                Button(action: { env.selectFocalLength(focal) }) {
                    Text(focal.label)
                        .font(AppTheme.Typography.focalButton)
                        .foregroundColor(isSelected ? AppTheme.Colors.appleGold : .white)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.white.opacity(0.18) : Color.black.opacity(0.4))
                        )
                }
            }
        }
    }
    
    // MARK: - Bottom Control Deck
    private var bottomControlDeck: some View {
        HStack(alignment: .center) {
            // Recent Capture Thumbnail / Gallery Button
            Button(action: {
                AppTheme.Haptics.selectionChanged()
                isQuickReviewPresented = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    if let thumbnail = env.recentThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .frame(width: 54)
            
            Spacer()
            
            // Rules Drawer Quick Button
            Button(action: {
                AppTheme.Haptics.selectionChanged()
                isRulesDrawerPresented = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "square.grid.3x3.topleft.filled")
                        .font(.system(size: 22))
                    Text("Rules")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
            // Physical Shutter Button
            Button(action: {
                env.triggerCapture()
            }) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.shutterRing, lineWidth: 4)
                        .frame(width: 74, height: 74)
                    Circle()
                        .fill(AppTheme.Colors.shutterCore)
                        .frame(width: 62, height: 62)
                }
            }
            .scaleEffect(env.isCapturing ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: env.isCapturing)
            
            Spacer()
            
            // Rotate Rule 90° Button
            Button(action: { env.rotate90Degrees() }) {
                VStack(spacing: 4) {
                    Image(systemName: "rotate.right.fill")
                        .font(.system(size: 20))
                    Text("Rotate")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
            // Quick Flip Horizontal Button
            Button(action: { env.flipHorizontal() }) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
                        .font(.system(size: 18))
                    Text("Flip")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(env.isFlippedHorizontally ? AppTheme.Colors.appleGold : .white)
            }
            .frame(width: 54)
        }
        .sheet(isPresented: $isRulesDrawerPresented) {
            RulesDrawerView(environment: env, isPresented: $isRulesDrawerPresented)
        }
        .sheet(isPresented: $isQuickReviewPresented) {
            QuickReviewView(environment: env, isPresented: $isQuickReviewPresented)
        }
    }
}

// MARK: - RootView Lifecycle Attachment
public extension RootView {
    func withCameraLifecycle(env: AppEnvironment) -> some View {
        self.task {
            await env.startCamera()
        }
    }
}

