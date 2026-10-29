import SwiftUI
import CoreMotion

// MARK: - App Navigation Tab (Exact 4 Modes from User Screenshots)
// Tab 1: Tesla 3D Driving Perception (Image 1)
// Tab 2: AR Scanner (LiDAR + RealityKit)
// Tab 3: Baghdad Apple Maps Navigation (Image 2)
// Tab 4: 3D Landmarks & Heritage Catalog (Image 3)
public enum AppNavigationTab: String, CaseIterable {
    case teslaRoad = "teslaRoad"
    case arScanner = "arScanner"
    case baghdadMap = "baghdadMap"
    case landmarks = "landmarks"
    
    public func title(isArabic: Bool) -> String {
        switch self {
        case .teslaRoad:
            return isArabic ? "تسلا 3D" : "Tesla 3D"
        case .arScanner:
            return isArabic ? "الماسح AR" : "AR Scanner"
        case .baghdadMap:
            return isArabic ? "الخريطة" : "Map"
        case .landmarks:
            return isArabic ? "المعالم والآثار" : "Landmarks"
        }
    }
    
    public var iconSystemName: String {
        switch self {
        case .teslaRoad:
            return "car.fill"
        case .arScanner:
            return "qrcode.viewfinder"
        case .baghdadMap:
            return "map.fill"
        case .landmarks:
            return "sparkles"
        }
    }
}

// MARK: - Flagship Native iOS Experience (Full Power of iPhone 15 Pro Max & Liquid Glass)
public struct SpatialRootView: View {
    @StateObject private var catalogViewModel = CatalogViewModel()
    @ObservedObject private var lighting = LightingManager.shared
    @ObservedObject private var hardware = RealHardwareMonitor.shared

    // Core 4-Mode Navigation State
    @State private var activeAppTab: AppNavigationTab = .teslaRoad
    
    // Legacy / Modal Sub-views
    @State private var selectedArtifactForDetail: Artifact? = nil
    @State private var activeARArtifact: Artifact? = nil
    @State private var showControlCenter: Bool = false
    @State private var showScanner: Bool = false
    @State private var showBentoRoom: Bool = false
    @State private var showDuoFoldShowcase: Bool = false
    @State private var showHeritageCatalogSheet: Bool = false

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

                // Main 4-Mode Content View
                ZStack {
                    switch activeAppTab {
                    case .teslaRoad:
                        TeslaRoadView()
                            .transition(.opacity)
                        
                    case .arScanner:
                        ARScannerTabView()
                            .transition(.opacity)
                        
                    case .baghdadMap:
                        BaghdadMapView(
                            onSelectLandmarkForAR: { landmark in
                                launchLandmarkInAR(landmark)
                            },
                            onStartNavigation: { landmark in
                                startHighwayNavigation(to: landmark)
                            }
                        )
                        .transition(.opacity)
                        
                    case .landmarks:
                        LandmarksCatalogView(
                            onSelectLandmarkForAR: { landmark in
                                launchLandmarkInAR(landmark)
                            },
                            onStartNavigation: { landmark in
                                startHighwayNavigation(to: landmark)
                            }
                        )
                        .transition(.opacity)
                    }

                    // Detail View Overlay if an artifact was selected
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
                        .zIndex(20)
                    }

                    // Duo-Fold 3D Carousel Showcase
                    if showDuoFoldShowcase {
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
                        .zIndex(25)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - 3. Floating 4-Tab Liquid Glass Navigation Dock (Matches Image 1, 2, 3)
                if selectedArtifactForDetail == nil && !showDuoFoldShowcase {
                    floatingLiquidGlassDock
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                }
            }

