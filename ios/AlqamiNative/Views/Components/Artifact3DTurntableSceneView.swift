import SwiftUI
import SceneKit

// MARK: - Interactive 3D Turntable SceneView
public struct Artifact3DTurntableSceneView: UIViewRepresentable {
    public let artifact: Artifact
    public var autoRotate: Bool = true
    public var lightPreset: StudioLightPreset = .museumWarm

    public enum StudioLightPreset: String, CaseIterable, Identifiable {
        case museumWarm = "متحفي دافئ"
        case studioSoft = "استوديو ناعم"
        case daylight = "ضوء النهار"

        public var id: String { rawValue }

        public func label(isArabic: Bool) -> String {
            switch self {
            case .museumWarm: return isArabic ? "متحفي دافئ" : "Museum Warm"
            case .studioSoft: return isArabic ? "استوديو" : "Studio Soft"
            case .daylight: return isArabic ? "ضوء النهار" : "Daylight"
            }
        }
    }

    public func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false

        let scene = SCNScene()
        setupLighting(in: scene)
        setupCamera(in: scene)
        setupModel(in: scene)

        scnView.scene = scene
        return scnView
    }

    public func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }

        // Update lights according to preset
        if let keyLight = scene.rootNode.childNode(withName: "keyLight", recursively: true)?.light {
            switch lightPreset {
            case .museumWarm:
                keyLight.color = UIColor(red: 1.0, green: 0.92, blue: 0.80, alpha: 1.0)
                keyLight.intensity = 1100
            case .studioSoft:
                keyLight.color = UIColor.white
                keyLight.intensity = 950
            case .daylight:
                keyLight.color = UIColor(red: 0.88, green: 0.94, blue: 1.0, alpha: 1.0)
                keyLight.intensity = 1300
            }
        }
    }

    private func setupLighting(in scene: SCNScene) {
        // Key Directional Light with Shadows
        let keyLightNode = SCNNode()
        keyLightNode.name = "keyLight"
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.castsShadow = true
        keyLight.color = UIColor(red: 1.0, green: 0.92, blue: 0.80, alpha: 1.0)
        keyLight.intensity = 1100
        keyLightNode.light = keyLight
        keyLightNode.position = SCNVector3(x: 2, y: 4, z: 3)
        keyLightNode.eulerAngles = SCNVector3(x: -Float.pi / 4, y: Float.pi / 5, z: 0)
        scene.rootNode.addChildNode(keyLightNode)

        // Fill Soft Light
        let fillLightNode = SCNNode()
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.color = UIColor(red: 0.6, green: 0.7, blue: 0.9, alpha: 1.0)
        fillLight.intensity = 450
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(x: -3, y: 1, z: 2)
        scene.rootNode.addChildNode(fillLightNode)

        // Ambient Light
        let ambientNode = SCNNode()
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = UIColor(white: 0.28, alpha: 1.0)
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)
    }

    private func setupCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 0.05
        camera.zFar = 100
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0.25, z: 0.95)
        cameraNode.eulerAngles = SCNVector3(x: -0.15, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
    }

    private func setupModel(in scene: SCNScene) {
        let modelContainer = SCNNode()
        modelContainer.name = "artifactModel"

        // Build procedural PBR geometry
        let primaryColor = UIColor(hex: artifact.model.primaryColorHex) ?? UIColor.systemBrown
        let secondaryColor = UIColor(hex: artifact.model.secondaryColorHex) ?? UIColor.systemYellow

        let geometryNode = createProceduralSCNNode(for: artifact.model.archetype, primary: primaryColor, secondary: secondaryColor)
        modelContainer.addChildNode(geometryNode)

        // Gentle auto-rotation
        if autoRotate {
            let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 24))
            modelContainer.runAction(rotateAction)
        }

        scene.rootNode.addChildNode(modelContainer)
    }

    private func createProceduralSCNNode(for archetype: Artifact3DArchetype, primary: UIColor, secondary: UIColor) -> SCNNode {
        let node = SCNNode()

        switch archetype {
        case .manuscriptBook:
            let box = SCNBox(width: 0.32, height: 0.08, length: 0.44, chamferRadius: 0.015)
            box.firstMaterial?.diffuse.contents = primary
            box.firstMaterial?.roughness.contents = 0.65
            box.firstMaterial?.metalness.contents = 0.2
            let book = SCNNode(geometry: box)
            node.addChildNode(book)

            // Gold ornament on top
            let disc = SCNCylinder(radius: 0.06, height: 0.005)
            disc.firstMaterial?.diffuse.contents = secondary
            disc.firstMaterial?.metalness.contents = 0.9
            let discNode = SCNNode(geometry: disc)
            discNode.position = SCNVector3(0, 0.042, 0)
            node.addChildNode(discNode)

        case .worldTablet, .cuneiformClay:
            let box = SCNBox(width: 0.26, height: 0.06, length: 0.34, chamferRadius: 0.035)
            box.firstMaterial?.diffuse.contents = primary
            box.firstMaterial?.roughness.contents = 0.9
            node.addChildNode(SCNNode(geometry: box))

        case .battleHelmet:
            let cone = SCNCone(topRadius: 0.02, bottomRadius: 0.18, height: 0.32)
            cone.firstMaterial?.diffuse.contents = primary
            cone.firstMaterial?.metalness.contents = 0.88
            cone.firstMaterial?.roughness.contents = 0.25
            node.addChildNode(SCNNode(geometry: cone))

        case .curvedSword:
            let blade = SCNBox(width: 0.06, height: 0.01, length: 0.78, chamferRadius: 0.005)
            blade.firstMaterial?.diffuse.contents = primary
            blade.firstMaterial?.metalness.contents = 0.95
            node.addChildNode(SCNNode(geometry: blade))

        case .stoneStele:
            let stele = SCNBox(width: 0.28, height: 0.68, length: 0.20, chamferRadius: 0.04)
            stele.firstMaterial?.diffuse.contents = primary
            stele.firstMaterial?.roughness.contents = 0.85
            node.addChildNode(SCNNode(geometry: stele))

        case .prayerMihrab:
            let arch = SCNBox(width: 0.42, height: 0.65, length: 0.12, chamferRadius: 0.05)
            arch.firstMaterial?.diffuse.contents = primary
            arch.firstMaterial?.metalness.contents = 0.5
            node.addChildNode(SCNNode(geometry: arch))

        case .bronzeBowl, .ceramicBowl:
            let bowl = SCNCylinder(radius: 0.22, height: 0.14)
            bowl.firstMaterial?.diffuse.contents = primary
            bowl.firstMaterial?.metalness.contents = 0.75
            node.addChildNode(SCNNode(geometry: bowl))

        case .astrolabeInstrument:
            let disc = SCNCylinder(radius: 0.22, height: 0.02)
            disc.firstMaterial?.diffuse.contents = primary
            disc.firstMaterial?.metalness.contents = 0.92
            node.addChildNode(SCNNode(geometry: disc))

        case .damascusDagger:
            let dagger = SCNBox(width: 0.05, height: 0.01, length: 0.48, chamferRadius: 0.005)
            dagger.firstMaterial?.diffuse.contents = primary
            dagger.firstMaterial?.metalness.contents = 0.95
            node.addChildNode(SCNNode(geometry: dagger))
        }

        return node
    }
}

