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

        // 1. Try finding catalog.json in Bundle.main
        var catalogData: Data? = nil
        if let bundleUrl = Bundle.main.url(forResource: "catalog", withExtension: "json") {
            catalogData = try? Data(contentsOf: bundleUrl)
        }

        // 2. Fallback to searching all bundles or local documents
        if catalogData == nil {
            for bundle in Bundle.allBundles {
                if let url = bundle.url(forResource: "catalog", withExtension: "json") {
                    catalogData = try? Data(contentsOf: url)
                    break
                }
            }
        }

        guard let data = catalogData else {
            // Return built-in sample when bundle is standalone during initial preview
            return [Artifact.sample]
        }

        let decoder = JSONDecoder()
        let artifacts = try decoder.decode([Artifact].self, from: data)
        self.cachedArtifacts = artifacts
        return artifacts
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
