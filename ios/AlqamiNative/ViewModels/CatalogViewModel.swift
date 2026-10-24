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
    @Published public var live3DCatalog: Bool = false
    @Published public var isPopOut3D: Bool = false
    @Published public var favoriteIds: Set<String> = ["ALQ-MSS-006", "ALQ-SWD-002"]

    public init() {
        self.heroArtifactIndex = 0
    }

    public var heroArtifact: Artifact {
        artifacts[heroArtifactIndex % max(1, artifacts.count)]
    }

    public var filteredArtifacts: [Artifact] {
        artifacts.filter { artifact in
            let matchesCategory: Bool
            switch selectedCategory {
            case .all:
                matchesCategory = true
            case .heritage, .museum:
                matchesCategory = true
            default:
                matchesCategory = (artifact.category == selectedCategory)
            }

            if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return matchesCategory
            }

            let query = searchQuery.lowercased()
            let matchesSearch = artifact.title.ar.lowercased().contains(query) ||
                                artifact.title.en.lowercased().contains(query) ||
                                artifact.period.ar.lowercased().contains(query) ||
                                artifact.material.ar.lowercased().contains(query) ||
                                artifact.itemCode.lowercased().contains(query) ||
                                artifact.description.ar.lowercased().contains(query)

            return matchesCategory && matchesSearch
        }
    }

    public func toggleFavorite(_ id: String) {
        SpatialSoundHelper.shared.playSnapHaptic()
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
    }

    public func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }

    public func nextHeroArtifact() {
        heroArtifactIndex = (heroArtifactIndex + 1) % max(1, artifacts.count)
    }
}
