import Foundation
import UIKit
import RealityKit
import ARKit

public final class Artifact3DEntityBuilder {
    public static let shared = Artifact3DEntityBuilder()

    private init() {}

    // MARK: - Build RealityKit Entity for Artifact
    @MainActor
    public func createEntity(for artifact: Artifact) -> ModelEntity {
        let root = ModelEntity()
        root.name = artifact.id

        let archetype = artifact.model.archetype
        let primaryColor = UIColor(hex: artifact.model.primaryColorHex) ?? UIColor.systemBrown
        let secondaryColor = UIColor(hex: artifact.model.secondaryColorHex) ?? UIColor.systemYellow

        switch archetype {
        case .manuscriptBook:
            buildManuscriptBook(into: root, primaryColor: primaryColor, goldColor: secondaryColor)
        case .worldTablet, .cuneiformClay:
            buildClayTablet(into: root, clayColor: primaryColor)
        case .battleHelmet:
            buildBattleHelmet(into: root, steelColor: primaryColor, goldColor: secondaryColor)
        case .curvedSword:
            buildZulfiqarSword(into: root, steelColor: primaryColor, goldColor: secondaryColor)
        case .stoneStele:
            buildStoneStele(into: root, basaltColor: primaryColor)
        case .prayerMihrab:
            buildPrayerMihrab(into: root, blueColor: primaryColor, turquoiseColor: secondaryColor)
        case .bronzeBowl:
            buildBronzeBowl(into: root, brassColor: primaryColor)
        case .ceramicBowl:
            buildCeramicBowl(into: root, creamColor: primaryColor, goldColor: secondaryColor)
        case .astrolabeInstrument:
            buildAstrolabe(into: root, brassColor: primaryColor, darkBrassColor: secondaryColor)
        case .damascusDagger:
            buildDamascusDagger(into: root, steelColor: primaryColor, goldColor: secondaryColor)
        }

        // Add Soft Contact Ground Shadow
        addContactShadow(to: root, radius: 0.28)

        // Generate accurate collision shapes for raycast and gestures
        root.generateCollisionShapes(recursive: true)
        return root
    }

    // MARK: - 1. Manuscript Book (Nahj al-Balagha)
    private func buildManuscriptBook(into root: ModelEntity, primaryColor: UIColor, goldColor: UIColor) {
        // Book Body / Binding (Leather Cover)
        let coverMesh = MeshResource.generateBox(width: 0.22, height: 0.05, depth: 0.30, cornerRadius: 0.008)
        var coverMat = SimpleMaterial(color: primaryColor, roughness: 0.65, isMetallic: false)
        let coverEntity = ModelEntity(mesh: coverMesh, materials: [coverMat])
        coverEntity.position = [0, 0.025, 0]
        root.addChild(coverEntity)

        // Page Block (Cream/Gold paper block inset)
        let pagesMesh = MeshResource.generateBox(width: 0.21, height: 0.042, depth: 0.285, cornerRadius: 0.002)
        var pagesMat = SimpleMaterial(color: UIColor(red: 0.96, green: 0.92, blue: 0.82, alpha: 1.0), roughness: 0.85, isMetallic: false)
        let pagesEntity = ModelEntity(mesh: pagesMesh, materials: [pagesMat])
        pagesEntity.position = [0.004, 0.025, 0]
        root.addChild(pagesEntity)

        // Center Gold Medallion / Shamsa on Cover
        let medallionMesh = MeshResource.generatePlane(width: 0.08, depth: 0.08, cornerRadius: 0.04)
        var goldMat = SimpleMaterial(color: goldColor, roughness: 0.25, isMetallic: true)
        let medallion = ModelEntity(mesh: medallionMesh, materials: [goldMat])
        medallion.position = [0, 0.051, 0]
        root.addChild(medallion)
    }

