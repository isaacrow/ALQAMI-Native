import SwiftUI

// MARK: - Exact ALQAMI 6 Catalog & Spatial Window View with Apple Glossy Glass & Responsive Proportions
public struct CatalogHomeView: View {
    @ObservedObject public var viewModel: CatalogViewModel
    public var activeOrnamentTab: OrnamentTab
    public var onSelectArtifact: (Artifact) -> Void
    public var onLaunchAR: (Artifact) -> Void

    @State private var activePopOutCallout: Int = 0

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

    public var body: some View {
        GeometryReader { outerGeo in
            let isWide = outerGeo.size.width > 640
            let columns: [GridItem] = isWide
                ? [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
                : [GridItem(.flexible(), spacing: 11), GridItem(.flexible(), spacing: 11)]

            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
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
                            // 1. Royal Blue Glossy Glass Hero Banner (#124091 -> #1c56b8 -> #0f3478)
                            royalBlueHeroBanner(isWide: isWide)

                            // 2. "استلهم من التراث" Header + Live 3D Toggle + 3D Pop-Out + 8 Glossy Category Chips
                            inspireCatalogHeader

                            // 3. Responsive 2-Column (iPhone) / 3-Column (iPad) Artifacts Grid
                            let displayedArtifacts = activeOrnamentTab == .favorites
                                ? viewModel.artifacts.filter { viewModel.isFavorite($0.id) }
                                : viewModel.filteredArtifacts

                            if displayedArtifacts.isEmpty {
                                emptyCatalogPlaceholder
                            } else {
                                LazyVGrid(columns: columns, spacing: isWide ? 14 : 11) {
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
                                                withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
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
                            fourCellBentoShowcase(isWide: isWide)
                        }
                    }
                    .padding(isWide ? 20 : 14)
                    .padding(.bottom, isWide ? 12 : 54)
                }

                // 5. 3D Volume Pop-Out Overlay (when isPopOut3D == true)
                if viewModel.isPopOut3D {
                    volume3DPopOutOverlay
                }
            }
        }
    }

    // MARK: - 1. Royal Blue Glossy Glass Hero Banner (#124091 -> #1c56b8 -> #0f3478)
    private func royalBlueHeroBanner(isWide: Bool) -> some View {
        let hero = viewModel.heroArtifact
        return ZStack {
            // Exact Royal Blue Linear Gradient
            RoundedRectangle(cornerRadius: 24, style: .continuous)
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

            // Apple Glossy Glass Specular Top Sheen over Royal Blue
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.26), location: 0.0),
                            .init(color: Color.white.opacity(0.06), location: 0.38),
                            .init(color: Color.clear, location: 0.65),
                            .init(color: Color.black.opacity(0.18), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Radial Gold Highlight on Left
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.20), Color.clear],
                center: .topLeading,
                startRadius: 10,
                endRadius: 240
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            if isWide {
                HStack(spacing: 16) {
                    heroTextColumn(hero: hero, isWide: true)
                    Spacer()
                    heroRight3DAndLogoCluster(hero: hero, isWide: true)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .environment(\.layoutDirection, .leftToRight)
            } else {
                // Optimized Proportional Layout for iPhone Portrait
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 10) {
                        heroTextColumn(hero: hero, isWide: false)
                        Spacer(minLength: 4)
                        alqamiLogoTile(size: 68)
                    }

                    // Interactive 3D Hero Turntable + Quick 3D/AR Glossy Pills
                    ZStack(alignment: .bottomTrailing) {
                        Artifact3DTurntableSceneView(
                            artifact: hero,
                            autoRotate: true,
                            allowsCameraControl: true,
                            cameraDistance: 0.66
                        )
                        .frame(height: 132)

                        heroQuickActionPills(hero: hero)
                            .padding(.bottom, 4)
                    }
                }
                .padding(16)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.55), Color.white.opacity(0.12), Color.white.opacity(0.28)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.black.opacity(0.32), radius: 16, x: 0, y: 8)
    }

    private func heroTextColumn(hero: Artifact, isWide: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.isArabic ? "اكتشف المقتنيات النادرة" : "DISCOVER RARE ARTIFACTS")
                .font(.system(size: isWide ? 11.5 : 10.5, weight: .bold))
                .foregroundColor(.white.opacity(0.80))

            Text(viewModel.isArabic ? "استكشف كنوز التراث الإسلامي" : "Explore Islamic Heritage Treasures")
                .font(.system(size: isWide ? 25 : 19, weight: .heavy))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(viewModel.isArabic ? "مقتنيات فريدة، قصص خالدة، حضارة عريقة" : "Unique artifacts, timeless stories, ancient civilization")
                .font(.system(size: isWide ? 13 : 11.5, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
                .padding(.bottom, 4)

            // Glossy Yellow #FFD60A Pill CTA Button ("استكشف المعرض <-")
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                onSelectArtifact(hero)
            }) {
                HStack(spacing: 6) {
                    Text(viewModel.isArabic ? "استكشف المعرض" : "Explore Gallery")
                        .font(.system(size: isWide ? 13 : 12, weight: .bold))
                    Image(systemName: "arrow.left")
                        .font(.system(size: 11.5, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, isWide ? 18 : 14)
                .padding(.vertical, isWide ? 9 : 7)
                .glossyPill(isSelected: true)
            }
            .buttonStyle(.plain)
        }
    }

    private func heroRight3DAndLogoCluster(hero: Artifact, isWide: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack(alignment: .bottom) {
                Artifact3DTurntableSceneView(
                    artifact: hero,
                    autoRotate: true,
                    allowsCameraControl: true,
                    cameraDistance: 0.64
                )
                .frame(width: 200, height: 175)

                heroQuickActionPills(hero: hero)
                    .padding(.bottom, 4)
            }

            alqamiLogoTile(size: 94)
        }
    }

    private func heroQuickActionPills(hero: Artifact) -> some View {
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
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glossyPill()
            }
            .buttonStyle(.plain)

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
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glossyPill(isSelected: true)
            }
            .buttonStyle(.plain)
        }
    }

    private func alqamiLogoTile(size: CGFloat) -> some View {
        Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            viewModel.nextHeroArtifact()
        }) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.19, green: 0.45, blue: 0.86),
                                Color(red: 0.13, green: 0.35, blue: 0.74)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.65), Color.white.opacity(0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.32), radius: 10, x: 0, y: 5)

                if let logoImg = BundleImageLoader.uiImage(named: "logo.png") {
                    Image(uiImage: logoImg)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: size * 0.60, height: size * 0.60)
                        .frame(width: size, height: size)
                } else {
                    Text("علقمي")
                        .font(.system(size: size * 0.24, weight: .black, design: .serif))
                        .foregroundColor(.white)
                        .frame(width: size, height: size)
                }

                // Pulsing Yellow Amber Dot on Top-Right
                Circle()
                    .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                    .frame(width: 11, height: 11)
                    .shadow(color: Color(red: 1.0, green: 0.839, blue: 0.039), radius: 5)
                    .offset(x: 2, y: -2)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 2. "استلهم من التراث" Header + Live 3D Toggle + 8 Glossy Category Chips
    private var inspireCatalogHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(viewModel.isArabic ? "استلهم من التراث" : "Inspired by Heritage")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)

                // Live 3D Toggle Button (Cube Icon)
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    withAnimation { viewModel.live3DCatalog.toggle() }
                }) {
                    Image(systemName: "cube")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(viewModel.live3DCatalog ? .black : .white)
                        .glossyCircle(size: 32, isSelected: viewModel.live3DCatalog)
                }
                .buttonStyle(.plain)

                // 3D Volume Pop-Out Button (Rotate3d Icon)
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    withAnimation(.spring()) { viewModel.isPopOut3D.toggle() }
                }) {
                    Image(systemName: "rotate.3d")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(viewModel.isPopOut3D ? .black : .white)
                        .glossyCircle(size: 32, isSelected: viewModel.isPopOut3D)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(viewModel.filteredArtifacts.count) \(viewModel.isArabic ? "مقتنى" : "items")")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .glossyPill()
            }

            // 8 Glossy Category Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(ArtifactCategory.allCases) { category in
                        let isSelected = viewModel.selectedCategory == category
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.selectedCategory = category
                            }
                        }) {
                            Text(category.title(isArabic: viewModel.isArabic))
                                .font(.system(size: 12, weight: isSelected ? .bold : .semibold))
                                .foregroundColor(isSelected ? .black : .white.opacity(0.88))
                                .padding(.horizontal, 15)
                                .padding(.vertical, 7)
                                .glossyPill(isSelected: isSelected, activeColor: .white)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Search Bar Drawer (Glossy Glass)
    private var searchBarDrawer: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.65))
                .font(.system(size: 14, weight: .semibold))

            TextField(
                viewModel.isArabic ? "ابحث في مقتنيات علقمي التراثية (مخطوط، سيف، خوذة، بابل)..." : "Search Alqami artifacts...",
                text: $viewModel.searchQuery
            )
            .font(.system(size: 13))
            .foregroundColor(.white)

            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .glossyGlass(cornerRadius: 16, tintOpacity: 0.16)
    }

    // MARK: - 4-Cell Room Bento 3D Showcase at Bottom of Catalog
    private func fourCellBentoShowcase(isWide: Bool) -> some View {
        let a0 = viewModel.artifacts[0] // Nahj al-Balagha
        let a1 = viewModel.artifacts[2] // Zulfiqar
        let a2 = viewModel.artifacts[1] // Helmet
        let a3 = viewModel.artifacts[3] // Babylonian Map

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isArabic ? "معرض الغرفة المكانية" : "Spatial Room Bento Showcase")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text(viewModel.isArabic ? "استعراض ثلاثي الأبعاد حي للمقتنيات النادرة" : "Live 3D spatial preview of rare artifacts")
                        .font(.system(size: 11.5))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Text("BENTO 3D")
                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .glossyPill()
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 11), GridItem(.flexible(), spacing: 11)], spacing: 11) {
                bentoCell(
                    artifact: a0,
                    badge: viewModel.isArabic ? "مخطوط نادر" : "MANUSCRIPT"
                )
                bentoCell(
                    artifact: a1,
                    badge: viewModel.isArabic ? "خزانة السلاح" : "ARMORY"
                )
                bentoCell(
                    artifact: a2,
                    badge: viewModel.isArabic ? "دروع الفرسان" : "CAVALRY"
                )
                bentoCell(
                    artifact: a3,
                    badge: viewModel.isArabic ? "بلاد الرافدين" : "MESOPOTAMIA"
                )
            }
        }
        .padding(.top, 8)
    }

    private func bentoCell(artifact: Artifact, badge: String) -> some View {
        ZStack {
            Artifact3DTurntableSceneView(
                artifact: artifact,
                autoRotate: true,
                allowsCameraControl: true,
                cameraDistance: 0.72
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack {
                HStack {
                    Text(badge)
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .glossyPill()

                    Spacer(minLength: 4)

                    Button(action: { onLaunchAR(artifact) }) {
                        Image(systemName: "arkit")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(.black)
                            .glossyCircle(size: 28, isSelected: true)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(artifact.title.text(isArabic: viewModel.isArabic))
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(artifact.period.text(isArabic: viewModel.isArabic))
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.68))
                            .lineLimit(1)
                    }
                    Spacer(minLength: 4)
                    Button(action: { onSelectArtifact(artifact) }) {
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 26, isSelected: false)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
        }
        .frame(height: 175)
        .glossyGlass(cornerRadius: 20, tintOpacity: 0.22)
    }

    // MARK: - 3D Volume Pop-Out Overlay (Glossy Glass)
    private var volume3DPopOutOverlay: some View {
        let hero = viewModel.heroArtifact
        let callouts: [(titleAr: String, descAr: String)] = [
            ("الزخارف والنقوش الأصيلة", hero.decoration?.ar ?? hero.material.ar),
            ("المادة والصناعة التراثية", hero.material.ar),
            ("قاعدة المقتنى والختم الأثري", hero.seals?.ar ?? hero.institution.ar)
        ]

        return ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { viewModel.isPopOut3D = false }
                }

            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .frame(width: 8, height: 8)
                    Text("3D VOLUME • \(hero.title.ar)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .glossyPill()

                ZStack(alignment: .bottom) {
                    Artifact3DTurntableSceneView(
                        artifact: hero,
                        autoRotate: true,
                        allowsCameraControl: true,
                        cameraDistance: 0.60
                    )
                    .frame(height: 260)

                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { idx in
                            Button(action: {
                                SpatialSoundHelper.shared.playSnapHaptic()
                                withAnimation { activePopOutCallout = idx }
                            }) {
                                HStack(spacing: 5) {
                                    Text("\(idx + 1)")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(activePopOutCallout == idx ? .black : .white)
                                        .frame(width: 22, height: 22)
                                        .background(
                                            Circle()
                                                .fill(activePopOutCallout == idx ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.white.opacity(0.18))
                                        )
                                    if activePopOutCallout == idx {
                                        Text(callouts[idx].titleAr)
                                            .font(.system(size: 10.5, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .padding(.trailing, 6)
                                    }
                                }
                                .padding(4)
                                .glossyPill()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 8)
                }

                VStack(spacing: 4) {
                    Text(callouts[activePopOutCallout].titleAr)
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    Text(callouts[activePopOutCallout].descAr)
                        .font(.system(size: 11.5))
                        .foregroundColor(.white.opacity(0.88))
                        .multilineTextAlignment(.center)
                }
                .padding(12)
                .frame(maxWidth: 360)
                .glossyGlass(cornerRadius: 16, tintOpacity: 0.25)

                HStack(spacing: 10) {
                    Button(action: {
                        withAnimation(.spring()) { viewModel.isPopOut3D = false }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "xmark")
                            Text(viewModel.isArabic ? "إغلاق" : "Close")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .glossyPill()
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        viewModel.isPopOut3D = false
                        onLaunchAR(hero)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arkit")
                            Text(viewModel.isArabic ? "معاينة في المكان (AR)" : "Place in AR")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .glossyPill(isSelected: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
            .glossyGlass(cornerRadius: 26, tintOpacity: 0.35)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Creator & Platform About Section (Glossy Glass)
    private var creatorAboutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                if let logo = BundleImageLoader.uiImage(named: "logo.png") {
                    Image(uiImage: logo)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .padding(10)
                        .glossyGlass(cornerRadius: 16)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("منصة علقمي للتراث المكاني • ALQAMI Spatial")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text("designed & developed by isaac faleh · تصميم و تطوير اسحاق فالح")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                }
            }

            Text("منصة متحفية مكانية تفاعلية مبنية بالكامل باستخدام تقنيات Apple RealityKit و ARKit و Raycasting و Vision و Spatial Computing لعرض المخطوطات الإسلامية والآثار التاريخية النادرة في مكانك الحقيقي بدقة ثلاثية الأبعاد 1:1.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
        }
        .padding(18)
        .glossyGlass(cornerRadius: 22, tintOpacity: 0.20)
    }

    // MARK: - Curated Bag / Exhibition Vault Section (Glossy Glass)
    private var bagCuratedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.isArabic ? "حقيبة المقتنيات والمعرض الشخصي" : "Curated Spatial Exhibition Vault")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            ForEach(viewModel.artifacts) { item in
                HStack(spacing: 12) {
                    if let img = BundleImageLoader.uiImage(named: item.imageName) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.796, green: 0.788, blue: 0.773)))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title.text(isArabic: viewModel.isArabic))
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("\(item.itemCode) • \(item.dimensions.formatted(isArabic: viewModel.isArabic))")
                            .font(.system(size: 10.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                    Spacer()
                    Button(action: { onLaunchAR(item) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arkit")
                            Text("AR")
                        }
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .glossyPill(isSelected: true)
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
                .glossyGlass(cornerRadius: 16, tintOpacity: 0.16)
            }
        }
    }

    private var emptyCatalogPlaceholder: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.4))
            Text(viewModel.isArabic ? "لا توجد مقتنيات مطابقة" : "No matching artifacts found")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .glossyGlass(cornerRadius: 20)
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
