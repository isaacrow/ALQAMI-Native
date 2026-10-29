import SwiftUI
import CoreMotion

// MARK: - Flagship Native iOS Experience (Full Power of iPhone 15 Pro Max & Liquid Glass)
public struct SpatialRootView: View {
    @StateObject private var catalogViewModel = CatalogViewModel()
    @ObservedObject private var lighting = LightingManager.shared
    @ObservedObject private var hardware = RealHardwareMonitor.shared

    // Navigation State
    @State private var selectedArtifactForDetail: Artifact? = nil
    @State private var activeARArtifact: Artifact? = nil
    @State private var activeTab: CatalogHomeView.OrnamentTab = .catalog
    @State private var showControlCenter: Bool = false
    @State private var showScanner: Bool = false
    @State private var showBentoRoom: Bool = false
    @State private var showDuoFoldShowcase: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            // MARK: - 1. Dynamic Reactive OLED Backdrop (Smooth 60Hz Gyroscope Parallax)
            deviceOLEDBackdrop
                .ignoresSafeArea()

            // MARK: - 2. Native Edge-to-Edge Content with Safe Area Padding
            VStack(spacing: 0) {
                // Top Native Flagship Header (Below Dynamic Island)
                topFlagshipHeaderBar
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 6)

                // Main Content View (Catalog, Details, or Duo-Fold)
                ZStack {
                    if let detailArtifact = selectedArtifactForDetail {
                        ArtifactDetailView(
                            artifact: detailArtifact,
                            isArabic: catalogViewModel.isArabic,
                            isFavorite: catalogViewModel.isFavorite(detailArtifact.id),
                            onToggleFavorite: { id in
                                catalogViewModel.toggleFavorite(id)
                            },
                            onBack: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    selectedArtifactForDetail = nil
                                }
                            },
                            onLaunchAR: { art in
                                activeARArtifact = art
                            }
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                    } else if showDuoFoldShowcase {
                        DuoFoldShowcaseModalView(
                            artifacts: catalogViewModel.artifacts,
                            isArabic: catalogViewModel.isArabic,
                            onSelectArtifact: { artifact in
                                showDuoFoldShowcase = false
                                selectedArtifactForDetail = artifact
                            },
                            onLaunchAR: { artifact in
                                showDuoFoldShowcase = false
                                activeARArtifact = artifact
                            },
                            onClose: {
                                withAnimation(.spring()) { showDuoFoldShowcase = false }
                            }
                        )
                        .padding(.horizontal, 14)
                    } else {
                        CatalogHomeView(
                            viewModel: catalogViewModel,
                            activeOrnamentTab: activeTab,
                            onSelectArtifact: { artifact in
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    selectedArtifactForDetail = artifact
                                }
                            },
                            onLaunchAR: { artifact in
                                activeARArtifact = artifact
                            }
                        )
                        .environment(\.layoutDirection, catalogViewModel.isArabic ? .rightToLeft : .leftToRight)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Floating Liquid Glass Navigation Dock (Above Home Indicator)
                if selectedArtifactForDetail == nil && !showDuoFoldShowcase {
                    floatingLiquidGlassDock
                        .padding(.horizontal, 20)
                        .padding(.bottom, 6)
                }
            }

            // MARK: - 3. Studio & Hardware Control Center Overlay
            if showControlCenter {
                ControlCenterView(
                    isArabic: catalogViewModel.isArabic,
                    onSelectLanguage: { isAr in
                        withAnimation { catalogViewModel.isArabic = isAr }
                    },
                    onOpenARWorld: {
                        activeARArtifact = catalogViewModel.heroArtifact
                    },
                    onOpenScanner: {
                        showScanner = true
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showControlCenter = false
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(50)
            }
        }
        // Fullscreen Native RealityKit + ARKit + Raycasting View (100% Crash-Free)
        .fullScreenCover(item: $activeARArtifact) { artifact in
            ARContainerView(artifact: artifact) {
                activeARArtifact = nil
            }
        }
        // Vision AI & Barcode Scanner
        .fullScreenCover(isPresented: $showScanner) {
            CulturalVisionScannerView(
                onSelectArtifact: { artifact in
                    showScanner = false
                    activeARArtifact = artifact
                },
                onDismiss: {
                    showScanner = false
                }
            )
        }
        // 8-Hotspot Room Bento
        .fullScreenCover(isPresented: $showBentoRoom) {
            RoomBentoView(
                onLaunchAR: { artifact in
                    showBentoRoom = false
                    activeARArtifact = artifact
                },
                onDismiss: {
                    showBentoRoom = false
                }
            )
        }
    }

    // MARK: - 1. OLED Backdrop
    private var deviceOLEDBackdrop: some View {
        ZStack {
            // Pure OLED Black base with deep navy ambient glow
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.05, blue: 0.08),
                    Color(red: 0.07, green: 0.09, blue: 0.15),
                    Color(red: 0.03, green: 0.04, blue: 0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Real Room backdrop subtle illumination driven by gyroscope
            if let roomImg = BundleImageLoader.uiImage(named: "custom_room_bg.png") {
                Image(uiImage: roomImg)
                    .resizable()
                    .scaledToFill()
                    .offset(x: hardware.deviceRoll * 20, y: hardware.devicePitch * 14)
                    .opacity(0.18)
                    .blur(radius: 6)
            }

            // Radial vignette
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.65)],
                center: .center,
                startRadius: 120,
                endRadius: 500
            )
        }
    }

    // MARK: - 2. Top Native Flagship Header Bar (Safe Under Dynamic Island)
    private var topFlagshipHeaderBar: some View {
        HStack(spacing: 10) {
            // Alqami Emblem Button
            HStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    if let logo = BundleImageLoader.uiImage(named: "logo.png") {
                        Image(uiImage: logo)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    } else {
                        Text("ع")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Circle()
                        .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .frame(width: 6, height: 6)
                        .offset(x: 2, y: -2)
                }
                .glossyCircle(size: 36)

                Text("علقمي")
                    .font(.system(size: 16, weight: .black, design: .serif))
                    .foregroundColor(.white)
            }

            Spacer()

            // Real Live Hardware Chip (Clock + Battery Level)
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showControlCenter.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Text(hardware.currentTimeString)
                        .font(.system(size: 11.5, weight: .bold))
                    Text("•")
                        .foregroundColor(.white.opacity(0.4))
                    HStack(spacing: 3) {
                        Image(systemName: hardware.batteryState == .charging ? "bolt.fill" : "battery.100")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        Text("\(hardware.batteryPercentage)%")
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .glossyPill()
            }
            .buttonStyle(.plain)

            // AR Camera Mode Quick Button
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                activeARArtifact = catalogViewModel.heroArtifact
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arkit")
                        .font(.system(size: 12, weight: .bold))
                    Text("AR")
                        .font(.system(size: 11, weight: .black))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .glossyPill(isSelected: true)
            }
            .buttonStyle(.plain)

            // Menu Options (Duo-Fold, Scanner, Room Bento, Language)
            Menu {
                Button(action: {
                    withAnimation { catalogViewModel.isArabic.toggle() }
                }) {
                    Label(catalogViewModel.isArabic ? "Switch to English" : "التحويل للعربية", systemImage: "globe")
                }
                Divider()
                Button(action: {
                    showScanner = true
                }) {
                    Label(catalogViewModel.isArabic ? "الماسح البصري الذكي (Vision Scanner)" : "Vision AI Scanner", systemImage: "qrcode.viewfinder")
                }
                Button(action: {
                    showBentoRoom = true
                }) {
                    Label(catalogViewModel.isArabic ? "معرض الغرفة المكانية (8 نقاط)" : "Spatial Room (8 Hotspots)", systemImage: "dot.scope")
                }
                Button(action: {
                    withAnimation(.spring()) { showDuoFoldShowcase = true }
                }) {
                    Label(catalogViewModel.isArabic ? "العرض المطوي ثلاثي الأبعاد" : "Duo-Fold 3D Book", systemImage: "book.pages")
                }
                Divider()
                Button(action: {
                    showControlCenter = true
                }) {
                    Label(catalogViewModel.isArabic ? "مركز التحكم وإضاءة الاستوديو" : "Control Center & Lighting", systemImage: "slider.horizontal.3")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .glossyCircle(size: 36)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - 3. Floating Liquid Glass Dock (Bottom Navigation Bar)
    private var floatingLiquidGlassDock: some View {
        HStack(spacing: 8) {
            dockTabButton(tab: .catalog, icon: "square.grid.2x2", labelAr: "المعرض", labelEn: "Catalog")
            dockTabButton(tab: .search, icon: "magnifyingglass", labelAr: "البحث", labelEn: "Search")

            // Center Primary AR World Button
            Button(action: {
                SpatialSoundHelper.shared.playPlacementHaptic()
                activeARArtifact = catalogViewModel.heroArtifact
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.839, blue: 0.039), Color(red: 0.95, green: 0.65, blue: 0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.8), lineWidth: 1.2)
                        )
                        .shadow(color: Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.45), radius: 10, y: 4)

                    Image(systemName: "arkit")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(.plain)
            .offset(y: -4)

            dockTabButton(tab: .favorites, icon: "heart", labelAr: "المفضلة", labelEn: "Favorites", badgeCount: catalogViewModel.favoriteIds.count)
            dockTabButton(tab: .bag, icon: "bag", labelAr: "الخزانة", labelEn: "Vault")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glossyGlass(cornerRadius: 32, tintOpacity: 0.28, shadowRadius: 22)
    }

    private func dockTabButton(
        tab: CatalogHomeView.OrnamentTab,
        icon: String,
        labelAr: String,
        labelEn: String,
        badgeCount: Int = 0
    ) -> some View {
        let isSelected = activeTab == tab
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                activeTab = tab
            }
        }) {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected && icon == "heart" ? "heart.fill" : icon)
                        .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white.opacity(0.65))
                        .frame(width: 38, height: 28)

                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.system(size: 8.5, weight: .heavy, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                            .offset(x: 4, y: -2)
                    }
                }

                Text(catalogViewModel.isArabic ? labelAr : labelEn)
                    .font(.system(size: 9.5, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Duo-Fold 3D Mechanical Book/Door Carousel Showcase (Apple Liquid Glass)
public struct DuoFoldShowcaseModalView: View {
    public let artifacts: [Artifact]
    public let isArabic: Bool
    public var onSelectArtifact: (Artifact) -> Void
    public var onLaunchAR: (Artifact) -> Void
    public var onClose: () -> Void

    @State private var currentIndex: Int = 0
    @State private var foldRotation: Double = 0

    public var body: some View {
        let current = artifacts[currentIndex % max(1, artifacts.count)]
        GeometryReader { geo in
            let isWide = geo.size.width > 620
            VStack(spacing: 12) {
                // Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "book.pages.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        Text(isArabic ? "العرض المطوي ثلاثي الأبعاد • DUO-FOLD 3D" : "DUO-FOLD 3D SPATIAL SHOWCASE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 32)
                    }
                    .buttonStyle(.plain)
                }

                if isWide {
                    HStack(spacing: 10) {
                        duoFold3DLeaf(current: current)
                        duoFoldTextLeaf(current: current)
                    }
                } else {
                    VStack(spacing: 10) {
                        duoFold3DLeaf(current: current)
                            .frame(height: 210)
                        duoFoldTextLeaf(current: current)
                    }
                }

                // Bottom Prev/Next Controls
                HStack(spacing: 14) {
                    Button(action: { flipPage(delta: -1) }) {
                        Label(isArabic ? "السابق" : "Prev", systemImage: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glossyPill()
                    }
                    .buttonStyle(.plain)

                    Text("\(currentIndex + 1) / \(artifacts.count)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))

                    Button(action: { flipPage(delta: 1) }) {
                        Label(isArabic ? "التالي" : "Next", systemImage: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glossyPill()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .glossyGlass(cornerRadius: 28, tintOpacity: 0.26)
        }
    }

    private func duoFold3DLeaf(current: Artifact) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.796, green: 0.788, blue: 0.773)) // #CBC9C5

            Artifact3DTurntableSceneView(
                artifact: current,
                autoRotate: true,
                allowsCameraControl: true,
                cameraDistance: 0.65
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .rotation3DEffect(.degrees(foldRotation), axis: (x: 0, y: 1, z: 0), anchor: .trailing)
    }

    private func duoFoldTextLeaf(current: Artifact) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(current.itemCode)
                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))

            Text(current.title.text(isArabic: isArabic))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)

            Text(current.subtitle.text(isArabic: isArabic))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.68))
                .lineLimit(1)

            Text(current.description.text(isArabic: isArabic))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(3)

            Spacer(minLength: 4)

            HStack(spacing: 8) {
                Button(action: { onLaunchAR(current) }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arkit")
                        Text(isArabic ? "معاينة في المكان (AR)" : "Place in AR")
                    }
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .glossyPill(isSelected: true)
                }
                .buttonStyle(.plain)

                Button(action: { onSelectArtifact(current) }) {
                    Text(isArabic ? "التفاصيل الكاملة" : "Full Details")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .glossyPill()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .glossyGlass(cornerRadius: 20, tintOpacity: 0.18)
        .rotation3DEffect(.degrees(-foldRotation), axis: (x: 0, y: 1, z: 0), anchor: .leading)
    }

    private func flipPage(delta: Int) {
        guard !artifacts.isEmpty else { return }
        SpatialSoundHelper.shared.playSnapHaptic()
        withAnimation(.easeInOut(duration: 0.18)) {
            foldRotation = delta > 0 ? 35 : -35
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            currentIndex = (currentIndex + delta + artifacts.count) % artifacts.count
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                foldRotation = 0
            }
        }
    }
}
