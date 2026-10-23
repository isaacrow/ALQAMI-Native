import SwiftUI

public struct ARControlOverlay: View {
    @ObservedObject var viewModel: ARViewModel
    var onDismiss: () -> Void

    public var body: some View {
        VStack {
            // Top Bar
            HStack(spacing: 12) {
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    onDismiss()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.artifact.title.ar)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(viewModel.artifact.period.ar)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Status pill
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.isSurfaceDetected ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(viewModel.isPlaced ? "مثبت" : (viewModel.isSurfaceDetected ? "سطح جاهز" : "بحث..."))
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer()

            // Surface Guidance Center Indicator (when not placed)
            if !viewModel.isPlaced {
                VStack(spacing: 10) {
                    Image(systemName: viewModel.isSurfaceDetected ? "checkmark.circle.fill" : "camera.viewfinder")
                        .font(.system(size: 38))
                        .foregroundColor(viewModel.isSurfaceDetected ? .green : .white.opacity(0.8))
                        .scaleEffect(viewModel.isSurfaceDetected ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.isSurfaceDetected)

                    Text(viewModel.statusMessage)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .visionGlass(cornerRadius: 14)
                }
                .padding(.bottom, 30)
            }

            // Bottom Glass Dock
            VStack(spacing: 12) {
                if viewModel.isPlaced {
                    // Scale controls
                    HStack(spacing: 16) {
                        Button(action: {
                            viewModel.setScale(viewModel.scaleMultiplier - 0.15)
                            SpatialSoundHelper.shared.playSnapHaptic()
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text(String(format: "%.0f%%", viewModel.scaleMultiplier * 100))
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 54)

                        Button(action: {
                            viewModel.setScale(viewModel.scaleMultiplier + 0.15)
                            SpatialSoundHelper.shared.playSnapHaptic()
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Divider()
                            .frame(height: 20)
                            .background(Color.white.opacity(0.3))

                        // Occlusion toggle
                        Button(action: {
                            viewModel.isOcclusionEnabled.toggle()
                            SpatialSoundHelper.shared.playSnapHaptic()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isOcclusionEnabled ? "person.fill.viewfinder" : "eye.slash")
                                    .font(.system(size: 14))
                                Text(viewModel.isOcclusionEnabled ? "حجب العمق" : "العمق معطل")
                                    .font(.caption2.bold())
                            }
                            .foregroundColor(viewModel.isOcclusionEnabled ? .green : .white.opacity(0.6))
                        }

                        Spacer()

                        // Reset position button
                        Button(action: {
                            viewModel.resetPlacement()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.red.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .visionGlass(cornerRadius: 18)
                }

                // Instructions bar
                Text(viewModel.isPlaced ? "اسحب لتحريك القطعة • اقرص للتحجيم • لف بإصبعين للتدوير" : "انقر على السطح المحدد لتثبيت القطعة في مكانها الواقعي")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}
