import Foundation
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
    @Published public var statusMessage: String = "ابحث عن سطح مستوٍ..."
    @Published public var modelLoadError: String? = nil

    public var placedEntity: ModelEntity? = nil

    public init(artifact: Artifact) {
        self.artifact = artifact
        self.scaleMultiplier = artifact.model.scale
    }

    public func resetPlacement() {
        if let entity = placedEntity {
            entity.removeFromParent()
            placedEntity = nil
        }
        isPlaced = false
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
}
