import SwiftUI
import RealityKit

public struct ARControlOverlay: View {
    @ObservedObject var viewModel: ARViewModel
    var onDismiss: () -> Void

    @State private var showInfoSheet = false
    @State private var showCaliperDimensions = true
    @State private var isPlayingNarration = false

    public var body: some View {
        ZStack {
            // MARK: - Top Vision Glass Header Bar
            VStack {
                HStack(spacing: 12) {
                    // Close Button
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(.ultraThinMaterial))
                            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    }

                    // Status Pill with Real-Time Diagnostics
                    HStack(spacing: 8) {
                        Circle()
                            .fill(viewModel.isPlaced ? Color.green : (viewModel.isSurfaceDetected ? Color.yellow : Color.red))
                            .frame(width: 8, height: 8)

                        Text(viewModel.statusMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))

                    Spacer()

                    // Audio Narration Button
                    Button(action: {
                        isPlayingNarration.toggle()
                        SpatialSoundHelper.shared.playSnapHaptic()
                    }) {
                        Image(systemName: isPlayingNarration ? "speaker.wave.3.fill" : "speaker.wave.1")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isPlayingNarration ? Color(red: 1.0, green: 0.84, blue: 0.15) : .white)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(.ultraThinMaterial))
                            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()
            }

            // MARK: - Live 100% Scale Percentage Badge (Aero Style)
            if viewModel.isPlaced {
                VStack {
                    HStack(spacing: 6) {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 12, weight: .bold))
                        let percent = Int(viewModel.scaleMultiplier * 100)
                        Text(percent == 100 ? "100% (الحجم الواقعي 1:1)" : "\(percent)%")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Int(viewModel.scaleMultiplier * 100) == 100 ? Color(red: 1.0, green: 0.84, blue: 0.15) : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    .padding(.top, 74)

                    // Optional 3D Real-World Caliper Measurement Pill
                    if showCaliperDimensions {
                        HStack(spacing: 6) {
                            Image(systemName: "ruler")
                                .font(.system(size: 11))
                            Text(viewModel.artifact.dimensions.formatted(isArabic: true))
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.4)))
                    }

                    Spacer()
                }
            }

            // MARK: - Bottom Floating Vision Glass Dock Controls
            VStack {
                Spacer()

                VStack(spacing: 12) {
                    // Precision Scale Slider (When Placed)
                    if viewModel.isPlaced {
                        HStack(spacing: 12) {
                            Text("0.5x")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))

                            Slider(value: $viewModel.scaleMultiplier, in: 0.2...3.0, step: 0.05)
                                .tint(Color(red: 1.0, green: 0.84, blue: 0.15))

                            Text("3.0x")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))

                            // Snap 1:1 Button
                            Button(action: {
                                viewModel.scaleMultiplier = 1.0
                                SpatialSoundHelper.shared.playScaleTickHaptic()
                            }) {
                                Text("1:1")
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color(red: 1.0, green: 0.84, blue: 0.15)))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                        .padding(.horizontal, 24)
                    }

                    // Main Action Buttons Pill
                    HStack(spacing: 18) {
                        // Reset / Re-anchor
                        Button(action: {
                            viewModel.isPlaced = false
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .bold))
                                Text("إعادة تثبيت")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.white)
                        }

                        Divider()
                            .frame(height: 24)
                            .background(Color.white.opacity(0.3))

                        // Toggle Caliper Measurement Rulers
                        Button(action: {
                            showCaliperDimensions.toggle()
                            SpatialSoundHelper.shared.playSnapHaptic()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: showCaliperDimensions ? "ruler.fill" : "ruler")
                                    .font(.system(size: 16, weight: .bold))
                                Text("الأبعاد")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(showCaliperDimensions ? Color(red: 1.0, green: 0.84, blue: 0.15) : .white)
                        }

                        Divider()
                            .frame(height: 24)
                            .background(Color.white.opacity(0.3))

                        // Camera Snapshot
                        Button(action: {
                            SpatialSoundHelper.shared.playShutterSound()
                            SpatialSoundHelper.shared.playSuccessHaptic()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("لقطة")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.white)
                        }

                        Divider()
                            .frame(height: 24)
                            .background(Color.white.opacity(0.3))

                        // Info Sheet Trigger
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            showInfoSheet = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("عن القطعة")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.4), radius: 14, x: 0, y: 6)
                }
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            ArtifactQuickInfoSheet(artifact: viewModel.artifact)
        }
    }
}

// MARK: - In-AR Quick Info Glass Sheet
struct ArtifactQuickInfoSheet: View {
    let artifact: Artifact
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(artifact.title.ar)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text(artifact.period.ar)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Divider().background(Color.white.opacity(0.15))

                Text(artifact.description.ar)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("المواصفات والأصل التاريخي")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))

                    HStack {
                        Text("الأبعاد:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text(artifact.dimensions.formatted(isArabic: true))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("المادة:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text(artifact.material.ar)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))

                Spacer()
            }
            .padding(20)
        }
        .presentationDetents([.fraction(0.48), .medium])
    }
}
