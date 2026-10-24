import SwiftUI
import CoreMotion

// MARK: - Complete visionOS Spatial OS Shell & Honeycomb Launcher (App.tsx + SpatialWindow.tsx + HomeViewLauncher.tsx)
public struct SpatialRootView: View {
    @StateObject private var catalogViewModel = CatalogViewModel()
    @ObservedObject private var lighting = LightingManager.shared

    // Window & Navigation State
    @State private var selectedArtifactForDetail: Artifact? = nil
    @State private var activeARArtifact: Artifact? = nil
    @State private var activeOrnamentTab: CatalogHomeView.OrnamentTab = .catalog
    @State private var showHomeLauncher: Bool = false
    @State private var showControlCenter: Bool = false
    @State private var showScanner: Bool = false
    @State private var showBentoRoom: Bool = false
    @State private var showDuoFoldShowcase: Bool = false

    // 3D Room Parallax Camera State (Drag / Gyroscope Pan & Glide)
    @State private var roomYaw: CGFloat = 0
    @State private var roomPitch: CGFloat = 0
    @State private var windowOffset: CGSize = .zero

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - 1. 3D Spatial Room Environment Backdrop (custom_room_bg.png + 6 Environments + Live Camera AR World)
                spatialRoomBackdrop(size: geo.size)

