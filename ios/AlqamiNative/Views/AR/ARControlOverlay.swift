import SwiftUI
import RealityKit
import ARKit

// MARK: - Exact ALQAMI 6 2D SwiftUI AR Overlay + Spatial Computing ECS Graph Inspector with Apple Glossy Glass
public struct ARControlOverlay: View {
    @ObservedObject var viewModel: ARViewModel
    @ObservedObject private var hardware = RealHardwareMonitor.shared
    var onDismiss: () -> Void

    @State private var isArabic: Bool = true
    @State private var isHUDCollapsed: Bool = false
    @State private var activeHUDTab: HUDTab = .metadata
    @State private var showUSDASheet: Bool = false

    public enum HUDTab: String {
        case metadata = "metadata"
        case description = "description"
        case spatialGraph = "spatialGraph"
    }

    public init(viewModel: ARViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // MARK: - 1. Top Apple Glossy Glass Header Bar + Raycast Status Pill
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    // Left Side: Language Toggle Pill ("English" / "عربي") + Real Voice Guide Toggle
                    HStack(spacing: 6) {
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            withAnimation { isArabic.toggle() }
                        }) {
                            Text(isArabic ? "EN" : "عربي")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .glossyPill()
                        }
                        .buttonStyle(.plain)

                        // Real AVSpeechSynthesizer Voice Narration in AR
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            let text = "\(viewModel.artifact.title.text(isArabic: isArabic)). \(viewModel.artifact.description.text(isArabic: isArabic))"
                            hardware.speakNarration(text, isArabic: isArabic)
                        }) {
                            Image(systemName: hardware.isSpeaking ? "waveform" : "speaker.wave.2.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(hardware.isSpeaking ? .black : .white)
                                .glossyCircle(size: 32, isSelected: hardware.isSpeaking)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 4)

                    // Right Side: Artifact Title + Subtitle + Logo + Glossy Back (<) Button
                    HStack(spacing: 10) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(viewModel.artifact.title.text(isArabic: isArabic))
                                .font(.system(size: 13.5, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(isArabic ? "متحف علقمي المكاني · ARKit" : "Alqami Spatial Museum · ARKit")
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.68))
                                .lineLimit(1)
                        }

                        if let logoImg = BundleImageLoader.uiImage(named: "logo.png") {
                            Image(uiImage: logoImg)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }

                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            hardware.stopSpeaking()
                            onDismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13.5, weight: .bold))
                                .foregroundColor(.white)
                                .glossyCircle(size: 34)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .glossyGlass(cornerRadius: 22, tintOpacity: 0.28)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .environment(\.layoutDirection, .leftToRight)

                // Raycast CollisionCastHit & WorldAnchor Status Glossy Pill (Images 2, 3, 4)
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.isPlaced ? Color.green : (viewModel.isSurfaceDetected ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.orange))
                        .frame(width: 7.5, height: 7.5)

                    Text(viewModel.statusMessage)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if viewModel.isPlaced {
                        Text("• \(Int(viewModel.scaleMultiplier * 100))%")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .glossyPill()

                Spacer()
            }

            // MARK: - 2. Collapsible Floating Apple Glossy Glass HUD Card on Right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    collapsibleRightHUDCard
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 74)
                .environment(\.layoutDirection, .leftToRight)
            }

            // MARK: - 3. Bottom Spatial AR Controls Glossy Pill (Re-Anchor, 1:1 Scale, AR Camera Snapshot, Mesh Wireframe, USD Scene Inspector)
            VStack {
                Spacer()
                HStack(spacing: 9) {
                    // Re-anchor WorldAnchor on Raycast Plane
                    Button(action: {
                        viewModel.resetPlacement()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "scope")
                            Text(isArabic ? "إعادة التثبيت" : "Re-Anchor")
                        }
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glossyPill()
                    }
                    .buttonStyle(.plain)

                    // 1:1 True Scale Button
                    Button(action: {
                        viewModel.setScale(1.0)
                        SpatialSoundHelper.shared.playScaleTickHaptic()
                    }) {
                        Text("1:1")
                            .font(.system(size: 11.5, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 8)
                            .glossyPill(isSelected: true)
                    }
                    .buttonStyle(.plain)

                    // Real AR Snapshot Camera Button (Saves ARView photo to iOS Photos)
                    Button(action: {
                        viewModel.captureARSnapshot()
                    }) {
                        Image(systemName: viewModel.snapshotSavedToast ? "checkmark" : "camera.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(viewModel.snapshotSavedToast ? .black : .white)
                            .glossyCircle(size: 34, isSelected: viewModel.snapshotSavedToast)
                    }
                    .buttonStyle(.plain)

                    // Toggle MeshAnchor StaticMesh Wireframe (Image 2)
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation { viewModel.showMeshWireframe.toggle() }
                    }) {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(viewModel.showMeshWireframe ? .black : .white)
                            .glossyCircle(size: 34, isSelected: viewModel.showMeshWireframe)
                    }
                    .buttonStyle(.plain)

                    // Universal Scene Description (.usda / Reality Composer Pro) Sheet Trigger
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        showUSDASheet = true
                    }) {
                        Text("USD")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 8)
                            .glossyPill()
                    }
                    .buttonStyle(.plain)

                    // Show/Hide Metadata Card Toggle
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isHUDCollapsed.toggle()
                        }
                    }) {
                        Image(systemName: isHUDCollapsed ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 34)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .glossyGlass(cornerRadius: 28, tintOpacity: 0.30)
                .padding(.bottom, 12)
            }
        }
        .onDisappear {
            hardware.stopSpeaking()
        }
        .sheet(isPresented: $showUSDASheet) {
            usdSceneDescriptionInspectorSheet
        }
    }

    // MARK: - Collapsible Floating Apple Glossy Glass HUD Card
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
                VStack(spacing: 3) {
                    Capsule()
                        .fill(Color.white.opacity(0.42))
                        .frame(width: 34, height: 4)
                    Image(systemName: isHUDCollapsed ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(.white.opacity(0.65))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            .buttonStyle(.plain)

            if !isHUDCollapsed {
                // Tabs Header: "Spatial ECS" | "الوصف التاريخي" | "بيانات القطعة"
                HStack(spacing: 0) {
                    hudTabButton(
                        tab: .spatialGraph,
                        title: "Spatial ECS"
                    )
                    hudTabButton(
                        tab: .description,
                        title: isArabic ? "الوصف التاريخي" : "Historical"
                    )
                    hudTabButton(
                        tab: .metadata,
                        title: isArabic ? "بيانات القطعة" : "Metadata"
                    )
                }
                .padding(.horizontal, 10)

                Divider().background(Color.white.opacity(0.15))

                // Tab Body
                switch activeHUDTab {
                case .metadata:
                    VStack(spacing: 7) {
                        HStack(spacing: 7) {
                            metadataBox(
                                label: isArabic ? "الحقبة / التاريخ" : "Period / Date",
                                value: item.period.text(isArabic: isArabic)
                            )
                            metadataBox(
                                label: isArabic ? "المنشئ / الشارح" : "Creator / Author",
                                value: item.creator.text(isArabic: isArabic)
                            )
                        }

                        HStack(spacing: 7) {
                            metadataBox(
                                label: isArabic ? "جهة الحفظ" : "Repository",
                                value: item.institution.text(isArabic: isArabic)
                            )
                            metadataBox(
                                label: isArabic ? "القياسات / الأبعاد" : "Measurements",
                                value: item.dimensions.formatted(isArabic: isArabic)
                            )
                        }

                        metadataBox(
                            label: isArabic ? "المادة والخط" : "Material & Script",
                            value: item.material.text(isArabic: isArabic)
                        )
                    }
                    .padding(11)
                    .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)

                case .description:
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.description.text(isArabic: isArabic))
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(3)

                        Text(item.historicalContext.text(isArabic: isArabic))
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                            .lineSpacing(3)
                    }
                    .padding(12)
                    .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)

                case .spatialGraph:
                    spatialComputingECSGraphView
                        .padding(11)
                }
            }
        }
        .frame(width: min(UIScreen.main.bounds.width - 24, 360))
        .glossyGlass(cornerRadius: 22, tintOpacity: 0.30)
    }

    // MARK: - Live Spatial Computing ECS & Raycasting Diagram (Images 1, 2, 3, 4)
    private var spatialComputingECSGraphView: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                ecsPill("RealityView / ARView", color: .blue)
                Image(systemName: "arrow.right").font(.system(size: 8.5)).foregroundColor(.white.opacity(0.5))
                ecsPill("Content / Scene", color: .gray)
                Image(systemName: "arrow.right").font(.system(size: 8.5)).foregroundColor(.white.opacity(0.5))
                ecsPill("EntityGesture", color: .blue)
            }

            HStack(spacing: 7) {
                ecsPill("MeshAnchor (\(viewModel.activeMeshAnchorCount))", color: .blue)
                VStack(alignment: .leading, spacing: 1) {
                    Text(".transform + generateStaticMesh()")
                        .font(.system(size: 8.5, design: .monospaced))
                        .foregroundColor(.cyan)
                    Text("→ Entity [Transform + Collision]")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(7)
            .glossyGlass(cornerRadius: 10, tintOpacity: 0.14)

            HStack(spacing: 7) {
                ecsPill("CollisionCastHit", color: .green)
                VStack(alignment: .leading, spacing: 1) {
                    let n = viewModel.lastCollisionCastNormal
                    Text(String(format: "Normal: (%.2f, %.2f, %.2f)", n.x, n.y, n.z))
                        .font(.system(size: 8.5, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    let p = viewModel.lastCollisionPosition
                    Text(String(format: "Hit Pos: (%.2f, %.2f, %.2f)m", p.x, p.y, p.z))
                        .font(.system(size: 8.5, design: .monospaced))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
            }
            .padding(7)
            .glossyGlass(cornerRadius: 10, tintOpacity: 0.14)

            HStack(spacing: 7) {
                ecsPill("WorldAnchor (\(viewModel.activeWorldAnchorCount))", color: .indigo)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Entity [Transform + Model + Collision]")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("USDZ: \(viewModel.artifact.model.usdzFilename)")
                        .font(.system(size: 8.5, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(7)
            .glossyGlass(cornerRadius: 10, tintOpacity: 0.14)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func ecsPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 6).fill(color.opacity(0.85)))
    }

    private func hudTabButton(tab: HUDTab, title: String) -> some View {
        let isSelected = activeHUDTab == tab
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            withAnimation(.easeInOut(duration: 0.2)) {
                activeHUDTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white.opacity(0.65))
                Rectangle()
                    .fill(isSelected ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .buttonStyle(.plain)
    }

    private func metadataBox(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 9.5, weight: .semibold))
                .foregroundColor(.white.opacity(0.55))
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .glossyGlass(cornerRadius: 11, tintOpacity: 0.12)
    }

    // MARK: - Universal Scene Description (.usda) & Reality Composer Pro Inspector Sheet
    private var usdSceneDescriptionInspectorSheet: some View {
        ZStack {
            Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Universal Scene Description (USD / Reality Composer Pro)")
                            .font(.system(size: 14.5, weight: .bold))
                            .foregroundColor(.white)
                        Text(viewModel.artifact.model.usdzFilename)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                    Spacer()
                    Button(action: { showUSDASheet = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 32)
                    }
                    .buttonStyle(.plain)
                }

                ScrollView {
                    Text(RealityComposerContentBundle.shared.generateUSDASceneDescription(for: viewModel.artifact))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(red: 0.55, green: 0.92, blue: 0.72))
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glossyGlass(cornerRadius: 16, tintOpacity: 0.35)
                }
            }
            .padding(18)
        }
        .presentationDetents([.medium, .large])
    }
}
