import SwiftUI

// MARK: - Exact ALQAMI 6 Catalog & Spatial Window View (AlqamiSpatialApp.tsx)
public struct CatalogHomeView: View {
    @ObservedObject public var viewModel: CatalogViewModel
    public var activeOrnamentTab: OrnamentTab
    public var onSelectArtifact: (Artifact) -> Void
    public var onLaunchAR: (Artifact) -> Void

    @State private var activePopOutCallout: Int = 0
    @State private var selectedBentoHotspot: Int = 0

    public enum OrnamentTab: String, CaseIterable, Identifiable {
        case catalog = "catalog"
        case search = "search"
        case about = "about"
        case favorites = "favorites"
        case bag = "bag"
        public var id: String { rawValue }
    }

    public init(
        viewModel: CatalogViewModel,
        activeOrnamentTab: OrnamentTab = .catalog,
        onSelectArtifact: @escaping (Artifact) -> Void,
        onLaunchAR: @escaping (Artifact) -> Void
    ) {
        self.viewModel = viewModel
        self.activeOrnamentTab = activeOrnamentTab
        self.onSelectArtifact = onSelectArtifact
        self.onLaunchAR = onLaunchAR
    }

    private let gridColumns = [
        GridItem(.adaptive(minimum: 220, maximum: 320), spacing: 18)
    ]

    public var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    // Search Bar Drawer (when Search Ornament is active)
                    if activeOrnamentTab == .search {
                        searchBarDrawer
                    }

                    // Creator / About Card (when User Ornament is active)
                    if activeOrnamentTab == .about {
                        creatorAboutSection
                    } else if activeOrnamentTab == .bag {
                        bagCuratedSection
                    } else {
                        // 1. Exact Royal Blue Hero Banner (#124091 -> #1c56b8 -> #0f3478)
                        royalBlueHeroBanner

                        // 2. "استلهم من التراث" Header + Live 3D Toggle + 3D Pop-Out + 8 Category Chips
                        inspireCatalogHeader

                        // 3. Artifacts Grid (Filtered or Favorites)
                        let displayedArtifacts = activeOrnamentTab == .favorites
                            ? viewModel.artifacts.filter { viewModel.isFavorite($0.id) }
                            : viewModel.filteredArtifacts

                        if displayedArtifacts.isEmpty {
                            emptyCatalogPlaceholder
                        } else {
                            LazyVGrid(columns: gridColumns, spacing: 18) {
                                ForEach(displayedArtifacts) { artifact in
                                    ArtifactCardView(
                                        artifact: artifact,
                                        isArabic: viewModel.isArabic,
                                        live3D: viewModel.live3DCatalog,
                                        isFavorite: viewModel.isFavorite(artifact.id),
                                        onToggleFavorite: {
                                            viewModel.toggleFavorite(artifact.id)
                                        },
                                        onPopOut3D: {
                                            if let idx = viewModel.artifacts.firstIndex(where: { $0.id == artifact.id }) {
                                                viewModel.heroArtifactIndex = idx
                                            }
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                                                viewModel.isPopOut3D = true
                                            }
                                        },
                                        onSelect: {
                                            onSelectArtifact(artifact)
                                        },
                                        onLaunchAR: {
                                            onLaunchAR(artifact)
                                        }
                                    )
                                }
                            }
                        }