                // MARK: - 2. Main Spatial Window OR Home Honeycomb Launcher
                VStack(spacing: 0) {
                    // Top Quiet visionOS Shell Controls (Alqami Logo, Home Grid Button, Time + Control Center Pill, Spatial Mode Pill)
                    topQuietShellBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                    if showHomeLauncher {
                        HomeHoneycombLauncherView(
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
                    } else {
                        // Floating Frosted Glass Window + Left Vertical Ornament + Bottom Grab Bar
                        spatialFloatingWindow(size: geo.size)
                            .offset(windowOffset)
                    }

                    Spacer(minLength: 4)

                    // Bottom Window Grab Bar + Bottom-Right Creator Credit Pill
                    bottomWindowChromeAndCreatorCredit
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }

                // MARK: - 3. 3-Panel Control Center Overlay
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
        // ARKit 3D Object Scanner & Linked Data RDF Studio
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

    // MARK: - 1. Spatial Room Backdrop (custom_room_bg.png + Environments + Camera Passthrough)
    private func spatialRoomBackdrop(size: CGSize) -> some View {
        ZStack {
            if lighting.isSpatialWorldAR {
                // Live Camera Passthrough Backdrop
                CameraLivePreviewRepresentable()
                    .ignoresSafeArea()
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
            } else {
                // Base Environment Gradient
                LinearGradient(
                    colors: lighting.environment.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Real Room Background Image (custom_room_bg.png) when in Living Room environment
                if lighting.environment == .livingRoom,
                   let roomImg = BundleImageLoader.uiImage(named: "custom_room_bg.png") {
                    Image(uiImage: roomImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width * 1.16, height: size.height * 1.16)
                        .offset(x: roomYaw, y: roomPitch)
                        .clipped()
                        .ignoresSafeArea()
                }

                // Ambient Vignette & Lighting Tint Overlay
                RadialGradient(
                    colors: [
                        Color.black.opacity(0.18),
                        Color.black.opacity(0.56)
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
                    roomYaw = max(-45, min(45, value.translation.width * 0.18))
                    roomPitch = max(-25, min(25, value.translation.height * 0.12))
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        roomYaw = 0
                        roomPitch = 0
                    }
                }
        )
    }

    // MARK: - 2. Top Quiet visionOS Shell Controls (screenshot-view1.png)
    private var topQuietShellBar: some View {
        HStack(spacing: 8) {
            // 1. Round Alqami Logo Button (Toggles Spatial AR World Passthrough)
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring()) {
                    lighting.isSpatialWorldAR.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(lighting.isSpatialWorldAR
                              ? Color(red: 1.0, green: 0.839, blue: 0.039)
                              : Color.black.opacity(0.38))
                        .frame(width: 34, height: 34)
                        .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1))

                    if let logo = BundleImageLoader.uiImage(named: "logo.png") {
                        Image(uiImage: logo)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(lighting.isSpatialWorldAR ? .black : .white)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } else {
                        Text("ع")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(lighting.isSpatialWorldAR ? .black : .white)
                    }
                }
            }

            // 2. Round Home View Grid Button (Opens 13-App Honeycomb Launcher)
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                    showHomeLauncher.toggle()
                }
            }) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .fill(showHomeLauncher ? Color.white.opacity(0.28) : Color.black.opacity(0.35))
                    )
                    .overlay(Circle().stroke(Color.white.opacity(0.20), lineWidth: 1))
            }

            // 3. Time + Chevron Pill (Opens 3-Panel Control Center)
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showControlCenter.toggle()
                }
            }) {
                HStack(spacing: 5) {
                    Text(currentClockLabel())
                        .font(.system(size: 11.5, weight: .semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .opacity(0.7)
                }
                .foregroundColor(.white.opacity(0.92))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(showControlCenter ? Color.white.opacity(0.26) : Color.black.opacity(0.35))
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
            }

            Spacer()

            // 4. Right Mode Switcher Pill ("Spatial v" / Duo-Fold / Scanner / AR)
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
                    Label("Duo-Fold 3D Showcase • العرض المزدوج", systemImage: "book.pages")
                }
                Button(action: {
                    showScanner = true
                }) {
                    Label("ARKit 3D Scanner & RDF • الماسح الدلالي", systemImage: "qrcode.viewfinder")
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
                        .font(.system(size: 11.5, weight: .semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .opacity(0.7)
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color.black.opacity(0.35)))
                .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - 3. Floating Frosted Glass Window + Left Vertical Ornament (SpatialWindow.tsx)
    private func spatialFloatingWindow(size: CGSize) -> some View {
        let isWide = size.width > 640
        return HStack(spacing: 12) {
            // Left Vertical Floating Glass Ornament (5 Icons: Grid, Search, User, Favorites with #FFD60A dot, Bag)
            if isWide {
                leftVerticalOrnamentPill
            }

            // Main Frosted Glass Window Container
            ZStack {
                RoundedRectangle(cornerRadius: 34)
                    .fill(Color(red: 0.11, green: 0.12, blue: 0.14).opacity(0.76))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34))

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
                    .clipShape(RoundedRectangle(cornerRadius: 34))
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
                    .clipShape(RoundedRectangle(cornerRadius: 34))
                    .environment(\.layoutDirection, catalogViewModel.isArabic ? .rightToLeft : .leftToRight)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 34)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.48), radius: 28, x: 0, y: 16)
        }
        .padding(.horizontal, isWide ? 18 : 10)
        .overlay(alignment: .bottom) {
            if !isWide {
                compactBottomOrnamentPill
                    .offset(y: -12)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - Left Vertical Ornament Pill (5 Buttons from AlqamiSpatialApp.tsx)
    private var leftVerticalOrnamentPill: some View {
        VStack(spacing: 10) {
            ornamentIconButton(tab: .catalog, icon: "square.grid.2x2", badgeDot: false)
            ornamentIconButton(tab: .search, icon: "magnifyingglass", badgeDot: false)
            ornamentIconButton(tab: .about, icon: "person", badgeDot: false)
            ornamentIconButton(tab: .favorites, icon: "heart", badgeDot: !catalogViewModel.favoriteIds.isEmpty)
            ornamentIconButton(tab: .bag, icon: "bag", badgeDot: false)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.38))
                .background(.ultraThinMaterial, in: Capsule())
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.20), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 8)
    }

    private var compactBottomOrnamentPill: some View {
        HStack(spacing: 12) {
            ornamentIconButton(tab: .catalog, icon: "square.grid.2x2", badgeDot: false)
            ornamentIconButton(tab: .search, icon: "magnifyingglass", badgeDot: false)
            ornamentIconButton(tab: .about, icon: "person", badgeDot: false)
            ornamentIconButton(tab: .favorites, icon: "heart", badgeDot: !catalogViewModel.favoriteIds.isEmpty)
            ornamentIconButton(tab: .bag, icon: "bag", badgeDot: false)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.65))
                .background(.ultraThinMaterial, in: Capsule())
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
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
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.62))
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.white.opacity(0.22) : Color.clear)
                    )

                if badgeDot {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.839, blue: 0.039)) // #FFD60A
                        .frame(width: 7, height: 7)
                        .offset(x: -5, y: 5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. Bottom visionOS Window Grab Bar + Creator Credit Pill
    private var bottomWindowChromeAndCreatorCredit: some View {
        HStack {
            Spacer()

            // Center visionOS Window Close Dot + Grab Bar Handle
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.white.opacity(0.38))
                    .frame(width: 9, height: 9)
                    .onTapGesture {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring()) {
                            selectedArtifactForDetail = nil
                            windowOffset = .zero
                        }
                    }

                Capsule()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 120, height: 5)
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

            // Bottom-Right Subtle Creator Credit Pill ("designed & developed by isaac faleh · تصميم و تطوير اسحاق فالح")
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                selectedArtifactForDetail = nil
                activeOrnamentTab = .about
            }) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .frame(width: 6, height: 6)
                    Text("designed & developed by isaac faleh · تصميم و تطوير اسحاق فالح")
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.black.opacity(0.35)))
                .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func handleLaunchApp(_ appId: String) {
        SpatialSoundHelper.shared.playSnapHaptic()
        showHomeLauncher = false
        switch appId {
        case "arkit-scanner":
            showScanner = true
        case "ar-anchors":
            activeARArtifact = catalogViewModel.heroArtifact
        case "studio", "quicklook":
            showDuoFoldShowcase = true
        case "photos":
            showBentoRoom = true
        default:
            selectedArtifactForDetail = nil
            activeOrnamentTab = .catalog
        }
    }

    private func currentClockLabel() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}

