import SwiftUI

public struct ArtifactCardView: View {
    let artifact: Artifact
    var isArabic: Bool = true
    var onSelect: () -> Void
    var onLaunchAR: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Artifact Preview Container
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.14, blue: 0.18))
                    .frame(height: 160)

                // Render image if available in bundle or fallback symbol
                VStack {
                    Spacer()
                    Image(systemName: iconForCategory(artifact.category))
                        .font(.system(size: 46))
                        .foregroundColor(Color(red: 0.88, green: 0.74, blue: 0.48).opacity(0.8))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 160)

                // 3D / AR Badge
                HStack(spacing: 4) {
                    Image(systemName: "arkit")
                        .font(.system(size: 11, weight: .bold))
                    Text("3D")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(8)
            }

            // Info Section
            VStack(alignment: .leading, spacing: 4) {
                Text(artifact.title.localized(isArabic: isArabic))
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(artifact.period.localized(isArabic: isArabic))
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.65))
                    .lineLimit(1)

                Text(artifact.creator.localized(isArabic: isArabic))
                    .font(.caption2)
                    .foregroundColor(Color(red: 0.88, green: 0.74, blue: 0.48))
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)

            // Direct AR Action Button
            Button(action: {
                SpatialSoundHelper.shared.playPlacementHaptic()
                onLaunchAR()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 13, weight: .semibold))
                    Text(isArabic ? "عرض بالواقع المعزز" : "View in AR")
                        .font(.caption.bold())
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.84, blue: 0.52), Color(red: 0.82, green: 0.65, blue: 0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.top, 4)
        }
        .padding(12)
        .visionGlass(cornerRadius: 20)
        .onTapGesture {
            SpatialSoundHelper.shared.playSnapHaptic()
            onSelect()
        }
    }

    private func iconForCategory(_ cat: String) -> String {
        switch cat {
        case "manuscripts": return "book.closed"
        case "islamic-art": return "shield"
        case "history": return "scroll"
        case "museum": return "building.columns"
        default: return "cube.transparent"
        }
    }
}
