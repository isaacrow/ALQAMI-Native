import SwiftUI
import CoreMotion

// MARK: - Complete visionOS Spatial OS Shell & Honeycomb Launcher with Apple Glossy Glass & Real Gyroscope Parallax
public struct SpatialRootView: View {
    @StateObject private var catalogViewModel = CatalogViewModel()
    @ObservedObject private var lighting = LightingManager.shared
    @ObservedObject private var hardware = RealHardwareMonitor.shared

    // Window & Navigation State
    @State private var selectedArtifactForDetail: Artifact? = nil
    @State private var activeARArtifact: Artifact? = nil
    @State private var activeOrnamentTab: CatalogHomeView.OrnamentTab = .catalog
    @State private var showHomeLauncher: Bool = false
    @State private var showControlCenter: Bool = false
    @State private var showScanner: Bool = false
    @State private var showBentoRoom: Bool = false
    @State private var showDuoFoldShowcase: Bool = false

    // 3D Room Parallax Camera State (Real Gyroscope + Touch Drag)
    @State private var dragYaw: CGFloat = 0
    @State private var dragPitch: CGFloat = 0
    @State private var windowOffset: CGSize = .zero

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - 1. 3D Spatial Room Environment Backdrop (custom_room_bg.png + Real 60Hz Gyroscope Parallax + Camera AR World)
                spatialRoomBackdrop(size: geo.size)

                // MARK: - 2. Main Spatial Window OR Home Honeycomb Launcher
                VStack(spacing: 0) {
                    // Top Quiet visionOS Shell Controls (Alqami Logo, Home Grid Button, Time + Control Center Pill, Spatial Mode Pill)
                    topQuietShellBar
                        .padding(.horizontal, 14)
                        .padding(.top, 6)
                        .padding(.bottom, 6)

                    if showHomeLauncher {
                        HomeHoneycombLauncherView(
                            isArabic: catalogViewModel.isArabic,
                            onOpenApp: { appId in
                                handleLaunchApp(appId)
                            }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
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
                        .padding(.horizontal, 10)
                    } else {
                        // Floating Apple Glossy Glass Window + Left/Bottom Ornament
                        spatialFloatingWindow(size: geo.size)
                            .offset(windowOffset)
                    }

                    Spacer(minLength: 4)

                    // Bottom Window Grab Bar + Bottom-Right Creator Credit Pill
                    bottomWindowChromeAndCreatorCredit
                        .padding(.horizontal, 14)
                        .padding(.bottom, 4)
                }

                // MARK: - 3. 3-Panel Control Center Overlay (Real Hardware Telemetry)
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
        }
        // Fullscreen Native RealityKit + ARKit + Raycasting View
        .fullScreenCover(item: $activeARArtifact) { artifact in
            ARContainerView(artifact: artifact) {
                activeARArtifact = nil
            }
        }
        // Real Vision + ARKit 3D Object & QR Scanner
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
        // Room Bento 8-Hotspot Interactive View
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

    // MARK: - 1. Spatial Room Backdrop (custom_room_bg.png + Real CMMotionManager 60Hz Gyroscope Parallax)
    private func spatialRoomBackdrop(size: CGSize) -> some View {
        let totalYaw = max(-45, min(45, dragYaw + hardware.deviceRoll * 26))
        let totalPitch = max(-25, min(25, dragPitch + hardware.devicePitch * 18))

        return ZStack {
            if lighting.isSpatialWorldAR {
                // Real Live Camera Passthrough Backdrop
                CameraLivePreviewRepresentable()
                    .ignoresSafeArea()
                Color.black.opacity(0.20)
                    .ignoresSafeArea()
            } else {
                // Base Environment Gradient
                LinearGradient(
                    colors: lighting.environment.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Real Room Background Image (custom_room_bg.png) driven by Real Gyroscope + Touch Parallax
                if lighting.environment == .livingRoom,
                   let roomImg = BundleImageLoader.uiImage(named: "custom_room_bg.png") {
                    Image(uiImage: roomImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width * 1.18, height: size.height * 1.18)
                        .offset(x: totalYaw, y: totalPitch)
                        .clipped()
                        .ignoresSafeArea()
                }

                // Ambient Vignette & Lighting Intensity Overlay
                RadialGradient(
                    colors: [
                        Color.black.opacity(0.14),
                        Color.black.opacity(0.52)
                    ],
                    center: .center,
                    startRadius: 80,
                    endRadius: max(size.width, size.height) * 0.75
                )
                .ignoresSafeArea()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragYaw = max(-40, min(40, value.translation.width * 0.18))
                    dragPitch = max(-22, min(22, value.translation.height * 0.12))
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        dragYaw = 0
                        dragPitch = 0
                    }
                }
        )
    }

