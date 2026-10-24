import SwiftUI
import SceneKit
import SceneKit.ModelIO

// MARK: - Interactive 3D Turntable SceneView (Loads Real Bundled USDZ Models + Live LightingManager)
public struct Artifact3DTurntableSceneView: UIViewRepresentable {
    public let artifact: Artifact
    public var autoRotate: Bool = true
    public var allowsCameraControl: Bool = true
    public var cameraDistance: Float = 0.72
    @ObservedObject private var lighting = LightingManager.shared

    public init(
        artifact: Artifact,
        autoRotate: Bool = true,
        allowsCameraControl: Bool = true,
        cameraDistance: Float = 0.72
    ) {
        self.artifact = artifact
        self.autoRotate = autoRotate
        self.allowsCameraControl = allowsCameraControl
        self.cameraDistance = cameraDistance
    }

    public func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = allowsCameraControl
        scnView.autoenablesDefaultLighting = false
        scnView.defaultCameraController.interactionMode = .orbitTurntable

        let scene = SCNScene()
        setupLighting(in: scene)
        setupCamera(in: scene)
        setupModel(in: scene)

        scnView.scene = scene
        context.coordinator.currentArtifactId = artifact.id
        return scnView
    }

    public func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }

        // Reload 3D model if artifact changed
        if context.coordinator.currentArtifactId != artifact.id {
            context.coordinator.currentArtifactId = artifact.id
            scene.rootNode.childNode(withName: "artifactModel", recursively: false)?.removeFromParentNode()
            setupModel(in: scene)
        }

        // Apply live lighting preset & brightness from LightingManager
        applyLightingPreset(in: scene)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator {
        var currentArtifactId: String = ""
    }

    private func setupLighting(in scene: SCNScene) {
        // Key Directional Light
        let keyLightNode = SCNNode()
        keyLightNode.name = "keyLight"
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.castsShadow = true
        keyLight.shadowRadius = 6
        keyLight.shadowColor = UIColor.black.withAlphaComponent(0.32)
        keyLightNode.light = keyLight
        keyLightNode.position = SCNVector3(x: 2.5, y: 4.5, z: 3.5)
        keyLightNode.eulerAngles = SCNVector3(x: -Float.pi / 4, y: Float.pi / 5, z: 0)
        scene.rootNode.addChildNode(keyLightNode)

        // Secondary Fill Directional Light
        let fillLightNode = SCNNode()
        fillLightNode.name = "fillLight"
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(x: -3.0, y: 2.0, z: -2.0)
        scene.rootNode.addChildNode(fillLightNode)

        // Point Accent Light
        let pointLightNode = SCNNode()
        pointLightNode.name = "pointLight"
        let pointLight = SCNLight()
        pointLight.type = .omni
        pointLightNode.light = pointLight
        pointLightNode.position = SCNVector3(x: 0.0, y: 2.2, z: 2.0)
        scene.rootNode.addChildNode(pointLightNode)

        // Ambient Light
        let ambientNode = SCNNode()
        ambientNode.name = "ambientLight"
        let ambient = SCNLight()
        ambient.type = .ambient
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        applyLightingPreset(in: scene)
    }

    private func applyLightingPreset(in scene: SCNScene) {
        let preset = lighting.currentPreset
        let mult = CGFloat(lighting.brightness)

        if let keyLight = scene.rootNode.childNode(withName: "keyLight", recursively: false)?.light {
            keyLight.color = UIColor(hex: preset.dir1ColorHex) ?? .white
            keyLight.intensity = CGFloat(preset.dir1Intensity * 750) * mult
        }
        if let fillLight = scene.rootNode.childNode(withName: "fillLight", recursively: false)?.light {
            fillLight.color = UIColor(hex: preset.dir2ColorHex) ?? .white
            fillLight.intensity = CGFloat(preset.dir2Intensity * 650) * mult
        }
        if let pointLight = scene.rootNode.childNode(withName: "pointLight", recursively: false)?.light {
            pointLight.color = UIColor(hex: preset.pointColorHex) ?? .white
            pointLight.intensity = CGFloat(preset.pointIntensity * 550) * mult
        }
        if let ambient = scene.rootNode.childNode(withName: "ambientLight", recursively: false)?.light {
            ambient.color = UIColor(hex: preset.ambientColorHex) ?? .white
            ambient.intensity = CGFloat(preset.ambientIntensity * 550) * mult
        }
    }

    private func setupCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.name = "mainCamera"
        let camera = SCNCamera()
        camera.zNear = 0.02
        camera.zFar = 50
        camera.fieldOfView = 38
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0.06, z: cameraDistance)
        cameraNode.eulerAngles = SCNVector3(x: -0.08, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
    }

    private func setupModel(in scene: SCNScene) {
        let modelContainer = SCNNode()
        modelContainer.name = "artifactModel"

        // 1. Load the real bundled .usdz 3D model
        if let usdzURL = BundleImageLoader.usdzURL(named: artifact.model.usdzFilename),
           let loadedScene = try? SCNScene(url: usdzURL, options: [.checkConsistency: false]) {
            let wrapper = SCNNode()
            for child in loadedScene.rootNode.childNodes {
                wrapper.addChildNode(child.clone())
            }

            // Center and normalize to fit studio viewport cleanly
            let (minVec, maxVec) = wrapper.boundingBox
            let dx = maxVec.x - minVec.x
            let dy = maxVec.y - minVec.y
            let dz = maxVec.z - minVec.z
            let maxDim = max(dx, max(dy, dz))
            if maxDim > 0.0001 {
                let targetExtent: Float = 0.38
                let scale = targetExtent / maxDim
                wrapper.scale = SCNVector3(scale, scale, scale)
                let cx = (minVec.x + maxVec.x) * 0.5 * scale
                let cy = (minVec.y + maxVec.y) * 0.5 * scale
                let cz = (minVec.z + maxVec.z) * 0.5 * scale
                wrapper.position = SCNVector3(-cx, -cy, -cz)
            }

            // Ensure PBR lighting model on all child geometries
            wrapper.enumerateChildNodes { node, _ in
                if let geo = node.geometry {
                    for mat in geo.materials {
                        mat.lightingModel = .physicallyBased
                    }
                }
            }

            modelContainer.addChildNode(wrapper)
        } else {
            // Fallback procedural geometry if USDZ isn't found
            let primaryColor = UIColor(hex: artifact.model.primaryColorHex) ?? UIColor.systemBrown
            let secondaryColor = UIColor(hex: artifact.model.secondaryColorHex) ?? UIColor.systemYellow
            let fallbackNode = createProceduralSCNNode(for: artifact.model.archetype, primary: primaryColor, secondary: secondaryColor)
            modelContainer.addChildNode(fallbackNode)
        }

        if autoRotate {
            let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 22))
            modelContainer.runAction(rotateAction)
        }

        scene.rootNode.addChildNode(modelContainer)
    }

    private func createProceduralSCNNode(for archetype: Artifact3DArchetype, primary: UIColor, secondary: UIColor) -> SCNNode {
        let node = SCNNode()
        let box = SCNBox(width: 0.28, height: 0.28, length: 0.28, chamferRadius: 0.04)
        box.firstMaterial?.lightingModel = .physicallyBased
        box.firstMaterial?.diffuse.contents = primary
        box.firstMaterial?.metalness.contents = secondary
        node.addChildNode(SCNNode(geometry: box))
        return node
    }
}
