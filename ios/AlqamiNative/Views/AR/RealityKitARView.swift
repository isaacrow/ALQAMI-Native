import SwiftUI
import RealityKit
import ARKit
import Combine

// MARK: - Apple Spatial Computing, RealityKit, ARKit & Raycasting Engine (Images 1, 2, 3, 4)
// Implements:
// - Image 1: ARView / RealityView -> Scene / Content -> AnchorEntity + EntityGesture (`installGestures([.all], for:)`) + UIGesture
// - Image 2: ARMeshAnchor (.transform) -> Entity(TransformComponent + CollisionComponent via ShapeResource.generateStaticMesh)
// - Image 3: Raycasting -> scene.raycast(origin:direction:) returning CollisionCastHit (position + surface normal vector)
// - Image 4: ARAnchor ("WorldAnchor") (.transform) -> Entity(TransformComponent + ModelComponent(USDZ) + CollisionComponent)
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

        // Image 1 & 4: Scene -> AnchorEntity -> ModelEntity (Transform + Model + Collision)
        var reticleEntity: ModelEntity?
        var surfaceNormalArrowEntity: ModelEntity?
        var reticleAnchor: AnchorEntity?
        var placedAnchor: AnchorEntity?
        var currentModelEntity: ModelEntity?
        var activeWorldARAnchor: ARAnchor?

        // Image 2: MeshAnchor UUID -> Entity(Transform + StaticMesh CollisionComponent)
        var meshCollisionEntities: [UUID: Entity] = [:]
        var meshRootAnchor: AnchorEntity?

        // Gesture Tracking State
        private var initialEntityScale: SIMD3<Float> = .one
        private var lastMeshDebugState: Bool = false

        init(viewModel: ARViewModel) {
            self.viewModel = viewModel
            super.init()
        }

        func setup(arView: ARView, viewModel: ARViewModel) {
            self.arView = arView
            self.viewModel = viewModel

            // 1. Configure ARSession with Environmental HDR, Plane Detection & LiDAR MeshAnchor Reconstruction (Image 2)
            configureARSession(for: arView)
            arView.session.delegate = self

            // 2. Setup MeshAnchor Root Container (Image 2)
            let meshRoot = AnchorEntity(world: .zero)
            meshRoot.name = "MeshAnchorsContainer"
            arView.scene.addAnchor(meshRoot)
            self.meshRootAnchor = meshRoot

            // 3. Setup Raycast Focus Reticle + Surface Normal Vector Indicator (Image 3)
            setupRaycastReticleWithNormalVector(in: arView)

            // 4. Setup UIGesture + EntityGesture Pipeline (Image 1)
            setupSpatialGestures(in: arView)
        }

        func update(viewModel: ARViewModel) {
            self.viewModel = viewModel

            // Toggle LiDAR Mesh Wireframe Visualization (Image 2)
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

            // Image 2: Enable LiDAR Scene Reconstruction (.meshWithClassification) for MeshAnchor StaticMesh Collision
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
                config.sceneReconstruction = .meshWithClassification
                arView.environment.sceneUnderstanding.options.insert([.occlusion, .physics, .collision])
            }

            // Enable People Occlusion if supported
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                config.frameSemantics.insert(.personSegmentationWithDepth)
            }

            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            viewModel.statusMessage = "وجّه الكاميرا نحو الطاولة أو الأرضية لإطلاق شعاع Raycast..."
        }

        // MARK: - Image 3: Setup Raycast Reticle + Surface Normal Yellow Vector Arrow
        private func setupRaycastReticleWithNormalVector(in arView: ARView) {
            let anchor = AnchorEntity(world: .zero)

            // Outer Target Ring
            let outerRingMesh = MeshResource.generatePlane(width: 0.26, depth: 0.26, cornerRadius: 0.13)
            var outerMat = SimpleMaterial(color: UIColor(red: 1.0, green: 0.839, blue: 0.039, alpha: 0.72), isMetallic: true)
            outerMat.roughness = MaterialScalarParameter.float(0.2)
            let outerRing = ModelEntity(mesh: outerRingMesh, materials: [outerMat])

            // Inner Hit Diamond / Dot (matches the yellow hit diamond in Image 3)
            let innerDotMesh = MeshResource.generatePlane(width: 0.05, depth: 0.05, cornerRadius: 0.025)
            var innerMat = SimpleMaterial(color: UIColor.white, isMetallic: false)
            innerMat.roughness = MaterialScalarParameter.float(0.1)
            let innerDot = ModelEntity(mesh: innerDotMesh, materials: [innerMat])
            innerDot.position = [0, 0.001, 0]
            outerRing.addChild(innerDot)

            // Image 3: Surface Normal Upward Vector Indicator (Yellow Raycast Normal Shaft)
            let shaftMesh = MeshResource.generateBox(width: 0.006, height: 0.12, depth: 0.006, cornerRadius: 0.003)
            var yellowMat = SimpleMaterial(color: UIColor(red: 1.0, green: 0.78, blue: 0.0, alpha: 0.9), isMetallic: false)
            yellowMat.roughness = MaterialScalarParameter.float(0.2)
            let normalShaft = ModelEntity(mesh: shaftMesh, materials: [yellowMat])
            normalShaft.position = [0, 0.06, 0]
            outerRing.addChild(normalShaft)
            self.surfaceNormalArrowEntity = normalShaft

            anchor.addChild(outerRing)
            arView.scene.addAnchor(anchor)

            outerRing.isEnabled = false
            self.reticleEntity = outerRing
            self.reticleAnchor = anchor
        }

        // MARK: - Image 1: Setup UIGesture + RealityKit EntityGesture
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

        // MARK: - Tap Handler: Perform Raycast -> CollisionCastHit / ARRaycastResult -> Place WorldAnchor + USDZ Entity
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            let tapPoint = gesture.location(in: arView)

            if viewModel.isPlaced {
                // Image 3: Test CollisionCastHit against placed entity or scene collision mesh
                if let ray = arView.ray(through: tapPoint) {
                    let hits = arView.scene.raycast(origin: ray.origin, direction: ray.direction, length: 10.0, query: .nearest)
                    if let hit = hits.first {
                        viewModel.lastCollisionCastHitDistance = hit.distance
                        viewModel.lastCollisionCastNormal = hit.normal
                        viewModel.lastCollisionPosition = hit.position
                        SpatialSoundHelper.shared.playSnapHaptic()
                    }
                }
                return
            }

            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)

            // 1. First try RealityKit Scene Raycast (`CollisionCastHit` against StaticMesh / Scene Collision - Image 3)
            if let ray = arView.ray(through: center) {
                let collisionHits = arView.scene.raycast(origin: ray.origin, direction: ray.direction, length: 8.0, query: .nearest)
                if let hit = collisionHits.first {
                    viewModel.lastCollisionCastHitDistance = hit.distance
                    viewModel.lastCollisionCastNormal = hit.normal
                    viewModel.lastCollisionPosition = hit.position
                    var matrix = matrix_identity_float4x4
                    matrix.columns.3 = SIMD4<Float>(hit.position.x, hit.position.y, hit.position.z, 1.0)
                    executeWorldAnchorPlacement(at: matrix)
                    return
                }
            }

            // 2. Fallback to ARKit Plane Raycast (`arView.raycast`)
            let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)
            if let firstResult = results.first {
                executeWorldAnchorPlacement(at: firstResult.worldTransform)
            } else {
                SpatialSoundHelper.shared.playWarningHaptic()
                viewModel.statusMessage = "يرجى توجيه الكاميرا نحو سطح مستقر أولاً"
            }
        }

        // MARK: - Image 4: WorldAnchor (.transform) -> Entity(Transform + Model(USDZ) + Collision)
        private func executeWorldAnchorPlacement(at worldTransform: simd_float4x4) {
            guard let arView = arView else { return }

            SpatialSoundHelper.shared.playPlacementHaptic()

            // Image 4: Create persistent ARAnchor ("WorldAnchor") in ARSession at the raycast hit transform
            let worldARAnchor = ARAnchor(name: "WorldAnchor_\(viewModel.artifact.id)", transform: worldTransform)
            arView.session.add(anchor: worldARAnchor)
            self.activeWorldARAnchor = worldARAnchor
            viewModel.activeWorldAnchorCount = 1

            let anchorEntity = AnchorEntity(world: worldTransform)
            anchorEntity.name = "WorldAnchorEntity_\(viewModel.artifact.id)"

            // Load Universal Scene Description (.usdz) Entity with ModelComponent + CollisionComponent
            let modelEntity = RealityComposerContentBundle.shared.loadUSDEntity(for: viewModel.artifact)
            let baseScale = viewModel.artifact.model.scale
            modelEntity.scale = SIMD3<Float>(repeating: baseScale * viewModel.scaleMultiplier)

            // Image 1: Install native RealityKit EntityGestures (.translation, .rotation, .scale) on the HasCollision entity
            arView.installGestures([.translation, .rotation, .scale], for: modelEntity)

            // Smooth Spring Drop Animation onto the WorldAnchor plane
            modelEntity.position = [0, 0.14, 0]
            anchorEntity.addChild(modelEntity)
            arView.scene.addAnchor(anchorEntity)

            var targetTransform = modelEntity.transform
            targetTransform.translation.y = 0
            modelEntity.move(to: targetTransform, relativeTo: anchorEntity, duration: 0.36, timingFunction: .easeOut)

            self.placedAnchor = anchorEntity
            self.currentModelEntity = modelEntity
            viewModel.placedEntity = modelEntity
            viewModel.isPlaced = true
            reticleEntity?.isEnabled = false

            let pos = worldTransform.columns.3
            viewModel.lastCollisionPosition = SIMD3<Float>(pos.x, pos.y, pos.z)
            viewModel.statusMessage = "تم تثبيت WorldAnchor بنجاح! اسحب أو كبّر أو دوّر المجسم"
            SpatialSoundHelper.shared.playSuccessHaptic()
        }

        // MARK: - 1-Finger Raycast Surface-Clamped Pan (Updates WorldAnchor Transform)
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let arView = arView, let anchor = placedAnchor, viewModel.isPlaced else { return }

            let location = gesture.location(in: arView)

            // Image 3: Raycast against Collision mesh first, then AR estimated plane
            if let ray = arView.ray(through: location) {
                let hits = arView.scene.raycast(origin: ray.origin, direction: ray.direction, length: 8.0, query: .nearest)
                if let hit = hits.first, hit.entity != currentModelEntity {
                    anchor.position = hit.position
                    viewModel.lastCollisionCastHitDistance = hit.distance
                    viewModel.lastCollisionCastNormal = hit.normal
                    viewModel.lastCollisionPosition = hit.position
                    return
                }
            }

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

        // MARK: - 2-Finger Pinch: Smooth Scaling with 1:1 True Scale Snap
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

        // MARK: - 2-Finger Rotate: Smooth Y-Axis Twist
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

        // MARK: - Image 2: ARSessionDelegate — Convert ARMeshAnchor -> Entity(Transform + StaticMesh CollisionComponent)
        nonisolated public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            Task { @MainActor [weak self] in
                self?.processMeshAnchors(anchors)
            }
        }

        nonisolated public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            Task { @MainActor [weak self] in
                self?.processMeshAnchors(anchors)
            }
        }

        @MainActor
        private func processMeshAnchors(_ anchors: [ARAnchor]) {
            guard let meshRoot = meshRootAnchor else { return }
            var addedOrUpdated = false

            for anchor in anchors {
                guard let meshAnchor = anchor as? ARMeshAnchor else { continue }
                addedOrUpdated = true

                // Image 2: MeshAnchor -> .transform -> Entity.transform
                let entity = meshCollisionEntities[meshAnchor.identifier] ?? {
                    let e = Entity()
                    e.name = "MeshAnchor_\(meshAnchor.identifier)"
                    meshRoot.addChild(e)
                    meshCollisionEntities[meshAnchor.identifier] = e
                    return e
                }()
                entity.transform = Transform(matrix: meshAnchor.transform)

                // Image 2: MeshAnchor -> generateStaticMesh() -> CollisionComponent
                if let shape = try? ShapeResource.generateStaticMesh(from: meshAnchor) {
                    entity.components.set(CollisionComponent(shapes: [shape], mode: .default))
                }
            }

            if addedOrUpdated {
                viewModel.activeMeshAnchorCount = meshCollisionEntities.count
            }
        }

        // MARK: - Image 3: ARSessionDelegate — Per-Frame Raycast & CollisionCastHit Normal Evaluation
        nonisolated public func session(_ session: ARSession, didUpdate frame: ARFrame) {
            Task { @MainActor [weak self] in
                guard let self = self, let arView = self.arView, !self.viewModel.isPlaced else { return }

                let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)

                // 1. Check Scene CollisionCastHit (Image 3)
                if let ray = arView.ray(through: center) {
                    let collisionHits = arView.scene.raycast(origin: ray.origin, direction: ray.direction, length: 8.0, query: .nearest)
                    if let hit = collisionHits.first {
                        self.viewModel.lastCollisionCastHitDistance = hit.distance
                        self.viewModel.lastCollisionCastNormal = hit.normal
                        self.viewModel.lastCollisionPosition = hit.position
                    }
                }

                // 2. Check ARKit Plane Raycast for Reticle Transform
                let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)
                if let result = results.first {
                    if !self.viewModel.isSurfaceDetected {
                        self.viewModel.isSurfaceDetected = true
                        SpatialSoundHelper.shared.playSurfaceDetectedHaptic()
                        self.viewModel.statusMessage = "تم رصدCollisionCastHit! انقر لتثبيت WorldAnchor"
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
                        self.viewModel.statusMessage = "حرك الكاميرا ببطء لمسح MeshAnchor وأسطح الغرفة..."
                    }
                    self.reticleEntity?.isEnabled = false
                }
            }
        }
    }
}

