import SwiftUI

public struct ArtifactDetailView: View {
    let artifact: Artifact
    var isArabic: Bool = true
    var onLaunchAR: () -> Void
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Image & 3D Tag
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.15, green: 0.18, blue: 0.24), Color(red: 0.08, green: 0.09, blue: 0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 280)

                    VStack {
                        Spacer()
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 72))
                            .foregroundColor(Color(red: 0.88, green: 0.74, blue: 0.48))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 280)

                    // Close Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(16)
                }

                // Title & Metadata
                VStack(alignment: .leading, spacing: 6) {
                    Text(artifact.title.localized(isArabic: isArabic))
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(artifact.subtitle.localized(isArabic: isArabic))
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.88, green: 0.74, blue: 0.48))

                    Text(artifact.period.localized(isArabic: isArabic))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                // Prominent AR Launcher Button
                Button(action: {
                    dismiss()
                    onLaunchAR()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arkit")
                            .font(.system(size: 20, weight: .bold))
                        Text(isArabic ? "عرض في الواقع المعزز (AR Space)" : "View in AR Space")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.85, blue: 0.55), Color(red: 0.82, green: 0.65, blue: 0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color(red: 0.82, green: 0.65, blue: 0.35).opacity(0.4), radius: 12, y: 6)
                }

                // Specifications Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text(isArabic ? "المواصفات التوثيقية" : "Documentation & Provenance")
                        .font(.headline)
                        .foregroundColor(.white)

                    VStack(spacing: 8) {
                        specRow(title: isArabic ? "الأبعاد" : "Dimensions", value: artifact.details.dimensions)
                        specRow(title: isArabic ? "المادة" : "Material", value: artifact.details.material.localized(isArabic: isArabic))
                        specRow(title: isArabic ? "حالة الحفظ" : "Condition", value: artifact.details.condition.localized(isArabic: isArabic))
                        specRow(title: isArabic ? "المؤسسة الحافظة" : "Institution", value: artifact.institution.localized(isArabic: isArabic))
                        specRow(title: isArabic ? "رمز القطعة" : "Catalog Code", value: artifact.itemCode)
                    }
                    .padding(14)
                    .visionGlass(cornerRadius: 18)
                }

                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text(isArabic ? "الوصف التاريخي" : "Historical Narrative")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(artifact.description.localized(isArabic: isArabic))
                        .font(.body)
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(6)
                        .padding(14)
                        .visionGlass(cornerRadius: 18)
                }
            }
            .padding(20)
        }
        .background(Color(red: 0.05, green: 0.06, blue: 0.08).ignoresSafeArea())
    }

    private func specRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}
