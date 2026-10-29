import SwiftUI
import RealityKit
import ARKit

// MARK: - Dedicated AR Scanner Tab View (LiDAR + RealityKit Surface & Object Scanner)
// Tab 2 in the 4-Mode Native Navigation Dock
public struct ARScannerTabView: View {
    @StateObject private var arViewModel = ARViewModel(artifact: HeritageCatalog.artifacts[0])
    @State private var scanMode: ScanMode = .surfaceLiDAR
    @State private var showUSDZPreview: Bool = false
    
    public enum ScanMode: String, CaseIterable {
        case surfaceLiDAR = "كشف الأسطح (LiDAR)"
        case objectTracking = "تتبع المجسمات"
        case qrRecognition = "مسح الرموز والمعالم"
    }
    
    public var body: some View {
        ZStack {
            // 1. RealityKit Native AR View with Raycasting & LiDAR
            RealityKitARView(viewModel: arViewModel)
                .ignoresSafeArea()
            
            // 2. HUD Overlays
            VStack(spacing: 0) {
                // Top Scanner Modes Pill Bar
                topModeSelector
                    .padding(.top, 6)
                
                Spacer()
                
                // Center Targeting Reticle (if not placed yet)
                if !arViewModel.isPlaced {
                    centerReticleHUD
                }
                
                Spacer()
                
                // Bottom LiDAR Control Strip
                bottomScannerControls
                    .padding(.horizontal, 16)
                    .padding(.bottom, 78) // Positioned above the dock
            }
        }
    }
    
    // MARK: - 1. Top Mode Selector
    private var topModeSelector: some View {
        HStack(spacing: 8) {
            ForEach(ScanMode.allCases, id: \.self) { mode in
                let isSelected = scanMode == mode
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        scanMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .black : .white.opacity(0.85))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .glossyPill(isSelected: isSelected)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .glossyGlass(cornerRadius: 22, tintOpacity: 0.25)
    }
    
    // MARK: - 2. Center Reticle HUD
    private var centerReticleHUD: some View {
        VStack(spacing: 8) {
            ZStack {
                // Animated Scanning Corner Brackets
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        arViewModel.isSurfaceDetected ? Color(red: 0.2, green: 0.85, blue: 0.4) : Color(red: 1.0, green: 0.839, blue: 0.039),
                        style: StrokeStyle(lineWidth: 2, dash: [20, 10])
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: (arViewModel.isSurfaceDetected ? Color.green : Color.yellow).opacity(0.5), radius: 10)
                
                // Center Crosshair
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.75))
            }
            
            Text(arViewModel.statusMessage)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .glossyGlass(cornerRadius: 16, tintOpacity: 0.3)
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
    
    // MARK: - 3. Bottom Scanner Controls
    private var bottomScannerControls: some View {
        HStack(spacing: 12) {
            // LiDAR Mesh Wireframe Toggle
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation {
                    arViewModel.showMeshWireframe.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: arViewModel.showMeshWireframe ? "circle.grid.3x3.fill" : "circle.grid.3x3")
                        .font(.system(size: 13, weight: .bold))
                    Text("شبكة LiDAR")
                        .font(.system(size: 11.5, weight: .bold))
                }
                .foregroundColor(arViewModel.showMeshWireframe ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .glossyPill(isSelected: arViewModel.showMeshWireframe)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Snapshot Button
            Button(action: {
                SpatialSoundHelper.shared.playPlacementHaptic()
                arViewModel.captureARSnapshot()
            }) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 46, height: 46)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 36, height: 36)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Reset / Clear Button
            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                arViewModel.resetPlacement()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12, weight: .bold))
                    Text("إعادة ضبط")
                        .font(.system(size: 11.5, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .glossyPill()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glossyGlass(cornerRadius: 24, tintOpacity: 0.28, shadowRadius: 16)
        .environment(\.layoutDirection, .rightToLeft)
    }
}
