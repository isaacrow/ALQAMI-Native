import SwiftUI
import RealityKit
import ARKit
import Combine

// MARK: - Bulletproof Apple RealityKit & ARKit Spatial Engine (Zero Crash, iPhone 15 Pro Max LiDAR Optimized)
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

        var reticleEntity: ModelEntity?
        var reticleAnchor: AnchorEntity?
        var placedAnchor: AnchorEntity?
        var currentModelEntity: ModelEntity?
        var activeWorldARAnchor: ARAnchor?

        private var initialEntityScale: SIMD3<Float> = .one
        private var lastMeshDebugState: Bool = false
        private var isProcessingRaycast: Bool = false

        init(viewModel: ARViewModel) {
            self.viewModel = viewModel
            super.init()
        }

        func setup(arView: ARView, viewModel: ARViewModel) {
            self.arView = arView
            self.viewModel = viewModel
            viewModel.arView = arView

            configureARSession(for: arView)
            arView.session.delegate = self

            setupRaycastReticle(in: arView)
            setupSpatialGestures(in: arView)
        }

        func update(viewModel: ARViewModel) {
            self.viewModel = viewModel

            // Toggle LiDAR Mesh Wireframe Visualization safely
            if let arView = arView, lastMeshDebugState != viewModel.showMeshWireframe {
                lastMeshDebugState = viewModel.showMeshWireframe
                if viewModel.showMeshWireframe {
                    arView.debugOptions.insert(.showSceneUnderstanding)
                } else {
                    arView.debugOptions.remove(.showSceneUnderstanding)
                }
            }

            // Handle Reset from 2D SwiftUI UI
            if !viewModel.isPlaced && currentModelEntity != nil {
                resetPlacement()
            }

            // Handle Scale Multiplier from 2D SwiftUI Slider
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

            // Real iPhone 15 Pro Max LiDAR Scene Reconstruction
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
                config.sceneReconstruction = .meshWithClassification
                arView.environment.sceneUnderstanding.options.insert([.occlusion, .physics, .collision])
            } else if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                config.sceneReconstruction = .mesh
                arView.environment.sceneUnderstanding.options.insert([.occlusion, .physics, .collision])
            }

            if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                config.frameSemantics.insert(.personSegmentationWithDepth)
            }

            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            viewModel.statusMessage = "وجّه الكاميرا نحو سطح مستقر لرصد المكان..."
        }

        // MARK: - Setup Reticle Indicator
        private func setupRaycastReticle(in arView: ARView) {
            let anchor = AnchorEntity(world: .zero)

            // Outer Target Ring
            let outerRingMesh = MeshResource.generatePlane(width: 0.24, depth: 0.24, cornerRadius: 0.12)
            var outerMat = SimpleMaterial(color: UIColor(red: 1.0, green: 0.839, blue: 0.039, alpha: 0.85), isMetallic: true)
            outerMat.roughness = MaterialScalarParameter.float(0.2)
            let outerRing = ModelEntity(mesh: outerRingMesh, materials: [outerMat])

            // Inner Center Dot
            let innerDotMesh = MeshResource.generatePlane(width: 0.04, depth: 0.04, cornerRadius: 0.02)
            var innerMat = SimpleMaterial(color: UIColor.white, isMetallic: false)
            let innerDot = ModelEntity(mesh: innerDotMesh, materials: [innerMat])
            innerDot.position = [0, 0.001, 0]
            outerRing.addChild(innerDot)

            // Normal Arrow Shaft (Yellow Vertical Indicator)
            let shaftMesh = MeshResource.generateBox(width: 0.006, height: 0.08, depth: 0.006, cornerRadius: 0.003)
            var shaftMat = SimpleMaterial(color: UIColor(red: 1.0, green: 0.839, blue: 0.039, alpha: 0.95), isMetallic: false)
            let shaft = ModelEntity(mesh: shaftMesh, materials: [shaftMat])
            shaft.position = [0, 0.04, 0]
            outerRing.addChild(shaft)

            anchor.addChild(outerRing)
            arView.scene.addAnchor(anchor)

            outerRing.isEnabled = false
            self.reticleEntity = outerRing
            self.reticleAnchor = anchor
        }

        // MARK: - Spatial Gestures (Translation, Rotation, Pinch Scale)
        private func setupSpatialGestures(in arView: ARView) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tap)

            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            pan.maximumNumberOfTouches = 1
            pan.delegate = self
            arView.addGestureRecognizer(pan)

            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            pinch.delegate = self
            arView.addGestureRecognizer(pinch)

            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
            rotate.delegate = self
            arView.addGestureRecognizer(rotate)
        }

        public nonisolated func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) ||
            (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer)
        }

        // MARK: - Tap Handler: Perform Raycast & Place ModelEntity
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let tapPoint = gesture.location(in: arView)

            if viewModel.isPlaced {
                // If already placed, check tap on object
                if let entity = arView.entity(at: tapPoint) {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    let p = entity.position(relativeTo: nil)
                    viewModel.lastCollisionPosition = p
                }
                return
            }

            // Raycast on estimated or existing planes
            let results = arView.raycast(from: tapPoint, allowing: .estimatedPlane, alignment: .any)
            if let first = results.first {
                executeWorldAnchorPlacement(at: first.worldTransform)
            } else {
                let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
                let centerResults = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)
                if let centerFirst = centerResults.first {
                    executeWorldAnchorPlacement(at: centerFirst.worldTransform)
                } else {
                    SpatialSoundHelper.shared.playWarningHaptic()
                    viewModel.statusMessage = "وجّه الكاميرا نحو سطح مستقر كطاولة أو أرضية"
                }
            }
        }

        // MARK: - Anchor Placement
        private func executeWorldAnchorPlacement(at worldTransform: simd_float4x4) {
            guard let arView = arView else { return }
            SpatialSoundHelper.shared.playPlacementHaptic()

            let worldARAnchor = ARAnchor(name: "WorldAnchor_\(viewModel.artifact.id)", transform: worldTransform)
            arView.session.add(anchor: worldARAnchor)
            self.activeWorldARAnchor = worldARAnchor
            viewModel.activeWorldAnchorCount = 1

            let anchorEntity = AnchorEntity(world: worldTransform)
            anchorEntity.name = "Anchor_\(viewModel.artifact.id)"

            // Load USDZ model entity
            let modelEntity = RealityComposerContentBundle.shared.loadUSDEntity(for: viewModel.artifact)
            let baseScale = viewModel.artifact.model.scale
            modelEntity.scale = SIMD3<Float>(repeating: baseScale * viewModel.scaleMultiplier)

            // Safe collision bounds generation
            let visualBounds = modelEntity.visualBounds(relativeTo: nil)
            let safeExtents = SIMD3<Float>(
                max(0.05, visualBounds.extents.x),
                max(0.05, visualBounds.extents.y),
                max(0.05, visualBounds.extents.z)
            )
            let box = ShapeResource.generateBox(size: safeExtents)
            modelEntity.collision = CollisionComponent(shapes: [box])

            // Install native RealityKit gestures
            arView.installGestures([.translation, .rotation, .scale], for: modelEntity)

            // Smooth placement drop
            modelEntity.position = [0, 0.12, 0]
            anchorEntity.addChild(modelEntity)
            arView.scene.addAnchor(anchorEntity)

            var targetTransform = modelEntity.transform
            targetTransform.translation.y = 0
            modelEntity.move(to: targetTransform, relativeTo: anchorEntity, duration: 0.32, timingFunction: .easeOut)

            self.placedAnchor = anchorEntity
            self.currentModelEntity = modelEntity
            viewModel.placedEntity = modelEntity
            viewModel.isPlaced = true
            reticleEntity?.isEnabled = false

            let pos = worldTransform.columns.3
            viewModel.lastCollisionPosition = SIMD3<Float>(pos.x, pos.y, pos.z)
            viewModel.statusMessage = "تم تثبيت المقتنى في مكانك! يمكنك سحبه أو تدويره أو تكبيره"
            SpatialSoundHelper.shared.playSuccessHaptic()
        }

        // MARK: - 1-Finger Pan (Move Object on Plane)
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let arView = arView, let anchor = placedAnchor, viewModel.isPlaced else { return }
            let location = gesture.location(in: arView)

            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
            if let result = results.first {
                anchor.transform = Transform(matrix: result.worldTransform)
                let p = result.worldTransform.columns.3
                viewModel.lastCollisionPosition = SIMD3<Float>(p.x, p.y, p.z)
                if gesture.state == .ended {
                    SpatialSoundHelper.shared.playSnapHaptic()
                }
            }
        }

        // MARK: - 2-Finger Pinch (Scale with 1:1 Snap)
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let entity = currentModelEntity, viewModel.isPlaced else { return }

            switch gesture.state {
            case .began:
                initialEntityScale = entity.scale
            case .changed:
                let scaleFactor = Float(gesture.scale)
                var newScale = initialEntityScale * scaleFactor
                let currentMagnitude = newScale.x / viewModel.artifact.model.scale

                if currentMagnitude >= 0.2 && currentMagnitude <= 3.5 {
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

        // MARK: - 2-Finger Rotate (Y-Axis Spin)
        @objc func handleRotate(_ gesture: UIRotationGestureRecognizer) {
            guard let entity = currentModelEntity, viewModel.isPlaced else { return }
            let rotationAngle = Float(-gesture.rotation)
            let rotationTransform = simd_quatf(angle: rotationAngle, axis: [0, 1, 0])
            entity.orientation = rotationTransform * entity.orientation
            gesture.rotation = 0
        }

        private func resetPlacement() {
            if let worldAnchor = activeWorldARAnchor {
                arView?.session.remove(anchor: worldAnchor)
                activeWorldARAnchor = nil
            }
            placedAnchor?.removeFromParent()
            placedAnchor = nil
            currentModelEntity = nil
            viewModel.placedEntity = nil
            viewModel.isPlaced = false
            viewModel.activeWorldAnchorCount = 0
            viewModel.scaleMultiplier = 1.0
            viewModel.statusMessage = "وجّه الكاميرا نحو السطح للتثبيت مجدداً"
            reticleEntity?.isEnabled = true
            SpatialSoundHelper.shared.playSnapHaptic()
        }

        // MARK: - ARSessionDelegate Safe Updates
        nonisolated public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            let meshCount = anchors.filter { $0 is ARMeshAnchor }.count
            if meshCount > 0 {
                Task { @MainActor [weak self] in
                    self?.viewModel.activeMeshAnchorCount += meshCount
                }
            }
        }

        nonisolated public func session(_ session: ARSession, didUpdate frame: ARFrame) {
            Task { @MainActor [weak self] in
                guard let self = self, let arView = self.arView, !self.viewModel.isPlaced else { return }
                guard !self.isProcessingRaycast else { return }
                self.isProcessingRaycast = true

                defer { self.isProcessingRaycast = false }

                let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
                guard center.x > 0 && center.y > 0 else { return }

                let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)
                if let result = results.first {
                    if !self.viewModel.isSurfaceDetected {
                        self.viewModel.isSurfaceDetected = true
                        SpatialSoundHelper.shared.playSurfaceDetectedHaptic()
                        self.viewModel.statusMessage = "تم رصد السطح! انقر لتثبيت المقتنى في غرفتك"
                    }
                    self.reticleEntity?.isEnabled = true
                    self.reticleAnchor?.transform = Transform(matrix: result.worldTransform)

                    let p = result.worldTransform.columns.3
                    self.viewModel.lastCollisionPosition = SIMD3<Float>(p.x, p.y, p.z)
                    let upCol = result.worldTransform.columns.1
                    self.viewModel.lastCollisionCastNormal = SIMD3<Float>(upCol.x, upCol.y, upCol.z)
                } else {
                    if self.viewModel.isSurfaceDetected {
                        self.viewModel.isSurfaceDetected = false
                        self.viewModel.statusMessage = "حرّك الكاميرا ببطء لمسح أسطح الغرفة..."
                    }
                    self.reticleEntity?.isEnabled = false
                }
            }
        }
    }
}
