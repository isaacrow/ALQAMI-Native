import SwiftUI

public struct CatalogHomeView: View {
    @StateObject private var viewModel = CatalogViewModel()
    @State private var selectedArtifactForDetail: Artifact? = nil
    @State private var activeARArtifact: Artifact? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.06, blue: 0.08), Color(red: 0.08, green: 0.10, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                searchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                categorySelector
                    .padding(.top, 12)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(Color(red: 0.88, green: 0.74, blue: 0.48))
                        .scaleEffect(1.2)
                    Spacer()
                } else if viewModel.filteredArtifacts.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.4))
                        Text(viewModel.isArabic ? "لم يتم العثور على قطع تطابق البحث" : "No artifacts matched your search")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                } else {
                    ScrollView {
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
                        .padding(16)
                    }
                }
            }
        }
        .task {
            await viewModel.loadCatalog()
        }
        .sheet(item: $selectedArtifactForDetail) { artifact in
            ArtifactDetailView(
                artifact: artifact,
                isArabic: viewModel.isArabic,
                onLaunchAR: {
                    activeARArtifact = artifact
                }
            )
        }
        .fullScreenCover(item: $activeARArtifact) { artifact in
            ZStack {
                let arViewModel = ARViewModel(artifact: artifact)
                RealityKitARView(viewModel: arViewModel)
                    .ignoresSafeArea()
                ARControlOverlay(viewModel: arViewModel, onDismiss: {
                    activeARArtifact = nil
                })
            }
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.84, blue: 0.52), Color(red: 0.72, green: 0.55, blue: 0.28)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("ع")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    )

                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.isArabic ? "علقمي التراثي" : "ALQAMI Heritage")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    Text("Spatial AR Edition")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.88, green: 0.74, blue: 0.48))
                }
            }

            Spacer()

            Button(action: {
                viewModel.isArabic.toggle()
                SpatialSoundHelper.shared.playSnapHaptic()
            }) {
                Text(viewModel.isArabic ? "EN" : "عربي")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .visionGlass(cornerRadius: 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.5))
            TextField(
                viewModel.isArabic ? "بحث في المخطوطات والقطع الأثرية..." : "Search manuscripts & artifacts...",
                text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.updateSearchText($0) }
                )
            )
            .foregroundColor(.white)
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.updateSearchText("") }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(10)
        .visionGlass(cornerRadius: 14)
    }

    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.id) { category in
                    let isSelected = viewModel.selectedCategory == category.id
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        viewModel.selectCategory(category.id)
                    }) {
                        Text(category.label.localized(isArabic: viewModel.isArabic))
                            .font(.caption.bold())
                            .foregroundColor(isSelected ? .black : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if isSelected {
                                        LinearGradient(
                                            colors: [Color(red: 1.0, green: 0.85, blue: 0.55), Color(red: 0.82, green: 0.65, blue: 0.35)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    }
                                }
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