    // MARK: - 2. Clay Tablet (Babylonian Map & Cuneiform)
    private func buildClayTablet(into root: ModelEntity, clayColor: UIColor) {
        let tabletMesh = MeshResource.generateBox(width: 0.16, height: 0.038, depth: 0.22, cornerRadius: 0.025)
        var tabletMat = SimpleMaterial(color: clayColor, roughness: 0.92, isMetallic: false)
        let tablet = ModelEntity(mesh: tabletMesh, materials: [tabletMat])
        tablet.position = [0, 0.019, 0]
        root.addChild(tablet)

        // Decorative Inscribed Concentric Rings on Surface
        let ringMesh = MeshResource.generatePlane(width: 0.11, depth: 0.11, cornerRadius: 0.055)
        var ringMat = SimpleMaterial(color: clayColor.withAlphaComponent(0.8), roughness: 0.98, isMetallic: false)
        let ring = ModelEntity(mesh: ringMesh, materials: [ringMat])
        ring.position = [0, 0.039, 0]
        root.addChild(ring)
    }

    // MARK: - 3. Battle Helmet (Islamic Helmet)
    private func buildBattleHelmet(into root: ModelEntity, steelColor: UIColor, goldColor: UIColor) {
        // Conical Dome
        let domeMesh = MeshResource.generateBox(width: 0.22, height: 0.24, depth: 0.22, cornerRadius: 0.10)
        var steelMat = SimpleMaterial(color: steelColor, roughness: 0.28, isMetallic: true)
        let dome = ModelEntity(mesh: domeMesh, materials: [steelMat])
        dome.position = [0, 0.12, 0]
        root.addChild(dome)

        // Top Brass Spike
        let spikeMesh = MeshResource.generateBox(width: 0.025, height: 0.08, depth: 0.025, cornerRadius: 0.01)
        var goldMat = SimpleMaterial(color: goldColor, roughness: 0.22, isMetallic: true)
        let spike = ModelEntity(mesh: spikeMesh, materials: [goldMat])
        spike.position = [0, 0.27, 0]
        root.addChild(spike)

        // Gilded Brow Band
        let bandMesh = MeshResource.generatePlane(width: 0.23, depth: 0.23, cornerRadius: 0.115)
        let band = ModelEntity(mesh: bandMesh, materials: [goldMat])
        band.position = [0, 0.06, 0]
        root.addChild(band)
    }

