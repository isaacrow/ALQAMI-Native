import SwiftUI
import RealityKit
import ARKit

// MARK: - Exact ALQAMI 6 AR Overlay (screenshot-ar-view.png + immersive-ar.html + RealARXREngine.tsx)
public struct ARControlOverlay: View {
    @ObservedObject var viewModel: ARViewModel
    var onDismiss: () -> Void

    @State private var isArabic: Bool = true
    @State private var isHUDCollapsed: Bool = false
    @State private var activeHUDTab: HUDTab = .metadata
    @State private var showCaliperDimensions: Bool = false

    public enum HUDTab: String {
        case metadata = "metadata"
        case description = "description"
    }

    public init(viewModel: ARViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // MARK: - 1. Exact Top Dark Glass Header Bar (screenshot-ar-view.png)
            VStack {
                HStack(spacing: 12) {
                    // Left Side: Language Toggle Pill ("English" / "عربي")
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation { isArabic.toggle() }
                    }) {
                        Text(isArabic ? "English" : "عربي")
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white.opacity(0.10)))
                            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                    }

                    Spacer()

                    // Right Side: Artifact Title + "متحف علقمي المكاني · Alqami Heritage" + Logo + Back (<) Button
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(viewModel.artifact.title.text(isArabic: isArabic))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(isArabic ? "متحف علقمي المكاني · Alqami Heritage" : "Alqami Spatial Museum · الواقع المعزز")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.65))
                                .lineLimit(1)
                        }

                        // Alqami Logo Icon
                        if let logoImg = BundleImageLoader.uiImage(named: "logo.png") {
                            Image(uiImage: logoImg)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }

                        // Circular Back (<) Button
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            onDismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.10)))
                                .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.05, green: 0.06, blue: 0.09).opacity(0.82))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 8)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .environment(\.layoutDirection, .leftToRight)

                // Raycast Surface & Scale Status Pill
                HStack(spacing: 8) {
                    Circle()
                        .fill(viewModel.isPlaced ? Color.green : (viewModel.isSurfaceDetected ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.orange))
                        .frame(width: 8, height: 8)

                    Text(viewModel.statusMessage)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if viewModel.isPlaced {
                        Text("• \(Int(viewModel.scaleMultiplier * 100))%")
                            .font(.system(size: 11.5, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.black.opacity(0.55)))
                .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
                .padding(.top, 6)

                Spacer()
            }

            // MARK: - 2. Exact Collapsible Floating Dark Glass HUD Card on Right (screenshot-ar-view.png)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    collapsibleRightHUDCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 86)
                .environment(\.layoutDirection, .leftToRight)
            }

            // MARK: - 3. Bottom Spatial AR Controls Pill (Re-Anchor, 1:1 Scale, Caliper Rulers, Snapshot)
            VStack {
                Spacer()
                HStack(spacing: 14) {
                    // Re-anchor on Raycast Plane
                    Button(action: {
                        viewModel.resetPlacement()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "scope")
                            Text(isArabic ? "إعادة التثبيت" : "Re-Anchor")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                    }

                    // 1:1 True Scale Button
                    Button(action: {
                        viewModel.setScale(1.0)
                        SpatialSoundHelper.shared.playScaleTickHaptic()
                    }) {
                        Text("1:1")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                    }

                    // Toggle 3D Dimensions Badge
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation { showCaliperDimensions.toggle() }
                    }) {
                        Image(systemName: "ruler")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(showCaliperDimensions ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }

                    // Show/Hide Metadata Card Toggle
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isHUDCollapsed.toggle()
                        }
                    }) {
                        Image(systemName: isHUDCollapsed ? "sidebar.right" : "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(red: 0.05, green: 0.06, blue: 0.09).opacity(0.84))
                        .background(.ultraThinMaterial, in: Capsule())
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                .padding(.bottom, 18)
            }
        }
    }

    // MARK: - Collapsible Floating Dark Glass HUD Card (Exact screenshot-ar-view.png)
    private var collapsibleRightHUDCard: some View {
        let item = viewModel.artifact
        return VStack(spacing: 0) {
            // Top Collapse Handle Bar
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isHUDCollapsed.toggle()
                }
            }) {
                VStack(spacing: 4) {
                    Capsule()
                        .fill(Color.white.opacity(0.32))
                        .frame(width: 36, height: 4)
                    Image(systemName: isHUDCollapsed ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 6)
            }

            if !isHUDCollapsed {
                // Two Tabs Header: "بيانات القطعة" | "الوصف التاريخي" with Yellow Active Underline
                HStack(spacing: 0) {
                    hudTabButton(
                        tab: .description,
                        title: isArabic ? "الوصف التاريخي" : "Historical Context"
                    )
                    hudTabButton(
                        tab: .metadata,
                        title: isArabic ? "بيانات القطعة" : "Artifact Metadata"
                    )
                }
                .padding(.horizontal, 14)

                Divider().background(Color.white.opacity(0.12))

                // Tab Body
                if activeHUDTab == .metadata {
                    VStack(spacing: 8) {
                        // 2x2 Grid (Creator + Period, Dimensions + Institution)
                        HStack(spacing: 8) {
                            metadataBox(
                                label: isArabic ? "الحقبة / التاريخ" : "Period / Date",
                                value: item.period.text(isArabic: isArabic)
                            )
                            metadataBox(
                                label: isArabic ? "المنشئ / الشارح" : "Creator / Author",
                                value: item.creator.text(isArabic: isArabic)
                            )
                        }

                        HStack(spacing: 8) {
                            metadataBox(
                                label: isArabic ? "جهة الحفظ" : "Repository",
                                value: item.institution.text(isArabic: isArabic)
                            )
                            metadataBox(
                                label: isArabic ? "القياسات / الأبعاد" : "Measurements",
                                value: item.dimensions.formatted(isArabic: isArabic)
                            )
                        }

                        // Full-Width Box: Material & Script ("المادة والخط")
                        metadataBox(
                            label: isArabic ? "المادة والخط" : "Material & Script",
                            value: item.material.text(isArabic: isArabic)
                        )
                    }
                    .padding(14)
                    .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.description.text(isArabic: isArabic))
                            .font(.system(size: 12.5))
                            .foregroundColor(.white.opacity(0.88))
                            .lineSpacing(4)

                        Text(item.historicalContext.text(isArabic: isArabic))
                            .font(.system(size: 11.5))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.9))
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
                }
            }
        }
        .frame(width: min(UIScreen.main.bounds.width - 32, 375))
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.05, green: 0.06, blue: 0.09).opacity(0.84))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.5), radius: 22, x: 0, y: 12)
    }

    private func hudTabButton(tab: HUDTab, title: String) -> some View {
        let isSelected = activeHUDTab == tab
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            withAnimation(.easeInOut(duration: 0.2)) {
                activeHUDTab = tab
            }
        }) {
            VStack(spacing: 7) {
                Text(title)
                    .font(.system(size: 12.5, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white.opacity(0.6))
                Rectangle()
                    .fill(isSelected ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.clear)
                    .frame(height: 2.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
    }

    private func metadataBox(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
            Text(value)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}
