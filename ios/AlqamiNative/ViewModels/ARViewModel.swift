import Foundation
import UIKit
import RealityKit
import ARKit
import Combine

@MainActor
public final class ARViewModel: ObservableObject {
    @Published public var artifact: Artifact
    @Published public var isPlaced: Bool = false
    @Published public var isSurfaceDetected: Bool = false
    @Published public var scaleMultiplier: Float = 1.0
    @Published public var isOcclusionEnabled: Bool = true
    @Published public var showMeshWireframe: Bool = false
    @Published public var statusMessage: String = "ابحث عن سطح مستوٍ..."
    @Published public var modelLoadError: String? = nil
    @Published public var snapshotSavedToast: Bool = false

    // Spatial Computing Diagnostics (Images 1, 2, 3, 4)
    @Published public var activeMeshAnchorCount: Int = 0
    @Published public var activeWorldAnchorCount: Int = 0
    @Published public var lastCollisionCastHitDistance: Float? = nil
    @Published public var lastCollisionCastNormal: SIMD3<Float> = SIMD3<Float>(0, 1, 0)
    @Published public var lastCollisionPosition: SIMD3<Float> = .zero

    public weak var arView: ARView? = nil
    public var placedEntity: ModelEntity? = nil

    public init(artifact: Artifact) {
        self.artifact = artifact
        self.scaleMultiplier = 1.0
    }

    public func resetPlacement() {
        if let entity = placedEntity {
            entity.removeFromParent()
            placedEntity = nil
        }
        isPlaced = false
        activeWorldAnchorCount = 0
        statusMessage = "تم مسح القطعة. وجه الكاميرا لتحديد سطح جديد"
        SpatialSoundHelper.shared.playSnapHaptic()
    }

    public func setScale(_ scale: Float) {
        scaleMultiplier = max(0.1, min(5.0, scale))
        if let entity = placedEntity {
            let baseScale = artifact.model.scale
            entity.scale = SIMD3<Float>(repeating: baseScale * scaleMultiplier)
        }
    }

    /// Captures a real high-resolution AR snapshot from RealityKit `ARView` and saves it to the iOS Photos library.
    public func captureARSnapshot() {
        guard let arView = arView else { return }
        SpatialSoundHelper.shared.playPlacementHaptic()
        arView.snapshot(saveToHDR: false) { [weak self] image in
            guard let self = self, let image = image else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            Task { @MainActor in
                self.statusMessage = "تم حفظ صورة الواقع المعزز في ألبوم الصور!"
                self.snapshotSavedToast = true
                SpatialSoundHelper.shared.playSuccessHaptic()
                try? await Task.sleep(nanoseconds: 2_200_000_000)
                self.snapshotSavedToast = false
            }
        }
    }
}
