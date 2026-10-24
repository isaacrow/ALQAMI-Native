import SwiftUI
import RealityKit
import ARKit
import Combine

// MARK: - Adobe Aero Grade RealityKit AR View
@MainActor
public struct RealityKitARView: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel

    public func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.setup(arView: arView, viewModel: viewModel)
        return arView
    }

    public func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.update(viewModel: viewModel)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    // MARK: - Coordinator
    @MainActor
    public class Coordinator: NSObject, ARSessionDelegate, UIGestureRecognizerDelegate {
        weak var arView: ARView?
        var viewModel: ARViewModel

        // AR Anchors & Entities
        var reticleEntity: ModelEntity?
        var reticleAnchor: AnchorEntity?
        var placedAnchor: AnchorEntity?
        var currentModelEntity: ModelEntity?
        var shadowEntity: ModelEntity?

        // Gesture Tracking State
        private var initialEntityScale: SIMD3<Float> = .one
        private var initialPinchScale: CGFloat = 1.0
        private var previousPanRaycast: ARRaycastResult?
        private var cancellables = Set<AnyCancellable>()

        init(viewModel: ARViewModel) {
            self.viewModel = viewModel
            super.init()
        }

        func setup(arView: ARView, viewModel: ARViewModel) {
            self.arView = arView
            self.viewModel = viewModel

            // 1. Configure ARSession with Environmental HDR & LiDAR Mesh
            configureARSession(for: arView)
            arView.session.delegate = self

            // 2. Setup Adobe Aero Reticle (Focus Ring)
            setupAeroReticle(in: arView)

            // 3. Setup Custom Aero Gestures (Surface-Clamped Drag, Pinch, Rotate)
            setupAeroGestures(in: arView)
        }

        func update(viewModel: ARViewModel) {
            self.viewModel = viewModel

            // Handle Reset from UI
            if !viewModel.isPlaced && currentModelEntity != nil {
                resetPlacement()
            }

            // Handle Scale Multiplier from UI Slider
            if let entity = currentModelEntity, viewModel.isPlaced {
                let baseScale = viewModel.artifact.model.scale
                let targetScale = baseScale * viewModel.scaleMultiplier
                entity.scale = SIMD3<Float>(repeating: targetScale)
            }
        }

        private func configureARSession(for arView: ARView) {
            guard ARWorldTrackingConfiguration.isSupported else {
                viewModel.statusMessage = "الواقع المعزز غير مدعوم على هذا الجهاز"
                return
            }

            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            config.environmentTexturing = .automatic

            // Enable LiDAR Scene Reconstruction if available (iPhone Pro)
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
                config.sceneReconstruction = .meshWithClassification
                arView.environment.sceneUnderstanding.options.insert([.occlusion, .physics])
            }

            // Enable Person Segmentation (People Occlusion) if supported
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                config.frameSemantics.insert(.personSegmentationWithDepth)
            }

            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            viewModel.statusMessage = "وجّه الكاميرا نحو الأرضية أو طاولة مستوية..."
        }

        // MARK: - Setup Adobe Aero Focus Reticle
        private func setupAeroReticle(in arView: ARView) {
            let anchor = AnchorEntity(world: .zero)

            // Outer Pulsing Target Ring
            let outerRingMesh = MeshResource.generatePlane(width: 0.28, depth: 0.28, cornerRadius: 0.14)
            var outerMat = SimpleMaterial(color: UIColor(red: 1.0, green: 0.84, blue: 0.15, alpha: 0.65), isMetallic: true)
            outerMat.roughness = MaterialScalarParameter.float(0.2)
            let outerRing = ModelEntity(mesh: outerRingMesh, materials: [outerMat])

            // Inner Target Center Dot
            let innerDotMesh = MeshResource.generatePlane(width: 0.06, depth: 0.06, cornerRadius: 0.03)
            var innerMat = SimpleMaterial(color: UIColor.white, isMetallic: false)
            innerMat.roughness = MaterialScalarParameter.float(0.1)
            let innerDot = ModelEntity(mesh: innerDotMesh, materials: [innerMat])
            innerDot.position = [0, 0.001, 0]

            outerRing.addChild(innerDot)
            anchor.addChild(outerRing)
            arView.scene.addAnchor(anchor)

            outerRing.isEnabled = false
            self.reticleEntity = outerRing
            self.reticleAnchor = anchor
        }

        // MARK: - Setup Adobe Aero Gestures
        private func setupAeroGestures(in arView: ARView) {
            // Tap to Place / Snap
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tap)

            // 1-Finger Pan (Surface-Clamped Translation)
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            pan.maximumNumberOfTouches = 1
            pan.delegate = self
            arView.addGestureRecognizer(pan)

            // 2-Finger Pinch (Scale with Percentage Pill & 100% Snap Haptic)
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            pinch.delegate = self
            arView.addGestureRecognizer(pinch)

            // 2-Finger Rotation (Smooth Y-Axis Twist)
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
            rotate.delegate = self
            arView.addGestureRecognizer(rotate)
        }

        // MARK: - Gesture Delegate: Allow Simultaneous Pinch & Rotate
        public nonisolated func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) ||
            (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer)
        }

        // MARK: - Tap Handler (Placement)
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            if viewModel.isPlaced {
                // Tapping while placed plays a selection haptic
                SpatialSoundHelper.shared.playSnapHaptic()
                return
            }

            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)

            if let firstResult = results.first {
                executePlacement(at: firstResult)
            } else {
                SpatialSoundHelper.shared.playWarningHaptic()
                viewModel.statusMessage = "يرجى توجيه الكاميرا نحو سطح مستقر أولاً"
            }
        }

        // MARK: - Execute Placement with Aero Spring Drop Animation
        private func executePlacement(at raycastResult: ARRaycastResult) {
            guard let arView = arView else { return }

            SpatialSoundHelper.shared.playPlacementHaptic()
            viewModel.statusMessage = "جاري تثبيت المجسم بالواقع المعزز..."

            let anchor = AnchorEntity(world: raycastResult.worldTransform)

            // Build High-Fidelity 3D Heritage Entity
            let modelEntity = Artifact3DEntityBuilder.shared.createEntity(for: viewModel.artifact)
            let baseScale = viewModel.artifact.model.scale
            modelEntity.scale = SIMD3<Float>(repeating: baseScale * viewModel.scaleMultiplier)

            // Aero Spring Drop Animation: Start 15cm above surface and drop down smoothly
            modelEntity.position = [0, 0.15, 0]
            anchor.addChild(modelEntity)
            arView.scene.addAnchor(anchor)

            // Animate Drop to Surface (y = 0)
            var targetTransform = modelEntity.transform
            targetTransform.translation.y = 0
            modelEntity.move(to: targetTransform, relativeTo: anchor, duration: 0.38, timingFunction: .easeOut)

            self.placedAnchor = anchor
            self.currentModelEntity = modelEntity
            viewModel.placedEntity = modelEntity
            viewModel.isPlaced = true
            reticleEntity?.isEnabled = false

            viewModel.statusMessage = "تم التثبيت بنجاح! يمكنك السحب، والتدوير، والتكبير بإصبعين"
            SpatialSoundHelper.shared.playSuccessHaptic()
        }

        // MARK: - 1-Finger Pan: Surface Clamped Drag (Never leaves ground plane)
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let arView = arView, let anchor = placedAnchor, viewModel.isPlaced else { return }

            let location = gesture.location(in: arView)
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)

            if let result = results.first {
                anchor.transform = Transform(matrix: result.worldTransform)
                if gesture.state == .ended {
                    SpatialSoundHelper.shared.playSnapHaptic()
                }
            }
        }

        // MARK: - 2-Finger Pinch: Smooth Scaling with 100% Snap Haptic
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let entity = currentModelEntity, viewModel.isPlaced else { return }

            switch gesture.state {
            case .began:
                initialEntityScale = entity.scale
            case .changed:
                let scaleFactor = Float(gesture.scale)
                var newScale = initialEntityScale * scaleFactor

                // Clamp scale between 0.2x and 3.5x
                let minScale: Float = 0.2
                let maxScale: Float = 3.5
                let currentMagnitude = newScale.x / viewModel.artifact.model.scale

                if currentMagnitude >= minScale && currentMagnitude <= maxScale {
                    // Check for 100% snap tick
                    if abs(currentMagnitude - 1.0) < 0.04 {
                        newScale = SIMD3<Float>(repeating: viewModel.artifact.model.scale)
                        SpatialSoundHelper.shared.playScaleTickHaptic()
                    }
                    entity.scale = newScale
                    viewModel.scaleMultiplier = currentMagnitude
                }
            case .ended, .cancelled:
                SpatialSoundHelper.shared.playSnapHaptic()
            default:
                break
            }
        }

        // MARK: - 2-Finger Rotate: Smooth Surface Normal Twist
        @objc func handleRotate(_ gesture: UIRotationGestureRecognizer) {
            guard let entity = currentModelEntity, viewModel.isPlaced else { return }

            let rotationAngle = Float(-gesture.rotation)
            let rotationTransform = simd_quatf(angle: rotationAngle, axis: [0, 1, 0])
            entity.orientation = rotationTransform * entity.orientation
            gesture.rotation = 0
        }

        private func resetPlacement() {
            placedAnchor?.removeFromParent()
            placedAnchor = nil
            currentModelEntity = nil
            viewModel.placedEntity = nil
            viewModel.isPlaced = false
            viewModel.scaleMultiplier = 1.0
            viewModel.statusMessage = "وجّه الكاميرا نحو السطح للتثبيت مجدداً"
            reticleEntity?.isEnabled = true
            SpatialSoundHelper.shared.playSnapHaptic()
        }

        // MARK: - ARSessionDelegate: Real-Time High-FPS Reticle Snapping
        nonisolated public func session(_ session: ARSession, didUpdate frame: ARFrame) {
            Task { @MainActor [weak self] in
                guard let self = self, let arView = self.arView, !self.viewModel.isPlaced else { return }

                let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
                let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)

                if let result = results.first {
                    if !self.viewModel.isSurfaceDetected {
                        self.viewModel.isSurfaceDetected = true
                        SpatialSoundHelper.shared.playSurfaceDetectedHaptic()
                        self.viewModel.statusMessage = "تم اكتشاف السطح! انقر على الشاشة للتثبيت"
                    }
                    self.reticleEntity?.isEnabled = true
                    self.reticleAnchor?.transform = Transform(matrix: result.worldTransform)
                } else {
                    if self.viewModel.isSurfaceDetected {
                        self.viewModel.isSurfaceDetected = false
                        self.viewModel.statusMessage = "حرك الكاميرا ببطء لمسح أسطح الغرفة..."
                    }
                    self.reticleEntity?.isEnabled = false
                }
            }
        }
    }
}
