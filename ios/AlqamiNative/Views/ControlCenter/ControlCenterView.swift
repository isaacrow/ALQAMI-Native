import SwiftUI

// MARK: - visionOS 3-Column Control Center View
public struct ControlCenterView: View {
    var onDismiss: () -> Void

    @AppStorage("spatialAudioEnabled") private var spatialAudioEnabled = true
    @AppStorage("lidarOcclusionEnabled") private var lidarOcclusionEnabled = true
    @AppStorage("surfaceSnappingEnabled") private var surfaceSnappingEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    @State private var immersionLevel: Double = 0.85
    @State private var lightingIntensity: Double = 1.0
    @State private var ambientVolume: Double = 0.65
    @State private var selectedAtmosphere: String = "متحف التراث الإسلامي"

    private let atmospheres = [
        ("متحف التراث الإسلامي", "building.columns.fill", "Islamic Heritage Museum"),
        ("قاعة بابل الأثرية", "cube.fill", "Babylonian Hall"),
        ("واحة المساء الصحراوية", "sun.dust.fill", "Desert Oasis"),
        ("استوديو الفحص النقي", "sparkles", "Studio Vitrine")
    ]

    public var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()

            VStack(spacing: 20) {
                // Top Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("مركز التحكم المكاني")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("visionOS Control Center • Heritage Spatial Tuning")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                    }

                    Spacer()

                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 22)

                ScrollView {
                    VStack(spacing: 18) {
                        // SECTION 1: System Toggles Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("الخصائص التقنية والعتاد")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ToggleTile(icon: "speaker.wave.3.fill", title: "الصوت المكاني", isOn: $spatialAudioEnabled)
                                ToggleTile(icon: "camera.metering.matrix", title: "عزل الـ LiDAR", isOn: $lidarOcclusionEnabled)
                                ToggleTile(icon: "dot.scope", title: "محاذاة الأسطح", isOn: $surfaceSnappingEnabled)
                                ToggleTile(icon: "iphone.radiowaves.left.and.right", title: "الاهتزاز الهابتك", isOn: $hapticsEnabled)
                            }
                        }

                        // SECTION 2: Continuous Sliders
                        VStack(alignment: .leading, spacing: 14) {
                            Text("مستويات الانغماس والإضاءة")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))

                            VStack(spacing: 14) {
                                SliderRow(icon: "eye.fill", title: "مستوى الانغماس المكاني", value: $immersionLevel, range: 0.0...1.0)
                                SliderRow(icon: "sun.max.fill", title: "شدة الإضاءة التراثية", value: $lightingIntensity, range: 0.2...2.0)
                                SliderRow(icon: "waveform", title: "صوت البيئة المحيطة", value: $ambientVolume, range: 0.0...1.0)
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        }

                        // SECTION 3: Atmosphere Presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("بيئة الإضاءة والمتحف الافتراضي")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))

                            VStack(spacing: 8) {
                                ForEach(atmospheres, id: \.0) { atmos in
                                    let isSelected = selectedAtmosphere == atmos.0
                                    Button(action: {
                                        SpatialSoundHelper.shared.playSnapHaptic()
                                        selectedAtmosphere = atmos.0
                                    }) {
                                        HStack {
                                            Image(systemName: atmos.1)
                                                .foregroundColor(isSelected ? Color(red: 1.0, green: 0.84, blue: 0.15) : .white)
                                                .frame(width: 28)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(atmos.0)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                                Text(atmos.2)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.white.opacity(0.6))
                                            }

                                            Spacer()

                                            if isSelected {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(RoundedRectangle(cornerRadius: 14).fill(isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.04)))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// MARK: - Toggle Tile Component
struct ToggleTile: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Button(action: {
            isOn.toggle()
            SpatialSoundHelper.shared.playSnapHaptic()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isOn ? Color(red: 1.0, green: 0.84, blue: 0.15) : .white.opacity(0.5))

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isOn ? .white : .white.opacity(0.6))

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14).fill(isOn ? Color.white.opacity(0.14) : Color.white.opacity(0.05)))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isOn ? Color(red: 1.0, green: 0.84, blue: 0.15).opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Slider Row Component
struct SliderRow: View {
    let icon: String
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
            }

            Slider(value: $value, in: range)
                .tint(Color(red: 1.0, green: 0.84, blue: 0.15))
        }
    }
}