    // MARK: - 4. Zulfiqar Sword
    private func buildZulfiqarSword(into root: ModelEntity, steelColor: UIColor, goldColor: UIColor) {
        // Main Blade
        let bladeMesh = MeshResource.generateBox(width: 0.055, height: 0.008, depth: 0.72, cornerRadius: 0.004)
        var steelMat = SimpleMaterial(color: steelColor, roughness: 0.18, isMetallic: true)
        let blade = ModelEntity(mesh: bladeMesh, materials: [steelMat])
        blade.position = [0, 0.006, 0.15]
        root.addChild(blade)

        // Split Bifurcated Tips (Dual Point)
        let tip1Mesh = MeshResource.generateBox(width: 0.022, height: 0.008, depth: 0.16, cornerRadius: 0.003)
        let tip1 = ModelEntity(mesh: tip1Mesh, materials: [steelMat])
        tip1.position = [-0.018, 0.006, 0.52]
        root.addChild(tip1)

        let tip2 = ModelEntity(mesh: tip1Mesh, materials: [steelMat])
        tip2.position = [0.018, 0.006, 0.52]
        root.addChild(tip2)

        // Gilded Crossguard Quillons
        let guardMesh = MeshResource.generateBox(width: 0.18, height: 0.016, depth: 0.032, cornerRadius: 0.006)
        var goldMat = SimpleMaterial(color: goldColor, roughness: 0.22, isMetallic: true)
        let guardEntity = ModelEntity(mesh: guardMesh, materials: [goldMat])
        guardEntity.position = [0, 0.008, -0.21]
        root.addChild(guardEntity)

        // Handle Grip
        let gripMesh = MeshResource.generateBox(width: 0.035, height: 0.024, depth: 0.15, cornerRadius: 0.01)
        var gripMat = SimpleMaterial(color: UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.0), roughness: 0.5, isMetallic: false)
        let grip = ModelEntity(mesh: gripMesh, materials: [gripMat])
        grip.position = [0, 0.01, -0.29]
        root.addChild(grip)
    }

    // MARK: - 5. Stone Stele (Hammurabi)
    private func buildStoneStele(into root: ModelEntity, basaltColor: UIColor) {
        // Monolith Pillar
        let steleMesh = MeshResource.generateBox(width: 0.22, height: 0.54, depth: 0.16, cornerRadius: 0.05)
        var basaltMat = SimpleMaterial(color: basaltColor, roughness: 0.82, isMetallic: false)
        let stele = ModelEntity(mesh: steleMesh, materials: [basaltMat])
        stele.position = [0, 0.27, 0]
        root.addChild(stele)

        // Top Relief Scene Header (Lighter tone)
        let reliefMesh = MeshResource.generateBox(width: 0.20, height: 0.14, depth: 0.15, cornerRadius: 0.04)
        var reliefMat = SimpleMaterial(color: basaltColor.withAlphaComponent(0.85), roughness: 0.88, isMetallic: false)
        let relief = ModelEntity(mesh: reliefMesh, materials: [reliefMat])
        relief.position = [0, 0.46, 0]
        root.addChild(relief)
    }

    // MARK: - 6. Prayer Mihrab
    private func buildPrayerMihrab(into root: ModelEntity, blueColor: UIColor, turquoiseColor: UIColor) {
        // Outer Architectural Arch Frame
        let frameMesh = MeshResource.generateBox(width: 0.38, height: 0.56, depth: 0.08, cornerRadius: 0.04)
        var cobaltMat = SimpleMaterial(color: blueColor, roughness: 0.35, isMetallic: true)
        let frame = ModelEntity(mesh: frameMesh, materials: [cobaltMat])
        frame.position = [0, 0.28, 0]
        root.addChild(frame)

        // Inner Recessed Niche
        let nicheMesh = MeshResource.generateBox(width: 0.26, height: 0.44, depth: 0.07, cornerRadius: 0.08)
        var turqMat = SimpleMaterial(color: turquoiseColor, roughness: 0.25, isMetallic: true)
        let niche = ModelEntity(mesh: nicheMesh, materials: [turqMat])
        niche.position = [0, 0.25, -0.01]
        root.addChild(niche)
    }

    // MARK: - 7. Bronze Bowl (Saqakhane)
    private func buildBronzeBowl(into root: ModelEntity, brassColor: UIColor) {
        let bowlMesh = MeshResource.generateBox(width: 0.26, height: 0.10, depth: 0.26, cornerRadius: 0.12)
        var brassMat = SimpleMaterial(color: brassColor, roughness: 0.38, isMetallic: true)
        let bowl = ModelEntity(mesh: bowlMesh, materials: [brassMat])
        bowl.position = [0, 0.05, 0]
        root.addChild(bowl)

        // Interior Rim Inset
        let rimMesh = MeshResource.generatePlane(width: 0.24, depth: 0.24, cornerRadius: 0.12)
        var darkMat = SimpleMaterial(color: brassColor.withAlphaComponent(0.6), roughness: 0.45, isMetallic: true)
        let rim = ModelEntity(mesh: rimMesh, materials: [darkMat])
        rim.position = [0, 0.098, 0]
        root.addChild(rim)
    }

    // MARK: - 8. Ceramic Bowl (Lusterware)
    private func buildCeramicBowl(into root: ModelEntity, creamColor: UIColor, goldColor: UIColor) {
        let bowlMesh = MeshResource.generateBox(width: 0.28, height: 0.12, depth: 0.28, cornerRadius: 0.13)
        var lusterMat = SimpleMaterial(color: creamColor, roughness: 0.22, isMetallic: true)
        let bowl = ModelEntity(mesh: bowlMesh, materials: [lusterMat])
        bowl.position = [0, 0.06, 0]
        root.addChild(bowl)

        // Golden Medallion
        let centerMesh = MeshResource.generatePlane(width: 0.14, depth: 0.14, cornerRadius: 0.07)
        var goldMat = SimpleMaterial(color: goldColor, roughness: 0.20, isMetallic: true)
        let center = ModelEntity(mesh: centerMesh, materials: [goldMat])
        center.position = [0, 0.115, 0]
        root.addChild(center)
    }

    // MARK: - 9. Astronomical Astrolabe
    private func buildAstrolabe(into root: ModelEntity, brassColor: UIColor, darkBrassColor: UIColor) {
        // Base Disc / Mater
        let discMesh = MeshResource.generatePlane(width: 0.26, depth: 0.26, cornerRadius: 0.13)
        var brassMat = SimpleMaterial(color: brassColor, roughness: 0.3, isMetallic: true)
        let disc = ModelEntity(mesh: discMesh, materials: [brassMat])
        disc.position = [0, 0.015, 0]
        root.addChild(disc)

        // Inner Rete Grid
        let reteMesh = MeshResource.generatePlane(width: 0.22, depth: 0.22, cornerRadius: 0.11)
        var reteMat = SimpleMaterial(color: darkBrassColor, roughness: 0.32, isMetallic: true)
        let rete = ModelEntity(mesh: reteMesh, materials: [reteMat])
        rete.position = [0, 0.017, 0]
        root.addChild(rete)

        // Top Throne Ring / Suspension Loop
        let ringMesh = MeshResource.generateBox(width: 0.05, height: 0.012, depth: 0.05, cornerRadius: 0.02)
        let ring = ModelEntity(mesh: ringMesh, materials: [brassMat])
        ring.position = [0, 0.018, -0.15]
        root.addChild(ring)

        // Rotating Alidade Sight Bar
        let barMesh = MeshResource.generateBox(width: 0.018, height: 0.01, depth: 0.24, cornerRadius: 0.004)
        let bar = ModelEntity(mesh: barMesh, materials: [brassMat])
        bar.position = [0, 0.020, 0]
        root.addChild(bar)
    }

    // MARK: - 10. Damascus Dagger (Jambiya)
    private func buildDamascusDagger(into root: ModelEntity, steelColor: UIColor, goldColor: UIColor) {
        // Curved Steel Blade
        let bladeMesh = MeshResource.generateBox(width: 0.045, height: 0.006, depth: 0.32, cornerRadius: 0.003)
        var steelMat = SimpleMaterial(color: steelColor, roughness: 0.20, isMetallic: true)
        let blade = ModelEntity(mesh: bladeMesh, materials: [steelMat])
        blade.position = [0, 0.005, 0.08]
        root.addChild(blade)

        // Jade Pistol-Grip Hilt
        let hiltMesh = MeshResource.generateBox(width: 0.055, height: 0.026, depth: 0.14, cornerRadius: 0.018)
        var jadeMat = SimpleMaterial(color: UIColor(red: 0.18, green: 0.42, blue: 0.32, alpha: 1.0), roughness: 0.4, isMetallic: false)
        let hilt = ModelEntity(mesh: hiltMesh, materials: [jadeMat])
        hilt.position = [0, 0.012, -0.12]
        root.addChild(hilt)

        // Gold Inlaid Quillons Ring
        let ringMesh = MeshResource.generateBox(width: 0.065, height: 0.016, depth: 0.022, cornerRadius: 0.006)
        var goldMat = SimpleMaterial(color: goldColor, roughness: 0.22, isMetallic: true)
        let ring = ModelEntity(mesh: ringMesh, materials: [goldMat])
        ring.position = [0, 0.010, -0.05]
        root.addChild(ring)
    }

    // MARK: - Soft Contact Ground Shadow Plane
    private func addContactShadow(to root: ModelEntity, radius: Float) {
        let shadowMesh = MeshResource.generatePlane(width: radius * 2, depth: radius * 2, cornerRadius: radius)
        let shadowColor = UIColor.black.withAlphaComponent(0.35)
        var shadowMat = SimpleMaterial(color: shadowColor, roughness: 1.0, isMetallic: false)
        let shadowEntity = ModelEntity(mesh: shadowMesh, materials: [shadowMat])
        shadowEntity.position = [0, 0.001, 0] // Sits right above surface to prevent z-fighting
        root.addChild(shadowEntity)
    }
}

// MARK: - UIColor Hex Extension
private extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
