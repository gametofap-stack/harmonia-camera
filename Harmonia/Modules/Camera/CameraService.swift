import Foundation
import AVFoundation
import UIKit
import Combine

/// Hardware-accelerated camera engine engineered for the iPhone 15 dual-lens imaging system.
/// Manages AVCaptureSession, seamless focal transitions (0.5x, 1x, 2x), and 48MP full-sensor capture.
public final class CameraService: NSObject, ObservableObject, CameraServiceProtocol {
    
    // MARK: - Published State
    @Published public private(set) var isRunning: Bool = false
    @Published public private(set) var currentFocalLength: AppConfiguration.FocalLength = .standard
    @Published public private(set) var isTorchActive: Bool = false
    @Published public private(set) var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published public private(set) var lastCapturedImage: UIImage?
    @Published public var errorMessage: String?
    
    // MARK: - Core AVFoundation Properties
    public let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    public let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let sessionQueue = DispatchQueue(label: "com.apple.harmonia.sessionQueue", qos: .userInitiated)
    
    // Devices
    private var wideAngleCamera: AVCaptureDevice?
    private var ultraWideCamera: AVCaptureDevice?
    private var activeDeviceInput: AVCaptureDeviceInput?
    
    // Photo Capture delegate handler
    private var photoCaptureContinuation: CheckedContinuation<Data, Error>?
    public var onPhotoDataCaptured: ((Data) -> Void)?
    
    // MARK: - Initialization
    public override init() {
        super.init()
        self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        discoverDevices()
    }
    