    // MARK: - 2. Top Quiet visionOS Shell Controls (Apple Glossy Glass)
    private var topQuietShellBar: some View {
        HStack(spacing: 8) {
            // 1. Round Glossy Alqami Logo Button (Toggles Live Camera Passthrough)
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring()) {
                    lighting.isSpatialWorldAR.toggle()
                }
            }) {
                ZStack {
                    if let logo = BundleImageLoader.uiImage(named: "logo.png") {
                        Image(uiImage: logo)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(lighting.isSpatialWorldAR ? .black : .white)
                            .scaledToFit()
                            .frame(width: 19, height: 19)
                    } else {
                        Text("ع")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(lighting.isSpatialWorldAR ? .black : .white)
                    }
                }
                .glossyCircle(size: 34, isSelected: lighting.isSpatialWorldAR)
            }
            .buttonStyle(.plain)

            // 2. Round Glossy Home View Grid Button (Opens Real Functional ALQAMI Spatial Launcher)
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring(response: 0.36, dampingFraction: 0.8)) {
                    showHomeLauncher.toggle()
                }
            }) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(showHomeLauncher ? .black : .white)
                    .glossyCircle(size: 34, isSelected: showHomeLauncher)
            }
            .buttonStyle(.plain)

            // 3. Live Hardware Clock + Battery + Chevron Pill (Opens 3-Panel Control Center)
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showControlCenter.toggle()
                }
            }) {
                HStack(spacing: 5) {
                    Text(hardware.currentTimeString)
                        .font(.system(size: 11, weight: .bold))
                    Text("• \(hardware.batteryPercentage)%")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8.5, weight: .bold))
                        .opacity(0.75)
                }
                .foregroundColor(showControlCenter ? .black : .white)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .glossyPill(isSelected: showControlCenter)
            }
            .buttonStyle(.plain)

            Spacer()

            // 4. Right Mode Switcher Glossy Pill ("Spatial v" / Duo-Fold / Scanner / AR)
            Menu {
                Button(action: {
                    showHomeLauncher = false
                    showDuoFoldShowcase = false
                    selectedArtifactForDetail = nil
                }) {
                    Label("Spatial Window • نافذة المعرض", systemImage: "macwindow")
                }
                Button(action: {
                    activeARArtifact = catalogViewModel.heroArtifact
                }) {
                    Label("RealityKit AR + Raycast • الواقع المعزز", systemImage: "arkit")
                }
                Button(action: {
                    withAnimation(.spring()) { showDuoFoldShowcase = true }
                }) {
                    Label("Duo-Fold 3D Showcase • العرض المطوي", systemImage: "book.pages")
                }
                Button(action: {
                    showScanner = true
                }) {
                    Label("Vision & QR Scanner • الماسح البصري", systemImage: "qrcode.viewfinder")
                }
                Button(action: {
                    showBentoRoom = true
                }) {
                    Label("Room 8-Hotspot Bento • الغرفة التفاعلية", systemImage: "dot.scope")
                }
                Divider()
                Button(action: {
                    lighting.cycleEnvironment()
                }) {
                    Label("تغيير البيئة: \(lighting.environment.labelAr)", systemImage: "mountain.2")
                }
            } label: {
                HStack(spacing: 5) {
                    Text("Spatial")
                        .font(.system(size: 11, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8.5, weight: .bold))
                        .opacity(0.75)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .glossyPill()
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - 3. Floating Apple Glossy Glass Window + Left/Bottom Ornament
    private func spatialFloatingWindow(size: CGSize) -> some View {
        let isWide = size.width > 640
        return HStack(spacing: 10) {
            if isWide {
                leftVerticalOrnamentPill
            }

            // Main Apple Glossy Glass Window Container
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
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                } else {
                    CatalogHomeView(
                        viewModel: catalogViewModel,
                        activeOrnamentTab: activeOrnamentTab,
                        onSelectArtifact: { artifact in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                selectedArtifactForDetail = artifact
                            }
                        },
                        onLaunchAR: { artifact in
                            activeARArtifact = artifact
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .environment(\.layoutDirection, catalogViewModel.isArabic ? .rightToLeft : .leftToRight)
                }
            }
            .glossyGlass(cornerRadius: 28, tintOpacity: 0.22)
        }
        .padding(.horizontal, isWide ? 16 : 8)
        .overlay(alignment: .bottom) {
            if !isWide {
                compactBottomOrnamentPill
                    .padding(.bottom, 8)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - Left Vertical Ornament Pill (Apple Glossy Glass)
    private var leftVerticalOrnamentPill: some View {
        VStack(spacing: 8) {
            ornamentIconButton(tab: .catalog, icon: "square.grid.2x2", badgeDot: false)
            ornamentIconButton(tab: .search, icon: "magnifyingglass", badgeDot: false)
            ornamentIconButton(tab: .about, icon: "person", badgeDot: false)
            ornamentIconButton(tab: .favorites, icon: "heart", badgeDot: !catalogViewModel.favoriteIds.isEmpty)
            ornamentIconButton(tab: .bag, icon: "bag", badgeDot: false)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 7)
        .glossyGlass(cornerRadius: 26, tintOpacity: 0.25)
    }

    // MARK: - Compact Bottom Ornament Pill for iPhone (Apple Glossy Glass)
    private var compactBottomOrnamentPill: some View {
        HStack(spacing: 10) {
            ornamentIconButton(tab: .catalog, icon: "square.grid.2x2", badgeDot: false)
            ornamentIconButton(tab: .search, icon: "magnifyingglass", badgeDot: false)
            ornamentIconButton(tab: .about, icon: "person", badgeDot: false)
            ornamentIconButton(tab: .favorites, icon: "heart", badgeDot: !catalogViewModel.favoriteIds.isEmpty)
            ornamentIconButton(tab: .bag, icon: "bag", badgeDot: false)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .glossyPill()
    }

    private func ornamentIconButton(tab: CatalogHomeView.OrnamentTab, icon: String, badgeDot: Bool) -> some View {
        let isSelected = activeOrnamentTab == tab && selectedArtifactForDetail == nil
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedArtifactForDetail = nil
                activeOrnamentTab = tab
            }
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 13.5, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? .black : .white)
                    .glossyCircle(size: 34, isSelected: isSelected)

                if badgeDot {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .frame(width: 7, height: 7)
                        .offset(x: -3, y: 3)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. Bottom visionOS Window Grab Bar + Creator Credit Pill
    private var bottomWindowChromeAndCreatorCredit: some View {
        HStack(spacing: 10) {
            // Center visionOS Window Close Dot + Grab Bar Handle
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 8, height: 8)
                    .onTapGesture {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring()) {
                            selectedArtifactForDetail = nil
                            windowOffset = .zero
                        }
                    }

                Capsule()
                    .fill(Color.white.opacity(0.50))
                    .frame(width: 96, height: 4.5)
                    .gesture(
                        DragGesture()
                            .onChanged { val in
                                windowOffset = CGSize(
                                    width: val.translation.width * 0.35,
                                    height: val.translation.height * 0.35
                                )
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                    windowOffset = .zero
                                }
                            }
                    )
            }

            Spacer()

            // Bottom-Right Creator Credit Glossy Pill
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                selectedArtifactForDetail = nil
                activeOrnamentTab = .about
            }) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .frame(width: 5.5, height: 5.5)
                    Text("isaac faleh · اسحاق فالح")
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(.white.opacity(0.88))
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4.5)
                .glossyPill()
            }
            .buttonStyle(.plain)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func handleLaunchApp(_ appId: String) {
        SpatialSoundHelper.shared.playSnapHaptic()
        showHomeLauncher = false
        switch appId {
        case "catalog":
            selectedArtifactForDetail = nil
            activeOrnamentTab = .catalog
        case "ar-world":
            activeARArtifact = catalogViewModel.heroArtifact
        case "vision-scanner":
            showScanner = true
        case "bento-room":
            showBentoRoom = true
        case "duofold":
            showDuoFoldShowcase = true
        case "volume-popout":
            selectedArtifactForDetail = nil
            activeOrnamentTab = .catalog
            catalogViewModel.isPopOut3D = true
        case "live-3d":
            selectedArtifactForDetail = nil
            activeOrnamentTab = .catalog
            catalogViewModel.live3DCatalog = true
        case "voice-guide":
            let hero = catalogViewModel.heroArtifact
            selectedArtifactForDetail = hero
            hardware.speakNarration("\(hero.title.ar). \(hero.description.ar)", isArabic: true)
        case "favorites":
            selectedArtifactForDetail = nil
            activeOrnamentTab = .favorites
        case "bag-vault":
            selectedArtifactForDetail = nil
            activeOrnamentTab = .bag
        case "control-center":
            showControlCenter = true
        case "camera-passthrough":
            lighting.isSpatialWorldAR.toggle()
        default:
            selectedArtifactForDetail = nil
            activeOrnamentTab = .catalog
        }
    }
}

