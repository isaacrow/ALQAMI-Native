import SwiftUI

public struct ArtifactCardView: View {
    public let artifact: Artifact
    public var isArabic: Bool = true
    public var onSelect: () -> Void
    public var onLaunchAR: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 3D Mini Interactive Preview
            ZStack(alignment: .topTrailing) {
                Artifact3DTurntableSceneView(artifact: artifact, autoRotate: true)
                    .frame(height: 140)
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(16)

                // Quick AR Trigger Icon Button
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    onLaunchAR()
                }) {
                    Image(systemName: "cube.transparent")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Circle().fill(Color(red: 1.0, green: 0.84, blue: 0.15)))
                        .shadow(color: Color.black.opacity(0.3), radius: 6)
                }
                .padding(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                // Category & Era Badge
                Text(artifact.period.text(isArabic: isArabic))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                    .lineLimit(1)

                // Title
                Text(artifact.title.text(isArabic: isArabic))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Material summary
                Text(artifact.material.text(isArabic: isArabic))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)

                // Rating & Price row
                HStack {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                        Text(String(format: "%.1f", artifact.rating))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("$\(artifact.priceEstimateUSD)")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.18), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
        .contentShape(Rectangle())
        .onTapGesture {
            SpatialSoundHelper.shared.playSnapHaptic()
            onSelect()
        }
    }
}