                        // 4. 4-Cell Room Bento 3D Showcase at Bottom of Catalog
                        fourCellBentoShowcase
                    }
                }
                .padding(24)
            }

            // 5. 3D Volume Pop-Out Overlay (when isPopOut3D == true)
            if viewModel.isPopOut3D {
                volume3DPopOutOverlay
            }
        }
    }

    // MARK: - 1. Exact Royal Blue Hero Banner (#124091 -> #1c56b8 -> #0f3478)
    private var royalBlueHeroBanner: some View {
        let hero = viewModel.heroArtifact
        return ZStack {
            // Exact Royal Blue Linear Gradient
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.071, green: 0.251, blue: 0.569), // #124091
                            Color(red: 0.110, green: 0.337, blue: 0.722), // #1c56b8
                            Color(red: 0.059, green: 0.204, blue: 0.471)  // #0f3478
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Radial Gold Highlight on Left
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.22), Color.clear],
                center: .topLeading,
                startRadius: 10,
                endRadius: 280
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))

            // Hero Content: Text & Yellow Pill on Left, Live 3D Model + #2764c9 Logo Tile on Right
            GeometryReader { geo in
                let isWide = geo.size.width > 560
                if isWide {
                    HStack(spacing: 16) {
                        heroTextColumn(hero: hero)
                            .frame(maxWidth: geo.size.width * 0.48, alignment: .leading)

                        Spacer()

                        heroRight3DAndLogoCluster(hero: hero)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 22)
                    .environment(\.layoutDirection, .leftToRight)
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            heroTextColumn(hero: hero)
                            Spacer()
                            alqamiLogoTile
                        }
                        Artifact3DTurntableSceneView(
                            artifact: hero,
                            autoRotate: true,
                            allowsCameraControl: true,
                            cameraDistance: 0.65
                        )
                        .frame(height: 150)
                    }
                    .padding(20)
                }
            }
        }
        .frame(minHeight: 245)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.32), radius: 18, x: 0, y: 10)
    }

    private func heroTextColumn(hero: Artifact) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.isArabic ? "اكتشف المقتنيات النادرة" : "DISCOVER RARE ARTIFACTS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.75))

            Text(viewModel.isArabic ? "استكشف كنوز التراث الإسلامي" : "Explore Islamic Heritage Treasures")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Text(viewModel.isArabic ? "مقتنيات فريدة، قصص خالدة، حضارة عريقة" : "Unique artifacts, timeless stories, ancient civilization")
                .font(.system(size: 13.5, weight: .medium))
                .foregroundColor(.white.opacity(0.82))
                .padding(.bottom, 6)

            // Yellow #FFD60A Pill CTA Button ("استكشف المعرض <-")
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                onSelectArtifact(hero)
            }) {
                HStack(spacing: 8) {
                    Text(viewModel.isArabic ? "استكشف المعرض" : "Explore Gallery")
                        .font(.system(size: 13.5, weight: .bold))
                    Image(systemName: "arrow.left")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 22)
                .padding(.vertical, 11)
                .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039))) // #FFD60A
                .shadow(color: Color.black.opacity(0.28), radius: 10, x: 0, y: 5)
            }
        }
    }

    private func heroRight3DAndLogoCluster(hero: Artifact) -> some View {
        HStack(spacing: 16) {
            // Live Rotating 3D USDZ Model in Hero Banner
            ZStack(alignment: .bottom) {
                Artifact3DTurntableSceneView(
                    artifact: hero,
                    autoRotate: true,
                    allowsCameraControl: true,
                    cameraDistance: 0.64
                )
                .frame(width: 220, height: 200)

                // Quick Pop-Out & AR Pills
                HStack(spacing: 6) {
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring()) { viewModel.isPopOut3D = true }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "rotate.3d")
                                .font(.system(size: 10, weight: .bold))
                            Text("3D")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.42)))
                    }

                    Button(action: {
                        onLaunchAR(hero)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arkit")
                                .font(.system(size: 10, weight: .bold))
                            Text("AR")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                    }
                }
                .padding(.bottom, 4)
            }

            // #2764c9 Rounded Square Alqami Logo Tile with Pulsing Yellow Orb
            alqamiLogoTile
        }
    }

    private var alqamiLogoTile: some View {
        Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            viewModel.nextHeroArtifact()
        }) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.153, green: 0.392, blue: 0.788)) // #2764c9
                    .frame(width: 112, height: 112)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 8)

                if let logoImg = BundleImageLoader.uiImage(named: "logo.png") {
                    Image(uiImage: logoImg)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: 68, height: 68)
                        .frame(width: 112, height: 112)
                } else {
                    Text("علقمي")
                        .font(.system(size: 24, weight: .black, design: .serif))
                        .foregroundColor(.white)
                        .frame(width: 112, height: 112)
                }

                // Pulsing Yellow Amber Dot on Top-Right
                Circle()
                    .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                    .frame(width: 14, height: 14)
                    .shadow(color: Color(red: 1.0, green: 0.839, blue: 0.039), radius: 6)
                    .offset(x: 3, y: -3)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 2. "استلهم من التراث" Header + Live 3D Toggle + 8 Category Chips
    private var inspireCatalogHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 10) {
                    Text(viewModel.isArabic ? "استلهم من التراث" : "Inspired by Heritage")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    // Live 3D Toggle Button (Box Icon)
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation { viewModel.live3DCatalog.toggle() }
                    }) {
                        Image(systemName: "cube")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(viewModel.live3DCatalog ? .black : .white.opacity(0.75))
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(viewModel.live3DCatalog ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.white.opacity(0.10))
                            )
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }

                    // 3D Volume Pop-Out Button (Rotate3d Icon)
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring()) { viewModel.isPopOut3D.toggle() }
                    }) {
                        Image(systemName: "rotate.3d")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(viewModel.isPopOut3D ? .black : .white.opacity(0.75))
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(viewModel.isPopOut3D ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.white.opacity(0.10))
                            )
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                }

                Spacer()
            }

            // 8 Category Chips (Active chip is solid WHITE with black bold text, matching screenshot-view1.png)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ArtifactCategory.allCases) { category in
                        let isSelected = viewModel.selectedCategory == category
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.selectedCategory = category
                            }
                        }) {
                            Text(category.title(isArabic: viewModel.isArabic))
                                .font(.system(size: 12.5, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .black : .white.opacity(0.80))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color.white : Color.white.opacity(0.08))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(isSelected ? Color.white : Color.white.opacity(0.14), lineWidth: 1)
                                )
                                .shadow(color: isSelected ? Color.black.opacity(0.2) : Color.clear, radius: 6, x: 0, y: 3)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Search Bar Drawer
    private var searchBarDrawer: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 14))

            TextField(
                viewModel.isArabic ? "ابحث في مقتنيات علقمي التراثية (مخطوط، سيف، خوذة، بابل)..." : "Search Alqami artifacts...",
                text: $viewModel.searchQuery
            )
            .font(.system(size: 13.5))
            .foregroundColor(.white)

            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.18), lineWidth: 1))
    }

    // MARK: - 4-Cell Room Bento 3D Showcase at Bottom of Catalog
    private var fourCellBentoShowcase: some View {
        let a0 = viewModel.artifacts[0] // Nahj al-Balagha
        let a1 = viewModel.artifacts[2] // Zulfiqar
        let a2 = viewModel.artifacts[1] // Helmet
        let a3 = viewModel.artifacts[3] // Babylonian Map

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.isArabic ? "معرض الغرفة المكانية" : "Spatial Room Bento Showcase")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text(viewModel.isArabic ? "اضغط على النقاط التفاعلية لاستعراض المقتنيات في مساحتك الخاصة" : "Tap interactive hotspots to inspect artifacts in your space")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
                Text("BENTO 3D SHOWCASE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            }

            // 2x2 Bento Grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                bentoCell(
                    artifact: a0,
                    badge: "FEATURED MANUSCRIPT • مخطوط نادر",
                    bgColors: [Color(red: 0.16, green: 0.14, blue: 0.12), Color(red: 0.09, green: 0.08, blue: 0.07)]
                )
                bentoCell(
                    artifact: a1,
                    badge: "ROYAL ARMORY • خزانة السلاح",
                    bgColors: [Color(red: 0.11, green: 0.14, blue: 0.21), Color(red: 0.06, green: 0.08, blue: 0.13)]
                )
                bentoCell(
                    artifact: a2,
                    badge: "OTTOMAN CAVALRY • دروع الفرسان",
                    bgColors: [Color(red: 0.15, green: 0.12, blue: 0.10), Color(red: 0.08, green: 0.06, blue: 0.05)]
                )
                bentoCell(
                    artifact: a3,
                    badge: "MESOPOTAMIA • بلاد الرافدين",
                    bgColors: [Color(red: 0.12, green: 0.15, blue: 0.13), Color(red: 0.06, green: 0.08, blue: 0.07)]
                )
            }
        }
        .padding(.top, 12)
    }

    private func bentoCell(artifact: Artifact, badge: String, bgColors: [Color]) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: bgColors, startPoint: .topLeading, endPoint: .bottomTrailing))

            Artifact3DTurntableSceneView(
                artifact: artifact,
                autoRotate: true,
                allowsCameraControl: true,
                cameraDistance: 0.70
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))

            VStack {
                HStack {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.45)))

                    Spacer()

                    Button(action: { onLaunchAR(artifact) }) {
                        Image(systemName: "arkit")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                    }
                }
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(artifact.title.text(isArabic: viewModel.isArabic))
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(artifact.period.text(isArabic: viewModel.isArabic))
                            .font(.system(size: 10.5))
                            .foregroundColor(.white.opacity(0.65))
                            .lineLimit(1)
                    }
                    Spacer()
                    Button(action: { onSelectArtifact(artifact) }) {
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.white.opacity(0.16)))
                    }
                }
            }
            .padding(14)
        }
        .frame(height: 215)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.14), lineWidth: 1))
    }

    // MARK: - 3D Volume Pop-Out Overlay (isPopOut3D)
    private var volume3DPopOutOverlay: some View {
        let hero = viewModel.heroArtifact
        let callouts: [(titleAr: String, descAr: String)] = [
            ("الزخارف والنقوش الأصيلة", hero.decoration?.ar ?? hero.material.ar),
            ("المادة والصناعة التراثية", hero.material.ar),
            ("قاعدة المقتنى والختم الأثري", hero.seals?.ar ?? hero.institution.ar)
        ]

        return ZStack {
            Color.black.opacity(0.76)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { viewModel.isPopOut3D = false }
                }

            VStack(spacing: 16) {
                // Top Floating Pill
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .frame(width: 8, height: 8)
                    Text("3D VOLUME POP-OUT • \(hero.title.ar)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.black.opacity(0.65)))
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))

                // Interactive 3D Model Volume
                ZStack {
                    Artifact3DTurntableSceneView(
                        artifact: hero,
                        autoRotate: true,
                        allowsCameraControl: true,
                        cameraDistance: 0.58
                    )
                    .frame(height: 330)

                    // Interactive Feature Callout Dots
                    HStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { idx in
                            Button(action: {
                                SpatialSoundHelper.shared.playSnapHaptic()
                                withAnimation { activePopOutCallout = idx }
                            }) {
                                HStack(spacing: 6) {
                                    Text("\(idx + 1)")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(activePopOutCallout == idx ? .black : .white)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            Circle()
                                                .fill(activePopOutCallout == idx ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.black.opacity(0.6))
                                        )
                                    if activePopOutCallout == idx {
                                        Text(callouts[idx].titleAr)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.trailing, 8)
                                    }
                                }
                                .padding(4)
                                .background(Capsule().fill(Color.black.opacity(0.65)))
                                .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                            }
                        }
                    }
                    .offset(y: 135)
                }

                // Active Callout Description Card
                VStack(spacing: 4) {
                    Text(callouts[activePopOutCallout].titleAr)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    Text(callouts[activePopOutCallout].descAr)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding(14)
                .frame(maxWidth: 420)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.16), lineWidth: 1))

                // Close / Launch AR Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring()) { viewModel.isPopOut3D = false }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                            Text(viewModel.isArabic ? "إغلاق المعاينة / Close preview" : "Close preview")
                        }
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.black.opacity(0.65)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    }

                    Button(action: {
                        viewModel.isPopOut3D = false
                        onLaunchAR(hero)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arkit")
                            Text(viewModel.isArabic ? "معاينة في المكان (AR)" : "Place in Room AR")
                        }
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Creator & Platform About Section (User Ornament Tab)
    private var creatorAboutSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 16) {
                if let logo = BundleImageLoader.uiImage(named: "logo.png") {
                    Image(uiImage: logo)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .scaledToFit()
                        .frame(width: 54, height: 54)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.08)))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("منصة علقمي للتراث المكاني • ALQAMI Spatial")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("designed & developed by isaac faleh · تصميم و تطوير اسحاق فالح")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                }
            }

            Text("منصة متحفية مكانية تفاعلية مبنية بالكامل باستخدام تقنيات Apple RealityKit و ARKit و Raycasting و Spatial Computing لعرض المخطوطات الإسلامية والآثار التاريخية النادرة في مكانك الحقيقي بدقة ثلاثية الأبعاد 1:1.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.82))
                .lineSpacing(5)
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 26).fill(Color.white.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.white.opacity(0.16), lineWidth: 1))
    }

    // MARK: - Curated Bag / Exhibition Vault Section
    private var bagCuratedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.isArabic ? "حقيبة المقتنيات والمعرض الشخصي" : "Curated Spatial Exhibition Vault")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            ForEach(viewModel.artifacts.prefix(4)) { item in
                HStack(spacing: 14) {
                    if let img = BundleImageLoader.uiImage(named: item.imageName) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.796, green: 0.788, blue: 0.773)))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title.text(isArabic: viewModel.isArabic))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(item.itemCode)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    Spacer()
                    Button(action: { onLaunchAR(item) }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arkit")
                            Text("AR")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.07)))
            }
        }
    }

    private var emptyCatalogPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "Sparkles")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.35))
            Text(viewModel.isArabic ? "لا توجد مقتنيات مطابقة" : "No matching artifacts found")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - AR Container View
public struct ARContainerView: View {
    public let artifact: Artifact
    public var onDismiss: () -> Void
    @StateObject private var arViewModel: ARViewModel

    public init(artifact: Artifact, onDismiss: @escaping () -> Void) {
        self.artifact = artifact
        self.onDismiss = onDismiss
        _arViewModel = StateObject(wrappedValue: ARViewModel(artifact: artifact))
    }

    public var body: some View {
        ZStack {
            RealityKitARView(viewModel: arViewModel)
                .ignoresSafeArea()

            ARControlOverlay(viewModel: arViewModel, onDismiss: onDismiss)
        }
    }
}
