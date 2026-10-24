import Foundation

public protocol CatalogRepositoryProtocol {
    func fetchArtifacts() async throws -> [Artifact]
    func fetchArtifact(byId id: String) async throws -> Artifact?
    func fetchCategories() async throws -> [(id: String, label: LocalizedText)]
}

public final class LocalCatalogRepository: CatalogRepositoryProtocol {
    public static let shared = LocalCatalogRepository()
    private var cachedArtifacts: [Artifact] = []

    public init() {}

    public func fetchArtifacts() async throws -> [Artifact] {
        if !cachedArtifacts.isEmpty {
            return cachedArtifacts
        }
        self.cachedArtifacts = HeritageCatalog.artifacts
        return HeritageCatalog.artifacts
    }

    public func fetchArtifact(byId id: String) async throws -> Artifact? {
        let artifacts = try await fetchArtifacts()
        return artifacts.first { $0.id == id || $0.slug == id }
    }

    public func fetchCategories() async throws -> [(id: String, label: LocalizedText)] {
        var results = [(id: "all", label: LocalizedText(ar: "الكل", en: "All"))]
        for category in ArtifactCategory.allCases {
            if category != .all {
                results.append((id: category.rawValue, label: LocalizedText(ar: category.title(isArabic: true), en: category.title(isArabic: false))))
            }
        }
        return results
    }
}
