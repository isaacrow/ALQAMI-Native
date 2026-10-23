import Foundation
import Combine

@MainActor
public final class CatalogViewModel: ObservableObject {
    @Published public var artifacts: [Artifact] = []
    @Published public var filteredArtifacts: [Artifact] = []
    @Published public var categories: [(id: String, label: LocalizedText)] = []
    @Published public var selectedCategory: String = "all"
    @Published public var searchText: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var selectedArtifactForAR: Artifact? = nil
    @Published public var isArabic: Bool = true

    private let repository: CatalogRepositoryProtocol

    public init(repository: CatalogRepositoryProtocol = LocalCatalogRepository.shared) {
        self.repository = repository
    }

    public func loadCatalog() async {
        isLoading = true
        errorMessage = nil
        do {
            let items = try await repository.fetchArtifacts()
            let cats = try await repository.fetchCategories()
            self.artifacts = items
            self.categories = cats
            applyFilters()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func selectCategory(_ categoryId: String) {
        selectedCategory = categoryId
        applyFilters()
    }

    public func updateSearchText(_ query: String) {
        searchText = query
        applyFilters()
    }

    private func applyFilters() {
        var result = artifacts

        if selectedCategory != "all" {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.ar.lowercased().contains(query) ||
                $0.title.en.lowercased().contains(query) ||
                $0.period.ar.lowercased().contains(query) ||
                $0.period.en.lowercased().contains(query) ||
                $0.creator.ar.lowercased().contains(query) ||
                $0.creator.en.lowercased().contains(query)
            }
        }

        self.filteredArtifacts = result
    }
}
