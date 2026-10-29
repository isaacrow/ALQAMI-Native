import SwiftUI

// MARK: - Exact ALQAMI 6 Catalog & Spatial Experience (Full Edge-to-Edge iPhone 15 Pro Max Layout)
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
            let isWide = outerGeo.size.width > 680
            let columns: [GridItem] = isWide
                ? [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
                : [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Search Bar Drawer (when Search tab is active)
                    if activeOrnamentTab == .search {
                        searchBarDrawer
                    }

                    // Creator / About Section
                    if activeOrnamentTab == .about {
                        creatorAboutSection
                    } else if activeOrnamentTab == .bag {
                        bagCuratedSection
                    } else {
                        // 1. Royal Blue Liquid Glass Hero Banner (Zero Text Truncation, Contained 3D Model)
                        royalBlueHeroBanner(isWide: isWide)

                        // 2. "استلهم من التراث" Header + Live 3D Toggle + 8 Category Pills
                        inspireCatalogHeader

                        // 3. Responsive Artifacts Grid (Filtered or Favorites)
                        let displayedArtifacts = activeOrnamentTab == .favorites
                            ? viewModel.artifacts.filter { viewModel.isFavorite($0.id) }
                            : viewModel.filteredArtifacts

                        if displayedArtifacts.isEmpty {
                            emptyCatalogPlaceholder
                        } else {
                            LazyVGrid(columns: columns, spacing: 14) {
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

                        // 4. 4-Cell Room Bento 3D Showcase
                        fourCellBentoShowcase
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 96) // Extra padding so content never gets covered by floating dock
            }

            // 5. 3D Volume Pop-Out Modal
            if viewModel.isPopOut3D {
                volume3DPopOutOverlay
            }
        }
    }

    // MARK: - 1. Royal Blue Liquid Glass Hero Banner
    private func royalBlueHeroBanner(isWide: Bool) -> some View {
        let hero = viewModel.heroArtifact
        return ZStack {
            // Royal Blue Gradient Base
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.28, blue: 0.64), // #1447a3
                            Color(red: 0.12, green: 0.38, blue: 0.80), // #1e61cc
                            Color(red: 0.06, green: 0.22, blue: 0.52)  // #0f3885
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Liquid Glass Top Sheen
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.32), location: 0.0),
                            .init(color: Color.white.opacity(0.08), location: 0.32),
                            .init(color: Color.clear, location: 0.65),
                            .init(color: Color.black.opacity(0.20), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Subtle Gold Ambient Flare
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.25), Color.clear],
                center: .topLeading,
                startRadius: 10,
                endRadius: 260
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            // Hero Content
            VStack(alignment: .leading, spacing: 14) {
                // Top Row: Alqami Emblem + Live 3D/AR Badges
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        if let logoImg = BundleImageLoader.uiImage(named: "logo.png") {
                            Image(uiImage: logoImg)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        Text(viewModel.isArabic ? "مقتنى الأسبوع المميّز" : "FEATURED ARTIFACT")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.black.opacity(0.35)))

                    Spacer()

                    // Quick Switch Button
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        viewModel.nextHeroArtifact()
                    }) {
                        HStack(spacing: 4) {
                            Text(hero.itemCode)
                                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .glossyPill()
                    }
                    .buttonStyle(.plain)
                }

                // Titles & Description (NEVER truncated)
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.isArabic ? "استكشف كنوز التراث الإسلامي" : "Explore Islamic Heritage Treasures")
                        .font(.system(size: 21, weight: .heavy))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(hero.title.text(isArabic: viewModel.isArabic) + " — " + hero.subtitle.text(isArabic: viewModel.isArabic))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // 3D Turntable Preview Container (Cleanly contained with .clipped())
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.black.opacity(0.24))

                    Artifact3DTurntableSceneView(
                        artifact: hero,
                        autoRotate: true,
                        allowsCameraControl: true,
                        cameraDistance: 0.65
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    // 3D & AR Quick Buttons
                    HStack(spacing: 8) {
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            withAnimation(.spring()) { viewModel.isPopOut3D = true }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "rotate.3d")
                                    .font(.system(size: 11, weight: .bold))
                                Text("3D 360°")
                                    .font(.system(size: 10.5, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .glossyPill()
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            onLaunchAR(hero)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arkit")
                                    .font(.system(size: 11, weight: .bold))
                                Text(viewModel.isArabic ? "معاينة بالواقع المعزز" : "View in AR")
                                    .font(.system(size: 10.5, weight: .heavy))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .glossyPill(isSelected: true)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                }
                .frame(height: 160)
                .clipped()

                // Primary Yellow Explore CTA Button
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    onSelectArtifact(hero)
                }) {
                    HStack(spacing: 8) {
                        Text(viewModel.isArabic ? "استكشف المعرض والقطع الأثرية" : "Explore Exhibition Gallery")
                            .font(.system(size: 13.5, weight: .bold))
                        Image(systemName: viewModel.isArabic ? "arrow.left" : "arrow.right")
                            .font(.system(size: 12.5, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .glossyPill(isSelected: true)
                }
                .buttonStyle(.plain)
            }
            .padding(18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.65), Color.white.opacity(0.15), Color.white.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 18, x: 0, y: 8)
    }

    // MARK: - 2. "استلهم من التراث" Header + Category Chips
    private var inspireCatalogHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(viewModel.isArabic ? "استلهم من التراث" : "Inspired by Heritage")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)

                // Live 3D Toggle Button
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    withAnimation { viewModel.live3DCatalog.toggle() }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "cube")
                            .font(.system(size: 11, weight: .bold))
                        Text("3D")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(viewModel.live3DCatalog ? .black : .white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .glossyPill(isSelected: viewModel.live3DCatalog)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(viewModel.filteredArtifacts.count) \(viewModel.isArabic ? "مقتنى" : "items")")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.65))
            }

            // Category Chips Row
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
                                .foregroundColor(isSelected ? .black : .white.opacity(0.85))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .glossyPill(isSelected: isSelected, activeColor: Color(red: 1.0, green: 0.839, blue: 0.039))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Search Bar Drawer
    private var searchBarDrawer: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 14, weight: .semibold))

            TextField(
                viewModel.isArabic ? "ابحث بالاسم أو الحقبة (مخطوط، سيف، خوذة، بابل)..." : "Search artifacts by name or period...",
                text: $viewModel.searchQuery
            )
            .font(.system(size: 13.5))
            .foregroundColor(.white)

            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glossyGlass(cornerRadius: 18, tintOpacity: 0.20)
    }

    // MARK: - 4-Cell Room Bento 3D Showcase
    private var fourCellBentoShowcase: some View {
        let a0 = viewModel.artifacts[0] // Nahj al-Balagha
        let a1 = viewModel.artifacts[2] // Zulfiqar
        let a2 = viewModel.artifacts[1] // Helmet
        let a3 = viewModel.artifacts[3] // Babylonian Map

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isArabic ? "معرض الغرفة المكانية" : "Spatial Heritage Bento")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                    Text(viewModel.isArabic ? "نماذج تفاعلية ثلاثية الأبعاد تدعم فحص الواقع المعزز" : "Interactive 3D models with native AR inspect")
                        .font(.system(size: 11.5))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Text("BENTO 3D")
                    .font(.system(size: 9.5, weight: .black, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .glossyPill()
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                bentoCell(artifact: a0, badge: viewModel.isArabic ? "مخطوط نادر" : "MANUSCRIPT")
                bentoCell(artifact: a1, badge: viewModel.isArabic ? "خزانة السلاح" : "ARMORY")
                bentoCell(artifact: a2, badge: viewModel.isArabic ? "دروع الفرسان" : "CAVALRY")
                bentoCell(artifact: a3, badge: viewModel.isArabic ? "بلاد الرافدين" : "MESOPOTAMIA")
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glossyPill()

                    Spacer()

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
                    VStack(alignment: .leading, spacing: 2) {
                        Text(artifact.title.text(isArabic: viewModel.isArabic))
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(artifact.period.text(isArabic: viewModel.isArabic))
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.68))
                            .lineLimit(1)
                    }
                    Spacer()
                    Button(action: { onSelectArtifact(artifact) }) {
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 26)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
        }
        .frame(height: 180)
        .glossyGlass(cornerRadius: 20, tintOpacity: 0.22)
    }

    // MARK: - 3D Volume Pop-Out Overlay
    private var volume3DPopOutOverlay: some View {
        let hero = viewModel.heroArtifact
        let callouts: [(titleAr: String, descAr: String)] = [
            ("الزخارف والنقوش الأصيلة", hero.decoration?.ar ?? hero.material.ar),
            ("المادة والصناعة التراثية", hero.material.ar),
            ("قاعدة المقتنى والختم الأثري", hero.seals?.ar ?? hero.institution.ar)
        ]

        return ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()
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
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .glossyPill()

                Artifact3DTurntableSceneView(
                    artifact: hero,
                    autoRotate: true,
                    allowsCameraControl: true,
                    cameraDistance: 0.60
                )
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { idx in
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            withAnimation { activePopOutCallout = idx }
                        }) {
                            Text("\(idx + 1)")
                                .font(.system(size: 11.5, weight: .black))
                                .foregroundColor(activePopOutCallout == idx ? .black : .white)
                                .glossyCircle(size: 32, isSelected: activePopOutCallout == idx)
                        }
                        .buttonStyle(.plain)
                    }
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
                        Text(viewModel.isArabic ? "إغلاق" : "Close")
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

    // MARK: - About Creator & Platform Section
    private var creatorAboutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                if let logo = BundleImageLoader.uiImage(named: "logo.png") {
                    Image(uiImage: logo)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .padding(10)
                        .glossyGlass(cornerRadius: 16)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("منصة علقمي للتراث المكاني • ALQAMI")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text("designed & developed by isaac faleh · اسحاق فالح")
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

    // MARK: - Curated Bag Section
    private var bagCuratedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.isArabic ? "حقيبة المقتنيات والمعرض الشخصي" : "Curated Exhibition Vault")
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