// MARK: - 12 Real Functional ALQAMI Spatial Modules Launcher (Apple Glossy Glass, Zero Fake Apps)
public struct HomeHoneycombLauncherView: View {
    public var isArabic: Bool = true
    public var onOpenApp: (String) -> Void

    private struct SpatialAppItem: Identifiable {
        let id: String
        let nameAr: String
        let nameEn: String
        let subtitleAr: String
        let subtitleEn: String
        let icon: String
        let colors: [Color]
        let badge: String?
    }

    private let apps: [SpatialAppItem] = [
        SpatialAppItem(id: "catalog", nameAr: "معرض علقمي", nameEn: "Alqami Gallery", subtitleAr: "١١ مخطوطة وأثر 3D", subtitleEn: "11 Real USDZ Artifacts", icon: "building.columns.fill", colors: [Color(red: 0.11, green: 0.34, blue: 0.72), Color(red: 0.06, green: 0.20, blue: 0.47)], badge: "11"),
        SpatialAppItem(id: "ar-world", nameAr: "الواقع المعزز AR", nameEn: "RealityKit AR", subtitleAr: "تثبيت Raycast في الغرفة", subtitleEn: "WorldAnchor & Mesh", icon: "arkit", colors: [Color(red: 0.95, green: 0.72, blue: 0.05), Color(red: 0.85, green: 0.48, blue: 0.02)], badge: "AR"),
        SpatialAppItem(id: "vision-scanner", nameAr: "الماسح البصري", nameEn: "Vision Scanner", subtitleAr: "كاميرا QR و Vision AI", subtitleEn: "Real Camera & Barcode", icon: "qrcode.viewfinder", colors: [Color(red: 0.15, green: 0.68, blue: 0.52), Color(red: 0.08, green: 0.42, blue: 0.34)], badge: "LIVE"),
        SpatialAppItem(id: "bento-room", nameAr: "الغرفة التفاعلية", nameEn: "Room 8-Hotspots", subtitleAr: "٨ نقاط مكانية في الغرفة", subtitleEn: "8 Spatial Room Pins", icon: "dot.scope", colors: [Color(red: 0.52, green: 0.28, blue: 0.85), Color(red: 0.32, green: 0.16, blue: 0.58)], badge: "8"),
        SpatialAppItem(id: "duofold", nameAr: "العرض المطوي", nameEn: "Duo-Fold Book", subtitleAr: "تصفح ثلاثي الأبعاد", subtitleEn: "3D Hinged Manuscript", icon: "book.pages.fill", colors: [Color(red: 0.82, green: 0.32, blue: 0.48), Color(red: 0.52, green: 0.16, blue: 0.28)], badge: "3D"),
        SpatialAppItem(id: "volume-popout", nameAr: "المجسم العائم", nameEn: "3D Volume Pop-Out", subtitleAr: "فحص النقوش والأختام", subtitleEn: "360° Callout Inspector", icon: "rotate.3d", colors: [Color(red: 0.18, green: 0.55, blue: 0.88), Color(red: 0.10, green: 0.32, blue: 0.62)], badge: nil),
        SpatialAppItem(id: "live-3d", nameAr: "الكتالوج ثلاثي الأبعاد", nameEn: "Live 3D Grid", subtitleAr: "تدوير مباشر لكل البطاقات", subtitleEn: "Real-Time USDZ Cards", icon: "cube.transparent.fill", colors: [Color(red: 0.88, green: 0.52, blue: 0.15), Color(red: 0.62, green: 0.30, blue: 0.08)], badge: "USDZ"),
        SpatialAppItem(id: "voice-guide", nameAr: "المرشد الصوتي", nameEn: "Audio Guide", subtitleAr: "نطق عربي وإنجليزي حي", subtitleEn: "Real AVSpeech Narration", icon: "waveform.circle.fill", colors: [Color(red: 0.22, green: 0.64, blue: 0.78), Color(red: 0.12, green: 0.38, blue: 0.52)], badge: "TTS"),
        SpatialAppItem(id: "camera-passthrough", nameAr: "الكاميرا المكانية", nameEn: "Camera Backdrop", subtitleAr: "دمج النافذة مع غرفتك", subtitleEn: "Live Camera Passthrough", icon: "camera.aperture", colors: [Color(red: 0.35, green: 0.72, blue: 0.38), Color(red: 0.18, green: 0.45, blue: 0.22)], badge: nil),
        SpatialAppItem(id: "favorites", nameAr: "المفضلة", nameEn: "Saved Favorites", subtitleAr: "مقتنياتك المختارة", subtitleEn: "Persisted Collection", icon: "heart.fill", colors: [Color(red: 0.88, green: 0.24, blue: 0.36), Color(red: 0.58, green: 0.12, blue: 0.22)], badge: nil),
        SpatialAppItem(id: "bag-vault", nameAr: "خزانة المقتنيات", nameEn: "Exhibition Vault", subtitleAr: "الأبعاد والأكواد المتحفية", subtitleEn: "Museum Archive Specs", icon: "bag.fill", colors: [Color(red: 0.48, green: 0.42, blue: 0.35), Color(red: 0.28, green: 0.24, blue: 0.20)], badge: nil),
        SpatialAppItem(id: "control-center", nameAr: "مركز التحكم", nameEn: "Control Center", subtitleAr: "حالة البطارية والإضاءة", subtitleEn: "Real Hardware & Studio", icon: "slider.horizontal.3", colors: [Color(red: 0.32, green: 0.38, blue: 0.48), Color(red: 0.18, green: 0.22, blue: 0.30)], badge: nil)
    ]

