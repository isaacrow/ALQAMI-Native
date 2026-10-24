import SwiftUI

// MARK: - Exact 1:1 3-Panel Control Center (ControlCenter3Panel.tsx)
public struct ControlCenterView: View {
    public var isArabic: Bool
    public var onSelectLanguage: (Bool) -> Void
    public var onOpenARWorld: () -> Void
    public var onOpenScanner: () -> Void
    public var onDismiss: () -> Void

    @ObservedObject private var lighting = LightingManager.shared
    @State private var wifiOn: Bool = true
    @State private var bluetoothOn: Bool = true
    @State private var volume: Double = 0.78
    @State private var activeSystemFeature: String = "ar-mode"

    public init(
        isArabic: Bool = true,
        onSelectLanguage: @escaping (Bool) -> Void = { _ in },
        onOpenARWorld: @escaping () -> Void = {},
        onOpenScanner: @escaping () -> Void = {},
        onDismiss: @escaping () -> Void
    ) {
        self.isArabic = isArabic
        self.onSelectLanguage = onSelectLanguage
        self.onOpenARWorld = onOpenARWorld
        self.onOpenScanner = onOpenScanner
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // Backdrop Dismiss Layer
            Color.black.opacity(0.62)
                .ignoresSafeArea()
                .onTapGesture {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    onDismiss()
                }

            GeometryReader { geo in
                let isWide = geo.size.width > 740
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Top Pill Handle
                        HStack {
                            Text("SPATIAL CONTROL CENTER • مركز التحكم المكاني")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.75))
                            Spacer()
                            Button(action: {
                                SpatialSoundHelper.shared.playSnapHaptic()
                                onDismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Circle().fill(Color.white.opacity(0.14)))
                            }
                        }
                        .padding(.horizontal, 8)

