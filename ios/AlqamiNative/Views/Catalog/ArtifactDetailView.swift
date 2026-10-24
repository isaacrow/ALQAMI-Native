import SwiftUI

public struct ArtifactDetailView: View {
    public let artifact: Artifact
    public var isArabic: Bool = true
    public var onLaunchAR: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .overview
    @State private var isFavorite: Bool = false
    @State private var selectedLight: Artifact3DTurntableSceneView.StudioLightPreset = .museumWarm
    @State private var isPlayingAudio: Bool = false

    public enum DetailTab: String, CaseIterable, Identifiable {
        case overview = "نبذة"
        case specs = "التفاصيل"
        case audio = "الصوتيات"

        public var id: String { rawValue }

        public func label(isArabic: Bool) -> String {
            switch self {
            case .overview: return isArabic ? "نبذة تاريخية" : "Overview"
            case .specs: return isArabic ? "المواصفات" : "Specifications"
            case .audio: return isArabic ? "الصوت والتعليق" : "Narration"
            }
        }
    }

    public var body: some View {
        ZStack {
            // Background Dark Tone
            Color(red: 0.07, green: 0.08, blue: 0.11).ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Vision Glass Navigation Bar
                HStack(spacing: 14) {
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(.ultraThinMaterial))
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(artifact.title.text(isArabic: isArabic))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(artifact.period.text(isArabic: isArabic))
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                    }

                    Spacer()

                    // Favorite Button
                    Button(action: {
                        isFavorite.toggle()
                        SpatialSoundHelper.shared.playSnapHaptic()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isFavorite ? .red : .white)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 18) {
                        // 1. Interactive 3D Turntable Stage
                        ZStack(alignment: .bottomTrailing) {
                            Artifact3DTurntableSceneView(
                                artifact: artifact,
                                autoRotate: false,
                                lightPreset: selectedLight
                            )
                            .frame(height: 290)
                            .background(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.06), Color.black.opacity(0.4)],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 180
                                )
                            )
                            .cornerRadius(22)
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.12), lineWidth: 1))

                            // Studio Light Presets Picker
                            HStack(spacing: 6) {
                                ForEach(Artifact3DTurntableSceneView.StudioLightPreset.allCases) { preset in
                                    Button(action: {
                                        selectedLight = preset
                                        SpatialSoundHelper.shared.playSnapHaptic()
                                    }) {
                                        Text(preset.label(isArabic: isArabic))
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(selectedLight == preset ? .black : .white.opacity(0.8))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(selectedLight == preset ? Color(red: 1.0, green: 0.84, blue: 0.15) : Color.white.opacity(0.14))
                                            )
                                    }
                                }
                            }
                            .padding(10)
                        }
                        .padding(.horizontal, 18)

                        // 2. Vision Pro Glass HUD Panel with 3 Tabs
                        VStack(spacing: 12) {
                            // Tabs Header
                            HStack(spacing: 0) {
                                ForEach(DetailTab.allCases) { tab in
                                    let isSelected = selectedTab == tab
                                    Button(action: {
                                        selectedTab = tab
                                        SpatialSoundHelper.shared.playSnapHaptic()
                                    }) {
                                        VStack(spacing: 6) {
                                            Text(tab.label(isArabic: isArabic))
                                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                                .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                                            Rectangle()
                                                .fill(isSelected ? Color(red: 1.0, green: 0.84, blue: 0.15) : Color.clear)
                                                .frame(height: 2)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)

                            Divider().background(Color.white.opacity(0.1))

                            // Tab Content Body
                            Group {
                                switch selectedTab {
                                case .overview:
                                    overviewTabContent
                                case .specs:
                                    specsTabContent
                                case .audio:
                                    audioTabContent
                                }
                            }
                            .padding(16)
                        }
                        .background(RoundedRectangle(cornerRadius: 22).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.18), lineWidth: 1))
                        .padding(.horizontal, 18)
                        .padding(.bottom, 90) // Margin for floating AR button
                    }
                }
            }

            // 3. Floating Gold Action Button: "عرض في المكان بالواقع المعزز (AR)"
            VStack {
                Spacer()

                Button(action: {
                    SpatialSoundHelper.shared.playPlacementHaptic()
                    dismiss()
                    onLaunchAR()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "cube.transparent.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text(isArabic ? "عرض في المكان بالواقع المعزز (AR)" : "View in Space with AR")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(red: 1.0, green: 0.88, blue: 0.35), Color(red: 0.95, green: 0.75, blue: 0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                    )
                    .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.15).opacity(0.45), radius: 18, x: 0, y: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 22)
                }
            }
        }
    }

    // MARK: - Tab 1: Overview
    private var overviewTabContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(artifact.description.text(isArabic: isArabic))
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(5)

            VStack(alignment: .leading, spacing: 6) {
                Text(isArabic ? "السياق التاريخي:" : "Historical Context:")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))

                Text(artifact.historicalContext.text(isArabic: isArabic))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
        }
    }

    // MARK: - Tab 2: Specs & Provenance
    private var specsTabContent: some View {
        VStack(spacing: 10) {
            specRow(title: isArabic ? "الأبعاد الحقيقية:" : "Dimensions:", value: artifact.dimensions.formatted(isArabic: isArabic))
            specRow(title: isArabic ? "المادة الصانعة:" : "Material:", value: artifact.material.text(isArabic: isArabic))
            specRow(title: isArabic ? "الحالة الأثرية:" : "Condition:", value: artifact.condition.text(isArabic: isArabic))

            if let binding = artifact.binding {
                specRow(title: isArabic ? "التجليد والكسوة:" : "Binding:", value: binding.text(isArabic: isArabic))
            }
            if let decoration = artifact.decoration {
                specRow(title: isArabic ? "الزخرفة والتذهيب:" : "Decoration:", value: decoration.text(isArabic: isArabic))
            }
            if let seals = artifact.seals {
                specRow(title: isArabic ? "الأختام والوقفية:" : "Endowment Seals:", value: seals.text(isArabic: isArabic))
            }

            specRow(title: isArabic ? "الجهة الحافظة:" : "Repository:", value: artifact.institution.text(isArabic: isArabic))
        }
    }

    private func specRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.55))
                .frame(width: 105, alignment: .leading)

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Tab 3: Audio Narration
    private var audioTabContent: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                Button(action: {
                    isPlayingAudio.toggle()
                    SpatialSoundHelper.shared.playSnapHaptic()
                }) {
                    Image(systemName: isPlayingAudio ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(artifact.audio.titleAr)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(artifact.audio.narratorAr) • \(artifact.audio.durationSec) ثانية")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()
            }

            // Animated Audio Waveform Mockup
            HStack(spacing: 3) {
                ForEach(0..<28) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isPlayingAudio ? Color(red: 1.0, green: 0.84, blue: 0.15) : Color.white.opacity(0.3))
                        .frame(width: 4, height: isPlayingAudio ? CGFloat(12 + (i * 7) % 28) : 8)
                }
            }
            .frame(height: 32)
            .animation(.easeInOut(duration: 0.35), value: isPlayingAudio)

            Text(artifact.audio.transcriptAr)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.75))
                .italic()
                .lineSpacing(4)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
        }
    }
}
