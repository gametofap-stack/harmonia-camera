import SwiftUI

/// Modal sheet for inspecting the most recent capture with pinch-to-zoom,
/// dual-asset inspection (Clean Master vs. Composition Reference), and native sharing.
public struct QuickReviewView: View {
    @ObservedObject var environment: AppEnvironment
    @Binding var isPresented: Bool
    
    @State private var selectedAssetTab: AssetTab = .clean
    @State private var zoomScale: CGFloat = 1.0
    
    public init(environment: AppEnvironment, isPresented: Binding<Bool>) {
        self.environment = environment
        self._isPresented = isPresented
    }
    
    public enum AssetTab: String, CaseIterable {
        case clean = "Clean Master"
        case reference = "Composition Guide"
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Selector (if reference image is available)
                    if environment.assetDeliveryService.lastCapturedReference != nil {
                        Picker("View Mode", selection: $selectedAssetTab) {
                            ForEach(AssetTab.allCases, id: \.self) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                    }
                    
                    Spacer()
                    
                    // Main Image Viewer
                    if let imageToDisplay = activeDisplayImage {
                        Image(uiImage: imageToDisplay)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(zoomScale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in zoomScale = max(1.0, value) }
                                    .onEnded { _ in
                                        withAnimation(.spring()) { zoomScale = 1.0 }
                                    }
                            )
                            .padding(.horizontal, 8)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.3))
                            Text("No recent captures in this session.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                    
                    // Telemetry & Metadata Strip
                    if let image = activeDisplayImage {
                        metadataStrip(image: image)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Capture Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { isPresented = false }
                        .foregroundColor(AppTheme.Colors.appleGold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let image = activeDisplayImage {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview("Harmonia Capture", image: Image(uiImage: image))) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppTheme.Colors.appleGold)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var activeDisplayImage: UIImage? {
        if selectedAssetTab == .reference, let ref = environment.assetDeliveryService.lastCapturedReference {
            return ref
        }
        return environment.assetDeliveryService.lastCapturedClean
    }
    
    private func metadataStrip(image: UIImage) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("RESOLUTION")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.Colors.appleGold)
                Text("\(Int(image.size.width)) × \(Int(image.size.height))")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            Divider().frame(height: 24).background(Color.white.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("FOCAL LENGTH")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.Colors.appleGold)
                Text("\(environment.activeFocalLength.label) (\(environment.activeFocalLength.focalEquivalent))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Divider().frame(height: 24).background(Color.white.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("COMPOSITION")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.Colors.appleGold)
                Text(environment.activeRule.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(12)
        .background(AppTheme.Colors.controlSurface)
        .cornerRadius(12)
    }
}
