# ALQAMI Native (iOS & Android)

True native mobile applications built from the ground up for spatial heritage exploration and Augmented Reality, inspired by the ALQAMI project.

- **iOS**: Built with **SwiftUI**, **ARKit 6**, and **RealityKit 3** with LiDAR mesh occlusion, PBR rendering, raycasting, and visionOS-style frosted glassmorphic UI.
- **Android**: Built with **Kotlin**, **Jetpack Compose**, **Google ARCore**, and **Sceneview (Filament PBR engine)** with Depth API occlusion, horizontal/vertical surface detection, and environmental HDR.
- **Shared**: Canonical bilingual catalog (`catalog.json`), 11 optimized historical 3D models (`.glb` / `.usdz`), computer vision feature index, and conversion pipeline.

---

## Codebase Structure

```text
ALQAMI-Native/
├── shared/
│   ├── catalog/catalog.json             # Single source of truth for 11 historical artifacts
│   ├── models/glb/                      # 11 glTF 2.0 Binary models for Android Sceneview
│   ├── models/usdz/                     # USDZ models for iOS RealityKit
│   ├── images/                          # High-res photogrammetry & render previews
│   ├── recognition/                     # Visual feature index (1024-dim MobileNet embeddings)
│   └── scripts/convert_glb_to_usdz.py   # Automated GLB to USDZ conversion pipeline
│
├── ios/                                 # Native iOS Project (SwiftUI + RealityKit)
│   ├── Package.swift                    # Swift Package definition
│   └── AlqamiNative/
│       ├── App/AlqamiNativeApp.swift    # App entry point with RTL / theme configuration
│       ├── Models/Artifact.swift        # Codable data structures
│       ├── Services/                    # ARSessionManager & CatalogRepository
│       ├── ViewModels/                  # CatalogViewModel & ARViewModel
│       ├── Views/Catalog/               # CatalogHomeView, ArtifactCardView, ArtifactDetailView
│       ├── Views/AR/                    # RealityKitARView & ARControlOverlay
│       ├── Views/Components/            # VisionGlass & SpatialSoundHelper (CoreHaptics)
│       └── Resources/                   # catalog.json & Info.plist
│
└── android/                             # Native Android Project (Kotlin + Jetpack Compose)
    ├── build.gradle.kts                 # Root Gradle configuration
    ├── settings.gradle.kts              # Module and repository definitions
    ├── gradle/libs.versions.toml        # Version catalog
    └── app/
        ├── build.gradle.kts             # App build script (ARCore + Sceneview + Compose M3)
        └── src/main/
            ├── AndroidManifest.xml      # Camera & ARCore required configuration
            ├── assets/                  # Bundled catalog.json & models/*.glb
            ├── res/                     # Arabic (values-ar) and English (values) strings
            └── java/com/alqami/nativeapp/
                ├── MainActivity.kt      # Edge-to-edge window, permission, & navigation
                ├── data/                # Data models and repository
                ├── ui/theme/            # Vision Pro dark theme & typography
                ├── ui/components/       # GlassmorphicSurface & HapticFeedbackManager
                ├── ui/viewmodel/        # CatalogViewModel & ArViewModel
                ├── ui/catalog/          # CatalogHomeScreen, ArtifactCard, ArtifactDetailScreen
                └── ui/ar/               # ArExperienceScreen & ArControlOverlay
```

---

## How to Build & Run

### 1. iOS (SwiftUI + RealityKit)
1. Open the `ios/` folder or `Package.swift` in **Xcode 15+** on macOS.
2. Select your development team in Signing & Capabilities.
3. Choose a physical device (iPhone with iOS 16+ or iPad with LiDAR for best occlusion and meshing).
4. Build and Run (`Cmd + R`).

### 2. Android (Kotlin + Jetpack Compose + ARCore)
1. Open the `android/` directory in **Android Studio Hedgehog / Iguana / Jellyfish**.
2. Sync the project with Gradle files.
3. Connect an ARCore-supported Android device with USB debugging enabled.
4. Build and Run (`Shift + F10`).

---

## Key Native AR Features Implemented

| Feature | iOS Implementation | Android Implementation |
|:---|:---|:---|
| **Tracking Engine** | `ARKit 6` (`ARWorldTrackingConfiguration`) | `Google ARCore 1.43` |
| **PBR Rendering** | `RealityKit 3` (`PhysicallyBasedMaterial`) | `Sceneview 2.2` (Google Filament engine) |
| **Surface Detection** | Horizontal & Vertical planes with normal alignment | `PlaneFindingMode.HORIZONTAL_AND_VERTICAL` |
| **Occlusion** | LiDAR mesh reconstruction + Person segmentation with depth | ARCore `DepthMode.AUTOMATIC` |
| **Raycasting** | `ARRaycastQuery` / `arView.raycast` | `arSceneView.hitTest` |
| **Gestures** | Multi-touch drag translation, pinch scale, twist rotation | `ArModelNode` editable position, rotation & scale |
| **UI Design System** | visionOS frosted glassmorphism (`.ultraThinMaterial`) | Jetpack Compose custom glass modifier & luminous borders |
| **Localization** | Native Arabic RTL & English LTR switcher | Dual resource qualifiers (`values/` and `values-ar/`) |