    // MARK: - Device Discovery
    private func discoverDevices() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,
                .builtInUltraWideCamera
            ],
            mediaType: .video,
            position: .back
        )
        
        for device in discoverySession.devices {
            if device.deviceType == .builtInWideAngleCamera {
                self.wideAngleCamera = device
            } else if device.deviceType == .builtInUltraWideCamera {
                self.ultraWideCamera = device
            }
        }
    }
    
    // MARK: - Permissions & Session Lifecycle
    public func requestPermissionsIfNeeded() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async { self.authorizationStatus = status }
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    public func startSession() async throws {
        let authorized = await requestPermissionsIfNeeded()
        guard authorized else {
            throw CameraError.permissionDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                do {
                    if !self.captureSession.isRunning {
                        try self.configureSession()
                        self.captureSession.startRunning()
                        DispatchQueue.main.async {
                            self.isRunning = self.captureSession.isRunning
                        }
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func stopSession() async {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                if self.captureSession.isRunning {
                    self.captureSession.stopRunning()
                    DispatchQueue.main.async {
                        self.isRunning = false
                    }
                }
                continuation.resume()
            }
        }
    }
    
    // MARK: - Session Configuration
    private func configureSession() throws {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // Use .photo preset to enable full sensor dimensions (48MP/24MP pipeline)
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        } else {
            throw CameraError.presetUnavailable
        }
        
        // Attach initial camera input (default: 48MP Wide Angle Camera)
        guard let camera = wideAngleCamera ?? AVCaptureDevice.default(for: .video) else {
            throw CameraError.deviceNotFound
        }
        
        let input = try AVCaptureDeviceInput(device: camera)
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            self.activeDeviceInput = input
        } else {
            throw CameraError.cannotAddInput
        }
        
        // Configure Photo Output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            
            // Enable high-resolution 48MP capture pipeline
            photoOutput.maxPhotoQualityPrioritization = .quality
            
            // Match maximum supported dimension (typically 8064x6048 on iPhone 15 main sensor)
            if let maxDimension = camera.activeFormat.supportedMaxPhotoDimensions.last {
                photoOutput.maxPhotoDimensions = maxDimension
            }
        } else {
            throw CameraError.cannotAddOutput
        }
        
        // Configure Video Data Output for throttled Vision AI (Phase 4)
        if captureSession.canAddOutput(videoDataOutput) {
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            captureSession.addOutput(videoDataOutput)
        }
    }
    
    // MARK: - Vision Pipeline Attachment
    public func attachVisionSampleBufferDelegate(
        _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.videoDataOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
    
    // MARK: - Lens & Focal Switching (0.5x, 1x, 2x)
    public func setFocalLength(_ focalLength: AppConfiguration.FocalLength) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                do {
                    switch focalLength {
                    case .ultraWide:
                        // Switch physical camera input to Ultra-Wide sensor
                        guard let ultraWide = self.ultraWideCamera else {
                            throw CameraError.deviceNotFound
                        }
                        try self.switchDeviceInput(to: ultraWide)
                        try self.resetZoom(on: ultraWide)
                        
                    case .standard:
                        // Switch physical camera input to 48MP Wide sensor at 1.0x
                        guard let wide = self.wideAngleCamera else {
                            throw CameraError.deviceNotFound
                        }
                        try self.switchDeviceInput(to: wide)
                        try self.resetZoom(on: wide)
                        
                    case .telephoto2x:
                        // Use 48MP Main sensor with 2.0x optical-quality sensor crop
                        guard let wide = self.wideAngleCamera else {
                            throw CameraError.deviceNotFound
                        }
                        try self.switchDeviceInput(to: wide)
                        try self.applySensorCropZoom(factor: 2.0, on: wide)
                    }
                    
                    DispatchQueue.main.async {
                        self.currentFocalLength = focalLength
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func switchDeviceInput(to newDevice: AVCaptureDevice) throws {
        guard let currentInput = activeDeviceInput else { return }
        if currentInput.device == newDevice { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        captureSession.removeInput(currentInput)
        let newInput = try AVCaptureDeviceInput(device: newDevice)
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            self.activeDeviceInput = newInput
            
            // Reconfigure max dimensions for new active format
            if let maxDimension = newDevice.activeFormat.supportedMaxPhotoDimensions.last {
                photoOutput.maxPhotoDimensions = maxDimension
            }
        } else {
            captureSession.addInput(currentInput)
            throw CameraError.cannotAddInput
        }
    }
    
    private func resetZoom(on device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        device.videoZoomFactor = 1.0
        device.unlockForConfiguration()
    }
    
    private func applySensorCropZoom(factor: CGFloat, on device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        let clampedFactor = min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor)
        device.videoZoomFactor = clampedFactor
        device.unlockForConfiguration()
    }
    
    // MARK: - Torch Control
    public func toggleTorch() async throws {
        guard let device = activeDeviceInput?.device, device.hasTorch else {
            return
        }
        
        try device.lockForConfiguration()
        if device.torchMode == .on {
            device.torchMode = .off
            DispatchQueue.main.async { self.isTorchActive = false }
        } else {
            try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            DispatchQueue.main.async { self.isTorchActive = true }
        }
        device.unlockForConfiguration()
    }
    
    // MARK: - Photo Capture
    public func capturePhoto(bakeComposition: Bool = false) async throws {
        guard isRunning else { throw CameraError.sessionNotRunning }
        
        let settings = AVCapturePhotoSettings()
        
        // Prioritize maximum image quality
        settings.photoQualityPrioritization = .quality
        
        // Enable high-resolution 48MP if supported on active device
        if let maxDimension = activeDeviceInput?.device.activeFormat.supportedMaxPhotoDimensions.last {
            settings.maxPhotoDimensions = maxDimension
        }
        
        // HEIF format optimization
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            // High-efficiency container
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
            return
        }
        
        guard let fileData = photo.fileDataRepresentation() else {
            return
        }
        
        let image = UIImage(data: fileData)
        
        DispatchQueue.main.async {
            self.lastCapturedImage = image
            self.onPhotoDataCaptured?(fileData)
        }
    }
}

// MARK: - Camera Error Definitions
public enum CameraError: LocalizedError {
    case permissionDenied
    case deviceNotFound
    case presetUnavailable
    case cannotAddInput
    case cannotAddOutput
    case sessionNotRunning
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera access was denied. Please enable Camera permissions in Settings."
        case .deviceNotFound:
            return "iPhone 15 camera hardware could not be initialized."
        case .presetUnavailable:
            return "High-resolution photo session preset is unavailable on this device."
        case .cannotAddInput:
            return "Unable to bind camera input stream."
        case .cannotAddOutput:
            return "Unable to bind high-resolution photo output."
        case .sessionNotRunning:
            return "Camera session is currently not active."
        }
    }
}
