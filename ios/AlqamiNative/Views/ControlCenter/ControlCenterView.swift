import SwiftUI

// MARK: - Apple Glossy Glass 3-Panel Control Center with Real Hardware Telemetry (ControlCenter3Panel.tsx)
public struct ControlCenterView: View {
    public var isArabic: Bool
    public var onSelectLanguage: (Bool) -> Void
    public var onOpenARWorld: () -> Void
    public var onOpenScanner: () -> Void
    public var onDismiss: () -> Void

    @ObservedObject private var lighting = LightingManager.shared
    @ObservedObject private var hardware = RealHardwareMonitor.shared
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
            Color.black.opacity(0.58)
                .ignoresSafeArea()
                .onTapGesture {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    onDismiss()
                }

            GeometryReader { geo in
                let isWide = geo.size.width > 740
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Top Glossy Pill Header
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                                Text("APPLE GLOSSY GLASS CONTROL CENTER • مركز التحكم المكاني")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button(action: {
                                SpatialSoundHelper.shared.playSnapHaptic()
                                onDismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .glossyCircle(size: 32)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .glossyPill()

                        if isWide {
                            HStack(alignment: .top, spacing: 14) {
                                leftClockAndWorldPanel
                                    .frame(width: 235)
                                centerSystemPanel
                                    .frame(maxWidth: .infinity)
                                rightLightingPanel
                                    .frame(width: 270)
                            }
                        } else {
                            VStack(spacing: 12) {
                                leftClockAndWorldPanel
                                rightLightingPanel
                                centerSystemPanel
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: 880)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - 1. Left Panel: Real Date, Real Clock, Real UIDevice Battery & NWPathMonitor Network
    private var leftClockAndWorldPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(hardware.currentDateText)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(.white.opacity(0.72))

                HStack(alignment: .firstTextBaseline) {
                    Text(hardware.currentTimeText)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    // Real NWPathMonitor Network + Real UIDevice Battery Level
                    HStack(spacing: 6) {
                        Image(systemName: hardware.isWiFiConnected ? "wifi" : "wifi.slash")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(hardware.isWiFiConnected ? .green : .orange)
                        Text("\(hardware.batteryLevelPercent)%")
                            .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                        Image(systemName: hardware.batteryState == .charging ? "battery.100.bolt" : "battery.100")
                            .font(.system(size: 12))
                            .foregroundColor(hardware.batteryState == .charging ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white)
                    }
                    .foregroundColor(.white.opacity(0.9))
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
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.42),
                                        Color(red: 0.071, green: 0.251, blue: 0.569).opacity(0.55)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        Image(systemName: "arkit")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ALQAMI · علقمي")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundColor(.white)
                        Text(lighting.isSpatialWorldAR ? "Live Camera AR Active" : "Launch RealityKit AR")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .glossyGlass(cornerRadius: 18, tintOpacity: 0.16, rimOpacity: 0.45, shadowRadius: 8)
            }
            .buttonStyle(.plain)

            // Live Hardware & LiDAR Status Pill
            HStack {
                Image(systemName: ARSessionManager.shared.isLiDARAvailable ? "sensor.tag.radiowaves.forward.fill" : "camera.metering.matrix")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                Text(ARSessionManager.shared.isLiDARAvailable ? "LiDAR Mesh Active • \(hardware.networkInterfaceText)" : "ARKit Raycast Ready • \(hardware.networkInterfaceText)")
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glossyGlass(cornerRadius: 16, tintOpacity: 0.12, rimOpacity: 0.35, shadowRadius: 6)
        }
        .padding(16)
        .glossyGlass(cornerRadius: 28)
    }

    // MARK: - 2. Center Panel: 4 Glossy Circular Toggles + System Actions + Real Audio Volume Slider
    private var centerSystemPanel: some View {
        VStack(spacing: 12) {
            // Top 4 Glossy Circular Toggles
            HStack(spacing: 10) {
                circularQuickToggle(
                    titleTop: "عربي",
                    subtitle: "AR",
                    isActive: isArabic
                ) {
                    onSelectLanguage(true)
                }

                circularQuickToggle(
                    titleTop: "EN",
                    subtitle: "English",
                    isActive: !isArabic
                ) {
                    onSelectLanguage(false)
                }

                circularIconToggle(
                    icon: "arkit",
                    label: "World AR",
                    isActive: lighting.isSpatialWorldAR
                ) {
                    lighting.isSpatialWorldAR.toggle()
                    SpatialSoundHelper.shared.playSnapHaptic()
                }

                circularIconToggle(
                    icon: "qrcode.viewfinder",
                    label: "Vision",
                    isActive: false
                ) {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    onDismiss()
                    onOpenScanner()
                }
            }

            // System Action List
            VStack(spacing: 8) {
                systemActionRow(id: "ar-mode", icon: "arkit", title: "RealityKit & Raycast AR • الواقع المعزز") {
                    activeSystemFeature = "ar-mode"
                    onDismiss()
                    onOpenARWorld()
                }
                systemActionRow(id: "scanner", icon: "qrcode.viewfinder", title: "Vision 3D Scanner & RDF • الماسح الدلالي") {
                    activeSystemFeature = "scanner"
                    onDismiss()
                    onOpenScanner()
                }
                systemActionRow(id: "cam-bg", icon: "video.fill", title: "Live Camera Backdrop • خلفية الكاميرا الحية") {
                    activeSystemFeature = "cam-bg"
                    lighting.isSpatialWorldAR.toggle()
                }
                systemActionRow(id: "env", icon: "mountain.2.fill", title: "Switch Spatial Environment • تبديل البيئة") {
                    activeSystemFeature = "env"
                    lighting.cycleEnvironment()
                }
            }

            // Real Output Volume Bar
            HStack(spacing: 10) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Slider(value: Binding(
                    get: { Double(hardware.systemVolume) },
                    set: { hardware.systemVolume = Float($0) }
                ), in: 0...1)
                    .tint(Color(red: 1.0, green: 0.839, blue: 0.039))
                Text("\(Int(hardware.systemVolume * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glossyPill()
        }
        .padding(16)
        .glossyGlass(cornerRadius: 28)
    }

    // MARK: - 3. Right Panel: Real-Time SceneKit / RealityKit 3D Lighting Controller
    private var rightLightingPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    Text("إضاءة النماذج 3D الحقيقية")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text(lighting.currentPreset.nameEn)
                    .font(.system(size: 10.5, weight: .bold))
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
                                .frame(width: 22, height: 22)
                                .shadow(color: Color(UIColor(hex: preset.uiAccentHex) ?? .yellow).opacity(0.6), radius: 5)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(preset.nameAr)
                                    .font(.system(size: 12.5, weight: .bold))
                                    .foregroundColor(.white)
                                Text(preset.nameEn)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.60))
                            }
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glossyGlass(
                            cornerRadius: 16,
                            tintOpacity: isSelected ? 0.24 : 0.08,
                            rimOpacity: isSelected ? 0.65 : 0.22,
                            shadowRadius: 6
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
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    Text("البيئة: \(lighting.environment.labelAr)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .glossyPill()
            }
            .buttonStyle(.plain)

            // Bottom Brightness Slider (20% - 200%)
            HStack(spacing: 10) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                Slider(value: $lighting.brightness, in: 0.2...2.0)
                    .tint(Color(red: 1.0, green: 0.839, blue: 0.039))
                Text("\(Int(lighting.brightness * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glossyPill()
        }
        .padding(16)
        .glossyGlass(cornerRadius: 28)
    }

    private func circularQuickToggle(
        titleTop: String,
        subtitle: String,
        isActive: Bool,
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
                    .font(.system(size: 9, weight: .semibold))
                    .opacity(0.8)
            }
            .foregroundColor(isActive ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .glossyPill(isHighlighted: isActive)
        }
        .buttonStyle(.plain)
    }

    private func circularIconToggle(
        icon: String,
        label: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                Text(label)
                    .font(.system(size: 8.5, weight: .semibold))
            }
            .foregroundColor(isActive ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .glossyPill(isHighlighted: isActive)
        }
        .buttonStyle(.plain)
    }

    private func systemActionRow(
        id: String,
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        let isActive = activeSystemFeature == id
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isActive ? .black : Color(red: 1.0, green: 0.839, blue: 0.039))
                    .glossyCircle(size: 30, isHighlighted: isActive)

                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.45))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .glossyGlass(cornerRadius: 16, tintOpacity: isActive ? 0.22 : 0.08, rimOpacity: 0.32, shadowRadius: 6)
        }
        .buttonStyle(.plain)
    }
}
