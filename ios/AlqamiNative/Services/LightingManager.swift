import Foundation
import SwiftUI
import UIKit

// MARK: - 3D Lighting Preset (Exact 1:1 Translation of src/utils/lightingManager.ts)
public struct LightingPreset: Identifiable, Hashable {
    public let id: String
    public let nameEn: String
    public let nameAr: String
    public let ambientColorHex: String
    public let ambientIntensity: Float
    public let dir1ColorHex: String
    public let dir1Intensity: Float
    public let dir2ColorHex: String
    public let dir2Intensity: Float
    public let pointColorHex: String
    public let pointIntensity: Float
    public let toneMappingExposure: Float
    public let uiAccentHex: String

    public static let allPresets: [LightingPreset] = [
        LightingPreset(
            id: "living-room",
            nameEn: "Living Room",
            nameAr: "غرفة المعيشة",
            ambientColorHex: "#fff5e6",
            ambientIntensity: 0.72,
            dir1ColorHex: "#ffe6bd",
            dir1Intensity: 1.45,
            dir2ColorHex: "#b8d0ff",
            dir2Intensity: 0.45,
            pointColorHex: "#ffb86c",
            pointIntensity: 0.65,
            toneMappingExposure: 1.08,
            uiAccentHex: "#ffb86c"
        ),
        LightingPreset(
            id: "studio-warm",
            nameEn: "Studio Warmth",
            nameAr: "استوديو ذهبي",
            ambientColorHex: "#fff0d4",
            ambientIntensity: 0.85,
            dir1ColorHex: "#ffd28a",
            dir1Intensity: 1.85,
            dir2ColorHex: "#ffe4b5",
            dir2Intensity: 0.6,
            pointColorHex: "#ff9d3b",
            pointIntensity: 0.9,
            toneMappingExposure: 1.18,
            uiAccentHex: "#FFD60A"
        ),
        LightingPreset(
            id: "gallery-cool",
            nameEn: "Gallery Daylight",
            nameAr: "صالة العرض",
            ambientColorHex: "#f4f8ff",
            ambientIntensity: 0.95,
            dir1ColorHex: "#ffffff",
            dir1Intensity: 1.75,
            dir2ColorHex: "#9ec5ff",
            dir2Intensity: 0.8,
            pointColorHex: "#dceaff",
            pointIntensity: 0.55,
            toneMappingExposure: 1.22,
            uiAccentHex: "#7ec8ff"
        ),
        LightingPreset(
            id: "sunset-amber",
            nameEn: "Sunset Amber",
            nameAr: "غروب الشمس",
            ambientColorHex: "#ffd7c2",
            ambientIntensity: 0.6,
            dir1ColorHex: "#ff7b47",
            dir1Intensity: 2.1,
            dir2ColorHex: "#7c5cbf",
            dir2Intensity: 0.55,
            pointColorHex: "#ff944d",
            pointIntensity: 1.15,
            toneMappingExposure: 1.05,
            uiAccentHex: "#ff7b47"
        ),
        LightingPreset(
            id: "dramatic-spot",
            nameEn: "Dramatic Spotlight",
            nameAr: "تسليط الضوء",
            ambientColorHex: "#1c2438",
            ambientIntensity: 0.3,
            dir1ColorHex: "#fff2cc",
            dir1Intensity: 2.6,
            dir2ColorHex: "#3a66b8",
            dir2Intensity: 0.35,
            pointColorHex: "#ffd166",
            pointIntensity: 1.35,
            toneMappingExposure: 0.95,
            uiAccentHex: "#ffd166"
        )
    ]
}

// MARK: - Spatial Environment Backdrop (Exact 6 Environments from App.tsx)
public enum SpatialEnvironmentPreset: String, CaseIterable, Identifiable {
    case livingRoom = "living-room"
    case chromaticWave = "chromatic-wave"
    case thorsmork = "thorsmork"
    case sunsetClouds = "sunset-clouds"
    case woodStudio = "wood-studio"
    case cafeLounge = "cafe-lounge"

    public var id: String { rawValue }

    public var labelEn: String {
        switch self {
        case .livingRoom: return "Living Room"
        case .chromaticWave: return "Chromatic"
        case .thorsmork: return "Thórsmörk"
        case .sunsetClouds: return "Sunset"
        case .woodStudio: return "Wood Studio"
        case .cafeLounge: return "Café Lounge"
        }
    }

    public var labelAr: String {
        switch self {
        case .livingRoom: return "غرفة المعيشة"
        case .chromaticWave: return "موجات لونية"
        case .thorsmork: return "وديان ثورسمورك"
        case .sunsetClouds: return "غروب السحب"
        case .woodStudio: return "الاستوديو الخشبي"
        case .cafeLounge: return "ردهة المقهى"
        }
    }

    public var gradientColors: [Color] {
        switch self {
        case .livingRoom:
            return [Color(red: 0.14, green: 0.12, blue: 0.10), Color(red: 0.24, green: 0.20, blue: 0.16), Color(red: 0.08, green: 0.07, blue: 0.06)]
        case .chromaticWave:
            return [Color(red: 0.03, green: 0.04, blue: 0.12), Color(red: 0.18, green: 0.08, blue: 0.35), Color(red: 0.04, green: 0.22, blue: 0.38)]
        case .thorsmork:
            return [Color(red: 0.12, green: 0.21, blue: 0.28), Color(red: 0.16, green: 0.26, blue: 0.20), Color(red: 0.06, green: 0.08, blue: 0.10)]
        case .sunsetClouds:
            return [Color(red: 0.24, green: 0.11, blue: 0.28), Color(red: 0.65, green: 0.28, blue: 0.22), Color(red: 0.14, green: 0.06, blue: 0.12)]
        case .woodStudio:
            return [Color(red: 0.22, green: 0.14, blue: 0.09), Color(red: 0.36, green: 0.23, blue: 0.14), Color(red: 0.11, green: 0.07, blue: 0.05)]
        case .cafeLounge:
            return [Color(red: 0.18, green: 0.15, blue: 0.13), Color(red: 0.29, green: 0.24, blue: 0.20), Color(red: 0.09, green: 0.08, blue: 0.07)]
        }
    }
}

// MARK: - Master Lighting & Environment Manager
@MainActor
public final class LightingManager: ObservableObject {
    public static let shared = LightingManager()

    @Published public var presetId: String = "living-room"
    @Published public var brightness: Double = 1.0 // 0.2 to 2.0
    @Published public var environment: SpatialEnvironmentPreset = .livingRoom
    @Published public var isSpatialWorldAR: Bool = false // Top-left logo toggles Spatial AR World passthrough

    private init() {}

    public var currentPreset: LightingPreset {
        LightingPreset.allPresets.first(where: { $0.id == presetId }) ?? LightingPreset.allPresets[0]
    }

    public func setPreset(_ id: String) {
        presetId = id
        SpatialSoundHelper.shared.playSnapHaptic()
    }

    public func setBrightness(_ val: Double) {
        brightness = max(0.2, min(2.0, val))
    }

    public func cycleEnvironment() {
        let all = SpatialEnvironmentPreset.allCases
        if let idx = all.firstIndex(of: environment) {
            environment = all[(idx + 1) % all.count]
        }
        SpatialSoundHelper.shared.playSnapHaptic()
    }
}
