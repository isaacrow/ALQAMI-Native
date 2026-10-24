import Foundation
import Combine
import SwiftUI

@MainActor
public final class CatalogViewModel: ObservableObject {
    @Published public var artifacts: [Artifact] = HeritageCatalog.artifacts
    @Published public var selectedCategory: ArtifactCategory = .all
    @Published public var searchQuery: String = ""
    @Published public var isArabic: Bool = true
    @Published public var heroArtifactIndex: Int = 0

    public init() {
        self.heroArtifactIndex = Int.random(in: 0..<HeritageCatalog.artifacts.count)
    }

    public var heroArtifact: Artifact {
        artifacts[heroArtifactIndex]
    }

    public var filteredArtifacts: [Artifact] {
        artifacts.filter { artifact in
            let matchesCategory = (selectedCategory == .all || artifact.category == selectedCategory)

            if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return matchesCategory
            }

            let query = searchQuery.lowercased()
            let matchesSearch = artifact.title.ar.lowercased().contains(query) ||
                                artifact.title.en.lowercased().contains(query) ||
                                artifact.period.ar.lowercased().contains(query) ||
                                artifact.material.ar.lowercased().contains(query) ||
                                artifact.description.ar.lowercased().contains(query)

            return matchesCategory && matchesSearch
        }
    }

    public func nextHeroArtifact() {
        heroArtifactIndex = (heroArtifactIndex + 1) % artifacts.count
    }
}