            // MARK: - 4. Studio & Hardware Control Center Overlay
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
        // Antiquities / Manuscripts Catalog Modal
        .sheet(isPresented: $showHeritageCatalogSheet) {
            CatalogHomeView(
                viewModel: catalogViewModel,
                activeOrnamentTab: .catalog,
                onSelectArtifact: { artifact in
                    showHeritageCatalogSheet = false
                    selectedArtifactForDetail = artifact
                },
                onLaunchAR: { artifact in
                    showHeritageCatalogSheet = false
                    activeARArtifact = artifact
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

            // Menu Options (Catalog, Duo-Fold, Scanner, Room Bento, Language)
            Menu {
                Button(action: {
                    withAnimation { catalogViewModel.isArabic.toggle() }
                }) {
                    Label(catalogViewModel.isArabic ? "Switch to English" : "التحويل للعربية", systemImage: "globe")
                }
                Divider()
                Button(action: {
                    showHeritageCatalogSheet = true
                }) {
                    Label(catalogViewModel.isArabic ? "المعرض التراثي والمخطوطات (11 مقتنى)" : "Heritage Artifacts Catalog", systemImage: "books.vertical")
                }
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

    // MARK: - 3. Floating 4-Tab Liquid Glass Navigation Dock (Matches Image 1, 2, 3)
    private var floatingLiquidGlassDock: some View {
        HStack(spacing: 4) {
            dockTabButton(tab: .teslaRoad)
            dockTabButton(tab: .arScanner)
            dockTabButton(tab: .baghdadMap)
            dockTabButton(tab: .landmarks)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .glossyGlass(cornerRadius: 32, tintOpacity: 0.28, shadowRadius: 22)
    }

    private func dockTabButton(tab: AppNavigationTab) -> some View {
        let isSelected = activeAppTab == tab
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                activeAppTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.iconSystemName)
                    .font(.system(size: 16, weight: isSelected ? .black : .semibold))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white.opacity(0.65))
                    .frame(height: 24)

                Text(tab.title(isArabic: catalogViewModel.isArabic))
                    .font(.system(size: 10, weight: isSelected ? .heavy : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.55))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Action Helpers
    private func startHighwayNavigation(to landmark: BaghdadLandmark) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeAppTab = .teslaRoad
        }
        SpatialSoundHelper.shared.playPlacementHaptic()
    }
    
    private func launchLandmarkInAR(_ landmark: BaghdadLandmark) {
        // Find matching artifact or use hero artifact
        let modelId = landmark.modelIdentifier ?? ""
        if let match = catalogViewModel.artifacts.first(where: { $0.id.contains(modelId) || $0.model.usdzFile.contains(modelId) }) {
            activeARArtifact = match
        } else {
            activeARArtifact = catalogViewModel.heroArtifact
        }
        SpatialSoundHelper.shared.playPlacementHaptic()
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
                        .foregroundColor(.white)

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
            .glossyGlass(cornerRadius: 24, tintOpacity: 0.28, shadowRadius: 22)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func duoFold3DLeaf(current: Artifact) -> some View {
        ZStack {
            Artifact3DTurntableSceneView(
                artifact: current,
                enableGestures: true
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack {
                HStack {
                    Text(current.category.title(isArabic: isArabic))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                    Spacer()
                }
                Spacer()
            }
            .padding(10)
        }
        .glossyGlass(cornerRadius: 18)
    }

    private func duoFoldTextLeaf(current: Artifact) -> some View {
        VStack(alignment: isArabic ? .trailing : .leading, spacing: 8) {
            Text(current.title.text(isArabic: isArabic))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)

            Text(current.description.text(isArabic: isArabic))
                .font(.system(size: 11.5))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(4)
                .lineSpacing(3)

            Spacer()

            HStack(spacing: 8) {
                Button(action: { onLaunchAR(current) }) {
                    Label(isArabic ? "واقع معزز" : "AR Mode", systemImage: "arkit")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .glossyPill(isSelected: true)
                }
                .buttonStyle(.plain)

                Button(action: { onSelectArtifact(current) }) {
                    Label(isArabic ? "التفاصيل" : "Details", systemImage: "info.circle")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .glossyPill()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .glossyGlass(cornerRadius: 18)
    }

    private func flipPage(delta: Int) {
        SpatialSoundHelper.shared.playSnapHaptic()
        let count = max(1, artifacts.count)
        withAnimation(.easeInOut(duration: 0.32)) {
            currentIndex = (currentIndex + delta + count) % count
        }
    }
}
