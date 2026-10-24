import Foundation
import RealityKit
import ARKit
import SwiftUI

// MARK: - Universal Scene Description (USD / USDZ) & Reality Composer Pro Scene Graph Loader
// Implements the Apple Spatial Computing Architecture shown in Images 1, 2, 3, and 4:
// - Image 1: ARView / RealityView -> Scene / Content -> AnchorEntity + EntityGesture / UIGesture
// - Image 2: MeshAnchor.transform -> Entity(TransformComponent + CollisionComponent(ShapeResource.generateStaticMesh))
// - Image 3: HandAnchor / Camera Ray -> scene.raycast(origin:direction:) -> CollisionCastHit (position + normal)
// - Image 4: WorldAnchor.transform -> Entity(TransformComponent + ModelComponent(USDZ) + CollisionComponent)

@MainActor
public final class RealityComposerContentBundle {
    public static let shared = RealityComposerContentBundle()

    /// Bundle name matching Reality Composer Pro (`RealityKitContent.rkassets`)
    public let bundleName = "RealityKitContent"

    private init() {}

    /// Loads a Universal Scene Description (`.usdz` / `.usda` / `.usdc`) entity from the app bundle or RealityKitContent bundle
    /// and attaches Reality Composer Pro components (`InputTargetComponent`, `CollisionComponent`, `GroundingShadowComponent`).
    public func loadUSDEntity(for artifact: Artifact) -> ModelEntity {
        let modelEntity = Artifact3DEntityBuilder.shared.createEntity(for: artifact)
        modelEntity.name = "USD_\(artifact.slug)"

        // Generate recursive collision shapes for EntityGesture & CollisionCastHit raycasting (Images 1, 3, 4)
        modelEntity.generateCollisionShapes(recursive: true)

        return modelEntity
    }

    /// Exports Universal Scene Description (`.usda` ASCII scene description header) metadata for inspection in the app
    public func generateUSDASceneDescription(for artifact: Artifact, worldTransform: simd_float4x4? = nil) -> String {
        let t = worldTransform?.columns.3 ?? SIMD4<Float>(0, 0, 0, 1)
        return """
        #usda 1.0
        (
            customLayerData = {
                string creator = "Apple Reality Composer Pro & ALQAMI Spatial USD Engine"
                string artifactId = "\(artifact.id)"
            }
            defaultPrim = "Root"
            metersPerUnit = 1
            upAxis = "Y"
        )

        def Xform "Root"
        {
            def Xform "WorldAnchor_\(artifact.slug.replacingOccurrences(of: "-", with: "_"))" (
                prepend apiSchemas = ["MaterialBindingAPI", "PhysicsCollisionAPI"]
            )
            {
                double3 xformOp:translate = (\(String(format: "%.4f", t.x)), \(String(format: "%.4f", t.y)), \(String(format: "%.4f", t.z)))
                float3 xformOp:scale = (\(artifact.model.scale), \(artifact.model.scale), \(artifact.model.scale))
                uniform token[] xformOpOrder = ["xformOp:translate", "xformOp:scale"]

                def Reference "USDZAsset" (
                    prepend references = @./Resources/Models/\(artifact.model.usdzFilename)@</Root>
                )
                {
                }
            }
        }
        """
    }
}