                        if isWide {
                            HStack(alignment: .top, spacing: 14) {
                                leftClockAndWorldPanel
                                    .frame(width: 225)
                                centerSystemPanel
                                    .frame(maxWidth: .infinity)
                                rightLightingPanel
                                    .frame(width: 265)
                            }
                        } else {
                            VStack(spacing: 14) {
                                centerSystemPanel
                                rightLightingPanel
                                leftClockAndWorldPanel
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 880)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - 1. Left Panel: Date, Clock, Battery/Wi-Fi, ALQAMI iPhone AR World Card, Notifications
    private var leftClockAndWorldPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tue Oct 24")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                HStack {
                    Text(currentTimeString())
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "wifi")
                            .font(.system(size: 11))
                        Text("97%")
                            .font(.system(size: 11, weight: .bold))
                        Image(systemName: "battery.100")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }

            // ALQAMI · علقمي iPhone AR World Card
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                lighting.isSpatialWorldAR.toggle()
                onOpenARWorld()
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.32),
                                        Color(red: 0.071, green: 0.251, blue: 0.569).opacity(0.45)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        Text("🌐")
                            .font(.system(size: 18))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ALQAMI · علقمي")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text(lighting.isSpatialWorldAR ? "Spatial AR Active" : "iPhone AR World")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                    Spacer()
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.10)))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.16), lineWidth: 1))
            }
            .buttonStyle(.plain)

            // 3 Notifications Pill
            HStack {
                Text("3 Notifications")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Circle()
                    .fill(Color.white.opacity(0.28))
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.10)))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.14), lineWidth: 1))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.12, green: 0.13, blue: 0.16).opacity(0.86))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        )
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.18), lineWidth: 1))
    }

    // MARK: - 2. Center Panel: 4 Circular Toggles (عربي, EN, Wi-Fi, Bluetooth) + System List + Volume Bar
    private var centerSystemPanel: some View {
        VStack(spacing: 12) {
            // Top 4 Circular Toggles
            HStack(spacing: 10) {
                circularQuickToggle(
                    titleTop: "عربي",
                    subtitle: "AR",
                    isActive: isArabic,
                    activeColor: Color(red: 1.0, green: 0.839, blue: 0.039),
                    textBlackWhenActive: true
                ) {
                    onSelectLanguage(true)
                }

                circularQuickToggle(
                    titleTop: "EN",
                    subtitle: "English",
                    isActive: !isArabic,
                    activeColor: Color.blue,
                    textBlackWhenActive: false
                ) {
                    onSelectLanguage(false)
                }

                circularIconToggle(
                    icon: "wifi",
                    isActive: wifiOn,
                    activeColor: Color.blue
                ) {
                    wifiOn.toggle()
                    SpatialSoundHelper.shared.playSnapHaptic()
                }

                circularIconToggle(
                    icon: "bolt.horizontal.fill",
                    isActive: bluetoothOn,
                    activeColor: Color.blue
                ) {
                    bluetoothOn.toggle()
                    SpatialSoundHelper.shared.playSnapHaptic()
                }
            }

            // System Action List
            VStack(spacing: 6) {
                systemActionRow(id: "ar-mode", emoji: "✨", icon: nil, title: "Alqami AR Mode • الواقع المعزز") {
                    activeSystemFeature = "ar-mode"
                    onDismiss()
                    onOpenARWorld()
                }
                systemActionRow(id: "scanner", emoji: "📦", icon: nil, title: "3D Object Tracking • تتبع المجسمات") {
                    activeSystemFeature = "scanner"
                    onDismiss()
                    onOpenScanner()
                }
                systemActionRow(id: "mac", emoji: nil, icon: "desktopcomputer", title: "Mac Virtual Display") {
                    activeSystemFeature = "mac"
                }
                systemActionRow(id: "mirror", emoji: nil, icon: "airplayvideo", title: "Mirror / Phone Cam AR") {
                    activeSystemFeature = "mirror"
                    lighting.isSpatialWorldAR.toggle()
                }
                systemActionRow(id: "guest", emoji: nil, icon: "person.2.fill", title: "Guest User • وضع الزائر") {
                    activeSystemFeature = "guest"
                }
                systemActionRow(id: "focus", emoji: nil, icon: "moon.fill", title: "Focus • وضع التركيز") {
                    activeSystemFeature = "focus"
                }
            }

            // Thick White Volume Bar
            HStack(spacing: 10) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.75))
                Slider(value: $volume, in: 0...1)
                    .tint(.black)
                Text("\(Int(volume * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.black.opacity(0.75))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.white.opacity(0.92)))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.12, green: 0.13, blue: 0.16).opacity(0.86))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        )
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.18), lineWidth: 1))
    }

    // MARK: - 3. Right Panel: Master 3D Lighting Controller (5 Presets + Environment Switcher + Brightness Bar)
    private var rightLightingPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    Text("إضاءة النماذج 3D")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Text(lighting.currentPreset.nameEn)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
            }

            // 5 Lighting Presets List
            VStack(spacing: 6) {
                ForEach(LightingPreset.allPresets) { preset in
                    let isSelected = lighting.presetId == preset.id
                    Button(action: {
                        lighting.setPreset(preset.id)
                    }) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(UIColor(hex: preset.uiAccentHex) ?? .yellow))
                                .frame(width: 24, height: 24)
                                .shadow(color: Color(UIColor(hex: preset.uiAccentHex) ?? .yellow).opacity(0.5), radius: 5)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(preset.nameAr)
                                    .font(.system(size: 12.5, weight: .bold))
                                    .foregroundColor(.white)
                                Text(preset.nameEn)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.55))
                            }
                            Spacer()
                            if isSelected {
                                Circle()
                                    .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? Color.white.opacity(0.20) : Color.white.opacity(0.07))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.white.opacity(0.32) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Environment Backdrop Switcher Button
            Button(action: {
                lighting.cycleEnvironment()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Text("البيئة: \(lighting.environment.labelAr) (\(lighting.environment.labelEn))")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundColor(.white.opacity(0.88))
                    Spacer()
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
            }
            .buttonStyle(.plain)

            // Bottom Brightness Slider (20% - 200%)
            HStack(spacing: 10) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.8))
                Slider(value: $lighting.brightness, in: 0.2...2.0)
                    .tint(.black)
                Text("\(Int(lighting.brightness * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.89, blue: 0.62), Color.white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.12, green: 0.13, blue: 0.16).opacity(0.86))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        )
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.18), lineWidth: 1))
    }

    private func circularQuickToggle(
        titleTop: String,
        subtitle: String,
        isActive: Bool,
        activeColor: Color,
        textBlackWhenActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            action()
        }) {
            VStack(spacing: 1) {
                Text(titleTop)
                    .font(.system(size: 12, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 8.5, weight: .semibold))
                    .opacity(0.8)
            }
            .foregroundColor(isActive ? (textBlackWhenActive ? .black : .white) : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Circle()
                    .fill(isActive ? activeColor : Color.white.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }

    private func circularIconToggle(
        icon: String,
        isActive: Bool,
        activeColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Circle()
                        .fill(isActive ? activeColor : Color.white.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
    }

    private func systemActionRow(
        id: String,
        emoji: String?,
        icon: String?,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        let isActive = activeSystemFeature == id
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            action()
        }) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 28, height: 28)
                    if let emoji = emoji {
                        Text(emoji).font(.system(size: 13))
                    } else if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                Text(title)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isActive ? Color.white.opacity(0.20) : Color.white.opacity(0.07))
            )
        }
        .buttonStyle(.plain)
    }

    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: Date())
    }
}