// MARK: - 13-App Honeycomb Spatial Launcher (Exact 1:1 HomeViewLauncher.tsx)
public struct HomeHoneycombLauncherView: View {
    public var onOpenApp: (String) -> Void

    private struct SpatialAppItem: Identifiable {
        let id: String
        let name: String
        let subtitle: String
        let icon: String
        let colors: [Color]
        let badge: String?
    }

    private let row1: [SpatialAppItem] = [
        SpatialAppItem(id: "tools100", name: "100 Tools Hub", subtitle: "Complete Spatial Suite", icon: "sparkles", colors: [.orange, .pink], badge: "100"),
        SpatialAppItem(id: "siri", name: "Siri", subtitle: "Voice Assistant", icon: "mic.fill", colors: [.purple, .blue], badge: nil),
        SpatialAppItem(id: "photos", name: "Photos & Memories", subtitle: "Spatial Gallery", icon: "photo.on.rectangle.angled", colors: [.pink, .yellow], badge: nil),
        SpatialAppItem(id: "airdraw", name: "Air Canvas", subtitle: "3D Brush & Paint", icon: "paintbrush.pointed.fill", colors: [.pink, .indigo], badge: nil),
        SpatialAppItem(id: "globe", name: "Planet Earth", subtitle: "Interactive 3D Globe", icon: "globe.americas.fill", colors: [.blue, .green], badge: nil)
    ]

    private let row2: [SpatialAppItem] = [
        SpatialAppItem(id: "arkit-scanner", name: "ARKit 3D Scanner", subtitle: "Bounding Box & RDF", icon: "qrcode.viewfinder", colors: [.yellow, .orange], badge: "RDF"),
        SpatialAppItem(id: "playground", name: "Image Playground", subtitle: "Generative Studio", icon: "wand.and.stars", colors: [.purple, .pink], badge: nil),
        SpatialAppItem(id: "safari", name: "Safari", subtitle: "Spatial Web Browser", icon: "safari.fill", colors: [.cyan, .blue], badge: nil),
        SpatialAppItem(id: "notes", name: "Notes", subtitle: "Spatial Workspace", icon: "note.text", colors: [.yellow, .orange], badge: nil),
        SpatialAppItem(id: "alqami", name: "Alqami Heritage", subtitle: "3D Museum & AR", icon: "building.columns.fill", colors: [.indigo, .blue], badge: "3D"),
        SpatialAppItem(id: "studio", name: "3D Studio & PBR", subtitle: "Duo-Fold Inspector", icon: "cube.transparent.fill", colors: [.purple, .indigo], badge: nil)
    ]

