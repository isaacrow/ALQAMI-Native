import SwiftUI

// MARK: - Exact ALQAMI 6 Artifact Card View (Frosted Glass Outer + #CBC9C5 Warm Stone-Gray Inner Viewport)
public struct ArtifactCardView: View {
    public let artifact: Artifact
    public var isArabic: Bool = true
    public var live3D: Bool = false
    public var isFavorite: Bool = false
    public var onToggleFavorite: () -> Void = {}
    public var onPopOut3D: () -> Void = {}
    public var onSelect: () -> Void
    public var onLaunchAR: () -> Void

    public init(
        artifact: Artifact,
        isArabic: Bool = true,
        live3D: Bool = false,
        isFavorite: Bool = false,
        onToggleFavorite: @escaping () -> Void = {},
        onPopOut3D: @escaping () -> Void = {},
        onSelect: @escaping () -> Void,
        onLaunchAR: @escaping () -> Void
    ) {
        self.artifact = artifact
        self.isArabic = isArabic
        self.live3D = live3D
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
        self.onPopOut3D = onPopOut3D
        self.onSelect = onSelect
        self.onLaunchAR = onLaunchAR
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 1. Warm Stone-Gray (#CBC9C5) Inner Studio Container (Exact ALQAMI 6 Card Viewport)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.796, green: 0.788, blue: 0.773)) // #CBC9C5

                // Subtle radial vignette matching the web card
                RadialGradient(
                    colors: [Color.clear, Color.black.opacity(0.08)],
                    center: .center,
                    startRadius: 30,
                    endRadius: 110
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Real High-Res Cutout Image OR Live 3D Model when live3D is enabled
                if live3D {
                    Artifact3DTurntableSceneView(
                        artifact: artifact,
                        autoRotate: true,
                        allowsCameraControl: true,
                        cameraDistance: 0.78
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } else if let uiImage = BundleImageLoader.uiImage(named: artifact.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(14)
                        .shadow(color: Color.black.opacity(0.28), radius: 10, x: 0, y: 6)
                } else {
                    Artifact3DTurntableSceneView(
                        artifact: artifact,
                        autoRotate: true,
                        allowsCameraControl: false,
                        cameraDistance: 0.78
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                // Bottom Overlay Bar inside #CBC9C5 Box: Heart + 3D Box on Left, itemCode Pill on Right
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        // Heart Favorite Button
                        Button(action: {
                            onToggleFavorite()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isFavorite ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white)
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle()
                                        .fill(isFavorite ? Color.black.opacity(0.65) : Color.black.opacity(0.32))
                                )
                        }
                        .buttonStyle(.plain)

                        // 3D Volume / AR Quick Inspect Button
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            onPopOut3D()
                        }) {
                            Image(systemName: "cube")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(Color.black.opacity(0.32)))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        // ItemCode Glass Pill (e.g. "1022 هـ / هـ", "HLM-OTT-15")
                        Text(artifact.itemCode)
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.black.opacity(0.28)))
                    }
                    .padding(10)
                }
            }
            .frame(height: 175)

            // 2. Bilingual Titles Below the Stone-Gray Viewport
            VStack(alignment: .leading, spacing: 3) {
                Text(artifact.title.text(isArabic: isArabic))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(artifact.subtitle.text(isArabic: isArabic))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.08))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            SpatialSoundHelper.shared.playSnapHaptic()
            onSelect()
        }
    }
}
