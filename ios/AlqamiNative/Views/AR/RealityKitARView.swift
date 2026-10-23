import SwiftUI
import RealityKit
import ARKit
import Combine

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
    public class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        var viewModel: ARViewModel
        var reticleEntity: ModelEntity?
        var planeAnchor: AnchorEntity?
        var currentModelEntity: ModelEntity?
        private var cancellables = Set<AnyCancellable>()

        init(viewModel: ARViewModel) {
            self.viewModel = viewModel
            super.init()
        }

        func setup(arView: ARView, viewModel: ARViewModel) {
            self.arView = arView
            self.viewModel = viewModel

            // Configure ARSession using ARSessionManager
            ARSessionManager.shared.configureSession(for: arView, enableOcclusion: viewModel.isOcclusionEnabled)
            arView.session.delegate = self

            // Create 3D Focus Reticle
            setupReticle(in: arView)

            // Setup Tap Gesture for Placement
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tapGesture)
        }

        func update(viewModel: ARViewModel) {
            self.viewModel = viewModel
            if !viewModel.isPlaced && currentModelEntity != nil {
                currentModelEntity?.removeFromParent()
                currentModelEntity = nil
            }
        }

        private func setupReticle(in arView: ARView) {
            let mesh = MeshResource.generatePlane(width: 0.24, depth: 0.24, cornerRadius: 0.12)
            let material = SimpleMaterial(color: UIColor.white.withAlphaComponent(0.85), isMetallic: true)

            let reticle = ModelEntity(mesh: mesh, materials: [material])
            let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, 0))
            anchor.addChild(reticle)
            arView.scene.addAnchor(anchor)
            reticle.isEnabled = false

            self.reticleEntity = reticle
            self.planeAnchor = anchor
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            if viewModel.isPlaced {
                SpatialSoundHelper.shared.playSnapHaptic()
                return
            }

            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)

            if let firstResult = results.first {
                placeModel(at: firstResult)
            } else {
                SpatialSoundHelper.shared.playWarningHaptic()
            }
        }

        private func placeModel(at raycastResult: ARRaycastResult) {
            guard let arView = arView else { return }

            SpatialSoundHelper.shared.playPlacementHaptic()
            viewModel.statusMessage = "جاري تحميل وتثبيت المجسم في المكان..."

            let anchor = AnchorEntity(world: raycastResult.worldTransform)

            let modelName = (viewModel.artifact.model.usdzFilename as NSString).deletingPathExtension

            // Try loading model from Bundle
            Entity.loadModelAsync(named: modelName)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case .failure(let error) = completion {
                        self.placeRepresentativeEntity(on: anchor)
                        self.viewModel.modelLoadError = "تم استخدام مجسم محاكاة (Asset: \(modelName).usdz): \(error.localizedDescription)"
                    }
                }, receiveValue: { [weak self] loadedModel in
                    guard let self = self else { return }
                    self.finalizePlacement(modelEntity: loadedModel, on: anchor)
                })
                .store(in: &cancellables)
        }

        private func placeRepresentativeEntity(on anchor: AnchorEntity) {
            let mesh = MeshResource.generateBox(width: 0.28, height: 0.06, depth: 0.20, cornerRadius: 0.01)
            let material = SimpleMaterial(color: UIColor(red: 0.72, green: 0.58, blue: 0.36, alpha: 1.0), isMetallic: false)

            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            finalizePlacement(modelEntity: modelEntity, on: anchor)
        }

        private func finalizePlacement(modelEntity: ModelEntity, on anchor: AnchorEntity) {
            guard let arView = arView else { return }

            let baseScale = viewModel.artifact.model.scale
            modelEntity.scale = SIMD3<Float>(repeating: baseScale * viewModel.scaleMultiplier)

            modelEntity.generateCollisionShapes(recursive: true)
            anchor.addChild(modelEntity)
            arView.scene.addAnchor(anchor)
            arView.installGestures([.translation, .rotation, .scale], for: modelEntity)

            self.currentModelEntity = modelEntity
            viewModel.placedEntity = modelEntity
            viewModel.isPlaced = true
            reticleEntity?.isEnabled = false
            viewModel.statusMessage = "تم التثبيت بنجاح! يمكنك التدوير والتكبير والسحب"
            SpatialSoundHelper.shared.playSuccessHaptic()
        }

        // MARK: - ARSessionDelegate
        public func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let arView = arView, !viewModel.isPlaced else { return }

            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)

            if let result = results.first {
                DispatchQueue.main.async {
                    self.viewModel.isSurfaceDetected = true
                    self.reticleEntity?.isEnabled = true
                    self.planeAnchor?.transform = Transform(matrix: result.worldTransform)
                }
            } else {
                DispatchQueue.main.async {
                    self.viewModel.isSurfaceDetected = false
                    self.reticleEntity?.isEnabled = false
                }
            }
        }
    }
}
