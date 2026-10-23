import Foundation
import ARKit
import RealityKit
import Combine

public final class ARSessionManager: NSObject, ObservableObject, ARSessionDelegate {
    public static let shared = ARSessionManager()

    @Published public var trackingState: ARCamera.TrackingState = .notAvailable
    @Published public var surfaceDetected: Bool = false
    @Published public var isLiDARAvailable: Bool = false
    @Published public var isOcclusionSupported: Bool = false
    @Published public var statusMessage: String = "جاري تهيئة جلسة الواقع المعزز..."

    public private(set) var session: ARSession?

    public override init() {
        super.init()
        checkHardwareCapabilities()
    }

    private func checkHardwareCapabilities() {
        isLiDARAvailable = ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification)
        isOcclusionSupported = ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth)
    }

    public func configureSession(for arView: ARView, enableOcclusion: Bool = true) {
        guard ARWorldTrackingConfiguration.isSupported else {
            statusMessage = "الواقع المعزز غير مدعوم على هذا الجهاز"
            return
        }

        self.session = arView.session
        arView.session.delegate = self

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic

        // Enable real-time LiDAR mesh scene reconstruction if available (iPhone Pro / iPad Pro)
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
            arView.environment.sceneUnderstanding.options.insert([.occlusion, .physics, .receivesLighting])
        }

        // Enable dynamic people occlusion where supported
        if enableOcclusion && ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }

        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        statusMessage = "وجه الكاميرا ببطء نحو الأرضية أو الطاولة لرصد السطح"
    }

    public func pauseSession() {
        session?.pause()
    }

    // MARK: - ARSessionDelegate
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        DispatchQueue.main.async {
            self.trackingState = camera.trackingState
            switch camera.trackingState {
            case .normal:
                self.statusMessage = "التتبع نشط - ابحث عن سطح مناسب"
            case .limited(let reason):
                switch reason {
                case .initializing:
                    self.statusMessage = "جاري ضبط الحساسات المكانية..."
                case .excessiveMotion:
                    self.statusMessage = "تحرك ببطء أكثر لضبط التتبع"
                case .insufficientFeatures:
                    self.statusMessage = "الإضاءة منخفضة أو السطح خالي من التفاصيل"
                case .relocalizing:
                    self.statusMessage = "جاري استعادة الموقع المكاني..."
                @unknown default:
                    self.statusMessage = "جاري تحسين دقة التتبع..."
                }
            case .notAvailable:
                self.statusMessage = "خدمات التتبع المكاني غير متاحة"
            }
        }
    }

    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let planes = anchors.compactMap { $0 as? ARPlaneAnchor }
        if !planes.isEmpty {
            DispatchQueue.main.async {
                self.surfaceDetected = true
                self.statusMessage = "تم رصد سطح مستقر - المس الشاشة لتثبيت القطعة"
            }
        }
    }
}
