import SwiftUI

// MARK: - Exact ALQAMI 6 Artifact Card View (Apple Glossy Glass Outer + #CBC9C5 Warm Stone-Gray Inner Studio)
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
        VStack(alignment: .leading, spacing: 8) {
            // 1. Warm Stone-Gray (#CBC9C5) Inner Studio Container with Glossy Inner Bevel
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.796, green: 0.788, blue: 0.773)) // #CBC9C5

                // Subtle studio vignette + top glossy highlight
                RadialGradient(
                    colors: [Color.white.opacity(0.18), Color.black.opacity(0.08)],
                    center: .center,
                    startRadius: 20,
                    endRadius: 95
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                // Real High-Res Cutout Image OR Live 3D Model when live3D is enabled
                if live3D {
                    Artifact3DTurntableSceneView(
                        artifact: artifact,
                        autoRotate: true,
                        allowsCameraControl: true,
                        cameraDistance: 0.76
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else if let uiImage = BundleImageLoader.uiImage(named: artifact.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .padding(.bottom, 16)
                        .shadow(color: Color.black.opacity(0.26), radius: 8, x: 0, y: 5)
                } else {
                    Artifact3DTurntableSceneView(
                        artifact: artifact,
                        autoRotate: true,
                        allowsCameraControl: false,
                        cameraDistance: 0.76
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                // Bottom Overlay Bar inside #CBC9C5 Box: Glossy Heart + 3D Cube on Left, Glossy itemCode Pill on Right
                VStack {
                    Spacer()
                    HStack(spacing: 5) {
                        // Heart Favorite Button
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            onToggleFavorite()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundColor(isFavorite ? .black : .white)
                                .glossyCircle(size: 28, isSelected: isFavorite)
                        }
                        .buttonStyle(.plain)

                        // 3D Volume / AR Quick Inspect Button
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            onPopOut3D()
                        }) {
                            Image(systemName: "cube")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundColor(.white)
                                .glossyCircle(size: 28, isSelected: false)
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 2)

                        // ItemCode Glossy Glass Pill (e.g. "1022 هـ", "HLM-OTT-15")
                        Text(artifact.itemCode)
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .glossyPill()
                    }
                    .padding(8)
                    .environment(\.layoutDirection, .leftToRight)
                }
            }
            .frame(height: 148)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 0.8)
            )

            // 2. Proportional Bilingual Titles Below the Stone-Gray Viewport
            VStack(alignment: .leading, spacing: 2) {
                Text(artifact.title.text(isArabic: isArabic))
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(artifact.subtitle.text(isArabic: isArabic))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.62))
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
        }
        .padding(9)
        .glossyGlass(cornerRadius: 22, tintOpacity: 0.14)
        .contentShape(Rectangle())
        .onTapGesture {
            SpatialSoundHelper.shared.playSnapHaptic()
            onSelect()
        }
    }
}
