import SwiftUI

public struct CatalogHomeView: View {
    @StateObject private var viewModel = CatalogViewModel()
    @State private var selectedArtifactForDetail: Artifact? = nil
    @State private var activeARArtifact: Artifact? = nil
    @State private var showScanner: Bool = false
    @State private var showBentoRoom: Bool = false
    @State private var showControlCenter: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public var body: some View {
        ZStack {
            // Dark Heritage Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.06, blue: 0.08),
                    Color(red: 0.09, green: 0.11, blue: 0.15),
                    Color(red: 0.04, green: 0.05, blue: 0.07)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. Vision Glass Header Bar
                headerBar

                // Scrollable Content
                ScrollView {
                    VStack(spacing: 18) {
                        // 2. Hero 3D Interactive Showcase Banner
                        heroShowcaseBanner

                        // 3. Search Bar
                        searchBar

                        // 4. Category Filter Chips
                        categorySelector

                        // 5. Artifacts 2-Column Grid
                        if viewModel.filteredArtifacts.isEmpty {
                            emptySearchState
                        } else {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.filteredArtifacts) { artifact in
                                    ArtifactCardView(
                                        artifact: artifact,
                                        isArabic: viewModel.isArabic,
                                        onSelect: {
                                            selectedArtifactForDetail = artifact
                                        },
                                        onLaunchAR: {
                                            activeARArtifact = artifact
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 96) // Bottom padding for floating dock
                }
            }

            // 6. Bottom Floating Vision Glass Dock
            VStack {
                Spacer()
                floatingGlassDock
            }
        }
        // AR Full Screen Experience
        .fullScreenCover(item: $activeARArtifact) { artifact in
            ARContainerView(artifact: artifact) {
                activeARArtifact = nil
            }
        }
        // Cultural Vision Scanner
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
        // Room Bento Hotspots View
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
        // Control Center Sheet
        .sheet(isPresented: $showControlCenter) {
            ControlCenterView {
                showControlCenter = false
            }
        }
        // Artifact Detail Sheet
        .sheet(item: $selectedArtifactForDetail) { artifact in
            ArtifactDetailView(
                artifact: artifact,
                isArabic: viewModel.isArabic,
                onLaunchAR: {
                    activeARArtifact = artifact
                }
            )
        }
    }

    // MARK: - 1. Vision Glass Header Bar
    private var headerBar: some View {
        HStack(spacing: 12) {
            // Brand Logo & Lockup
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            colors: [Color(red: 1.0, green: 0.84, blue: 0.15), Color(red: 0.85, green: 0.65, blue: 0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 34, height: 34)

                    Text("ع")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.isArabic ? "علقمي للتراث المكاني" : "ALQAMI Spatial")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(viewModel.isArabic ? "مخطوطات وقطع أثرية ثلاثية الأبعاد" : "3D Manuscripts & Heritage")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                }
            }

            Spacer()

            // Language Switcher
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation { viewModel.isArabic.toggle() }
            }) {
                Text(viewModel.isArabic ? "EN" : "عربي")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
            }

            // Quick Scanner Trigger
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                showScanner = true
            }) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.12)))
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.12)), alignment: .bottom)
    }

    // MARK: - 2. Hero 3D Showcase Banner
    private var heroShowcaseBanner: some View {
        let hero = viewModel.heroArtifact
        return ZStack(alignment: .bottomLeading) {
            // Interactive 3D Turntable Background
            Artifact3DTurntableSceneView(artifact: hero, autoRotate: true)
                .frame(height: 220)
                .background(
                    RadialGradient(
                        colors: [Color.white.opacity(0.08), Color.black.opacity(0.45)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 160
                    )
                )
                .cornerRadius(22)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.15), lineWidth: 1))

            // Information Overlay & AR Button
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text(hero.period.text(isArabic: viewModel.isArabic))
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.black.opacity(0.6)))

                Text(hero.title.text(isArabic: viewModel.isArabic))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Button(action: {
                    activeARArtifact = hero
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "cube.transparent.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(viewModel.isArabic ? "عرض بالواقع المعزز (AR)" : "Launch AR View")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color(red: 1.0, green: 0.84, blue: 0.15)))
                }
                .padding(.top, 2)
            }
            .padding(16)
        }
    }

    // MARK: - 3. Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 15))

            TextField(
                viewModel.isArabic ? "ابحث في المخطوطات والقطع التراثية..." : "Search artifacts, eras, materials...",
                text: $viewModel.searchQuery
            )
            .font(.system(size: 13))
            .foregroundColor(.white)

            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
    }

    // MARK: - 4. Category Selector Chips
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ArtifactCategory.allCases) { category in
                    let isSelected = viewModel.selectedCategory == category
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            viewModel.selectedCategory = category
                        }
                    }) {
                        Text(category.title(isArabic: viewModel.isArabic))
                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .black : .white.opacity(0.8))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color(red: 1.0, green: 0.84, blue: 0.15) : Color.white.opacity(0.08))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    // MARK: - 5. Empty Search State
    private var emptySearchState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 40)
            Text(viewModel.isArabic ? "لا توجد نتائج مطابقة للبحث" : "No artifacts matched your search")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - 6. Bottom Floating Vision Glass Dock
    private var floatingGlassDock: some View {
        HStack(spacing: 24) {
            // Tab 1: Catalog
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text(viewModel.isArabic ? "المعرض" : "Catalog")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
            }

            // Tab 2: Room Bento Hotspots
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                showBentoRoom = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 18, weight: .bold))
                    Text(viewModel.isArabic ? "الغرفة" : "Bento")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.75))
            }

            // Tab 3: Cultural Vision Scanner
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                showScanner = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 18, weight: .bold))
                    Text(viewModel.isArabic ? "الماسح" : "Scanner")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.75))
            }

            // Tab 4: Control Center
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                showControlCenter = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .bold))
                    Text(viewModel.isArabic ? "التحكم" : "Tuning")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.75))
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.4), radius: 18, x: 0, y: 8)
        .padding(.bottom, 16)
    }
}

// MARK: - AR Container View
struct ARContainerView: View {
    let artifact: Artifact
    var onDismiss: () -> Void
    @StateObject private var arViewModel: ARViewModel

    init(artifact: Artifact, onDismiss: @escaping () -> Void) {
        self.artifact = artifact
        self.onDismiss = onDismiss
        _arViewModel = StateObject(wrappedValue: ARViewModel(artifact: artifact))
    }

    var body: some View {
        ZStack {
            RealityKitARView(viewModel: arViewModel)
                .ignoresSafeArea()

            ARControlOverlay(viewModel: arViewModel, onDismiss: onDismiss)
        }
    }
}