    public var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > 640
            let cols = isWide
                ? Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
                : Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        Text(isArabic ? "تطبيقات منصة علقمي المكانية • ALQAMI Spatial Suite" : "ALQAMI Spatial Suite • Real Native Modules")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .glossyPill()
                    .padding(.top, 6)

                    LazyVGrid(columns: cols, spacing: 14) {
                        ForEach(apps) { app in
                            honeycombAppIcon(app)
                        }
                    }
                    .padding(.horizontal, isWide ? 24 : 12)
                }
                .padding(.vertical, 14)
            }
            .glossyGlass(cornerRadius: 28, tintOpacity: 0.20)
            .padding(.horizontal, isWide ? 16 : 8)
        }
    }

    private func honeycombAppIcon(_ app: SpatialAppItem) -> some View {
        Button(action: {
            onOpenApp(app.id)
        }) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: app.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.45), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.8), Color.white.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 5)

                    Image(systemName: app.icon)
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 58, height: 58)

                    if let badge = app.badge {
                        Text(badge)
                            .font(.system(size: 8.5, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                            .offset(x: 4, y: -2)
                    }
                }

                Text(isArabic ? app.nameAr : app.nameEn)
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(isArabic ? app.subtitleAr : app.subtitleEn)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.62))
                    .lineLimit(1)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity)
            .glossyGlass(cornerRadius: 20, tintOpacity: 0.14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Duo-Fold 3D Mechanical Book/Door Carousel Showcase (Apple Glossy Glass & Responsive Layout)
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
