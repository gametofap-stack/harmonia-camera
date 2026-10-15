import Foundation
import Photos
import UIKit
import Combine

/// High-throughput photo asset delivery pipeline.
/// Manages asynchronous PHPhotoLibrary saving, dedicated album management,
/// dual-save execution (clean master + composition reference), and thumbnail generation.
public final class AssetDeliveryService: ObservableObject {
    
    // MARK: - Published State
    @Published public private(set) var recentThumbnail: UIImage?
    @Published public private(set) var lastCapturedClean: UIImage?
    @Published public private(set) var lastCapturedReference: UIImage?
    @Published public private(set) var isSaving: Bool = false
    @Published public var errorMessage: String?
    
    private let albumName = "Harmonia"
    private let deliveryQueue = DispatchQueue(label: "com.apple.harmonia.deliveryQueue", qos: .userInitiated)
    
    public init() {}
    
    // MARK: - Permissions
    public func requestPhotoLibraryPermissions() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            return newStatus == .authorized || newStatus == .limited
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Save Process
    public func deliverCapturedPhoto(
        data: Data,
        rule: CompositionRule,
        lineStyle: LineStyle,
        isFlippedH: Bool,
        isFlippedV: Bool,
        rotation: Double,
        horizonRoll: Double,
        focalLength: AppConfiguration.FocalLength,
        bakeReference: Bool
    ) async throws {
        guard let cleanImage = UIImage(data: data) else {
            throw AssetDeliveryError.invalidImageData
        }
        
        let authorized = await requestPhotoLibraryPermissions()
        guard authorized else {
            throw AssetDeliveryError.permissionDenied
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
            self.lastCapturedClean = cleanImage
            self.recentThumbnail = self.generateThumbnail(from: cleanImage)
        }
        
        // Background delivery execution
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            deliveryQueue.async { [weak self] in
                guard let self = self else { return }
                do {
                    // Optional Composition Reference Render
                    var referenceImage: UIImage?
                    if bakeReference {
                        referenceImage = VectorCompositor.bakeCompositionOverlay(
                            onto: cleanImage,
                            rule: rule,
                            lineStyle: lineStyle,
                            isFlippedHorizontally: isFlippedH,
                            isFlippedVertically: isFlippedV,
                            rotationDegrees: rotation,
                            horizonRollDegrees: horizonRoll,
                            focalLength: focalLength
                        )
                        DispatchQueue.main.async {
                            self.lastCapturedReference = referenceImage
                        }
                    }
                    
                    // Save to Apple Photos & Harmonia Album
                    try self.saveAssetsToLibrary(cleanImage: cleanImage, referenceImage: referenceImage)
                    
                    DispatchQueue.main.async {
                        self.isSaving = false
                    }
                    continuation.resume()
                } catch {
                    DispatchQueue.main.async {
                        self.isSaving = false
                        self.errorMessage = error.localizedDescription
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - PHPhotoLibrary Album Saving
    private func saveAssetsToLibrary(cleanImage: UIImage, referenceImage: UIImage?) throws {
        let album = try getOrCreateAlbum()
        
        try PHPhotoLibrary.shared().performChangesAndWait {
            // 1. Save Clean Master
            let cleanCreationRequest = PHAssetChangeRequest.creationRequestForAsset(from: cleanImage)
            if let album = album, let albumRequest = PHAssetCollectionChangeRequest(for: album),
               let cleanPlaceholder = cleanCreationRequest.placeholderForCreatedAsset {
                albumRequest.addAssets([cleanPlaceholder] as NSArray)
            }
            
            // 2. Save Reference Image if present
            if let refImage = referenceImage {
                let refCreationRequest = PHAssetChangeRequest.creationRequestForAsset(from: refImage)
                if let album = album, let albumRequest = PHAssetCollectionChangeRequest(for: album),
                   let refPlaceholder = refCreationRequest.placeholderForCreatedAsset {
                    albumRequest.addAssets([refPlaceholder] as NSArray)
                }
            }
        }
    }
    
    private func getOrCreateAlbum() throws -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let existing = collection.firstObject {
            return existing
        }
        
        var albumPlaceholder: PHObjectPlaceholder?
        try PHPhotoLibrary.shared().performChangesAndWait {
            let createRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            albumPlaceholder = createRequest.placeholderForCreatedAssetCollection
        }
        
        if let placeholder = albumPlaceholder {
            let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
            return result.firstObject
        }
        
        return nil
    }
    
    // MARK: - Fast Thumbnail Extraction
    private func generateThumbnail(from image: UIImage, targetSize: CGSize = CGSize(width: 120, height: 120)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

public enum AssetDeliveryError: LocalizedError {
    case invalidImageData
    case permissionDenied
    
    public var errorDescription: String? {
        switch self {
        case .invalidImageData: return "Captured image data could not be parsed."
        case .permissionDenied: return "Photo Library access was denied. Enable Photos access in Settings."
        }
    }
}