    private let row3: [SpatialAppItem] = [
        SpatialAppItem(id: "spotlight", name: "Spotlight", subtitle: "Universal Search", icon: "magnifyingglass", colors: [.gray, .black], badge: nil),
        SpatialAppItem(id: "messages", name: "Messages", subtitle: "Spatial Personas", icon: "message.fill", colors: [.green, .mint], badge: "4"),
        SpatialAppItem(id: "ar-anchors", name: "AR Anchors", subtitle: "Room Raycast Pinning", icon: "arkit", colors: [.teal, .green], badge: nil),
        SpatialAppItem(id: "mac-display", name: "Mac Virtual Display", subtitle: "4K Curved Monitor", icon: "desktopcomputer", colors: [.blue, .indigo], badge: nil),
        SpatialAppItem(id: "quicklook", name: "Quick Look", subtitle: "USDZ / GLB Viewer", icon: "eye.fill", colors: [.orange, .brown], badge: nil)
    ]

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("visionOS Spatial Home • القائمة الرئيسية")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.top, 8)

                // Row 1
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 22) {
                        ForEach(row1) { app in
                            honeycombAppIcon(app)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Row 2 (Staggered Center Row)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 22) {
                        ForEach(row2) { app in
                            honeycombAppIcon(app)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Row 3
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 22) {
                        ForEach(row3) { app in
                            honeycombAppIcon(app)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 20)
        }
    }

    private func honeycombAppIcon(_ app: SpatialAppItem) -> some View {
        Button(action: {
            onOpenApp(app.id)
        }) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: app.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1.5))
                        .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 8)

                    Image(systemName: app.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 72, height: 72)

                    if let badge = app.badge {
                        Text(badge)
                            .font(.system(size: 9.5, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.red))
                            .offset(x: 4, y: -2)
                    }
                }

                Text(app.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(app.subtitle)
                    .font(.system(size: 9.5))
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(1)
            }
            .frame(width: 98)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Duo-Fold 3D Mechanical Book/Door Carousel Showcase (AlqamiDuoFoldShowcase.tsx)
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
        ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(Color(red: 0.08, green: 0.09, blue: 0.12).opacity(0.88))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34))

            VStack(spacing: 16) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "book.pages.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        Text("DUO-FOLD 3D SPATIAL SHOWCASE • العرض المطوي ثلاثي الأبعاد")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                }

                // 2-Leaf Hinged 3D Book Layout
                HStack(spacing: 4) {
                    // Left Leaf: 3D Interactive USDZ Turntable
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.796, green: 0.788, blue: 0.773)) // #CBC9C5

                        Artifact3DTurntableSceneView(
                            artifact: current,
                            autoRotate: true,
                            allowsCameraControl: true,
                            cameraDistance: 0.65
                        )
                    }
                    .rotation3DEffect(.degrees(foldRotation), axis: (x: 0, y: 1, z: 0), anchor: .trailing)

                    // Right Leaf: Manuscript Calligraphic Spec Leaf
                    VStack(alignment: .leading, spacing: 12) {
                        Text(current.itemCode)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))

                        Text(current.title.text(isArabic: isArabic))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text(current.subtitle.text(isArabic: isArabic))
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.65))

                        Text(current.description.text(isArabic: isArabic))
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.82))
                            .lineLimit(4)

                        Spacer()

                        HStack(spacing: 10) {
                            Button(action: { onLaunchAR(current) }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arkit")
                                    Text("معاينة في المكان (AR)")
                                }
                                .font(.system(size: 12.5, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                            }

                            Button(action: { onSelectArtifact(current) }) {
                                Text("التفاصيل الكاملة")
                                    .font(.system(size: 12.5, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color.white.opacity(0.12)))
                            }
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.06)))
                    .rotation3DEffect(.degrees(-foldRotation), axis: (x: 0, y: 1, z: 0), anchor: .leading)
                }

                // Bottom Prev/Next Controls
                HStack(spacing: 16) {
                    Button(action: { flipPage(delta: -1) }) {
                        Label("السابق", systemImage: "chevron.left")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white.opacity(0.12)))
                    }

                    Text("\(currentIndex + 1) / \(artifacts.count)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))

                    Button(action: { flipPage(delta: 1) }) {
                        Label("التالي", systemImage: "chevron.right")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white.opacity(0.12)))
                    }
                }
            }
            .padding(22)
        }
        .padding(.horizontal, 18)
    }

    private func flipPage(delta: Int) {
        SpatialSoundHelper.shared.playSnapHaptic()
        withAnimation(.easeInOut(duration: 0.2)) {
            foldRotation = 38
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            currentIndex = (currentIndex + delta + artifacts.count) % artifacts.count
            withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                foldRotation = 0
            }
        }
    }
}