// MARK: - ShapeResource.generateStaticMesh(from: ARMeshAnchor) Extension (Image 2)
extension ShapeResource {
    /// Generates a RealityKit static triangle mesh collision shape directly from an ARKit LiDAR `ARMeshAnchor`
    /// exactly as depicted in Apple's Spatial Computing Raycasting architecture (Image 2).
    public static func generateStaticMesh(from meshAnchor: ARMeshAnchor) throws -> ShapeResource {
        let geometry = meshAnchor.geometry
        let vertices = geometry.vertices
        let faces = geometry.faces

        var positions: [SIMD3<Float>] = []
        positions.reserveCapacity(vertices.count)

        let vertexBuffer = vertices.buffer.contents()
        for i in 0..<vertices.count {
            let offset = vertices.offset + (i * vertices.stride)
            let ptr = vertexBuffer.advanced(by: offset).assumingMemoryBound(to: SIMD3<Float>.self)
            positions.append(ptr.pointee)
        }

        var indices: [UInt32] = []
        indices.reserveCapacity(faces.count * 3)
        let indexBuffer = faces.buffer.contents()
        let bytesPerIndex = faces.bytesPerIndex

        for i in 0..<(faces.count * 3) {
            let offset = i * bytesPerIndex
            if bytesPerIndex == 4 {
                let idx = indexBuffer.advanced(by: offset).assumingMemoryBound(to: UInt32.self).pointee
                indices.append(idx)
            } else {
                let idx = indexBuffer.advanced(by: offset).assumingMemoryBound(to: UInt16.self).pointee
                indices.append(UInt32(idx))
            }
        }

        return try ShapeResource.generateStaticMesh(positions: positions, faceIndices: indices)
    }
}
