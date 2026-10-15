import SwiftUI
import AVFoundation
import UIKit

/// High-performance UIViewRepresentable bridging AVCaptureVideoPreviewLayer directly into SwiftUI.
public struct CameraPreviewView: UIViewRepresentable {
    
    public let session: AVCaptureSession
    
    public init(session: AVCaptureSession) {
        self.session = session
    }
    
    public func makeUIView(context: Context) -> VideoPreviewUIView {
        let view = VideoPreviewUIView()
        view.backgroundColor = .black
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        
        // Configure layer properties
        return view
    }
    
    public func updateUIView(_ uiView: VideoPreviewUIView, context: Context) {
        if uiView.previewLayer.session != session {
            uiView.previewLayer.session = session
        }
    }
}

/// Custom UIView backed by an AVCaptureVideoPreviewLayer for zero-copy hardware rendering.
public final class VideoPreviewUIView: UIView {
    
    public override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    public var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Layer mismatch: expected AVCaptureVideoPreviewLayer")
        }
        return layer
    }
}
