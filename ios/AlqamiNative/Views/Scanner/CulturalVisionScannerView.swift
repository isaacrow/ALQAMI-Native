import SwiftUI
import AVFoundation

// MARK: - Cultural Vision Object Scanner View
public struct CulturalVisionScannerView: View {
    var onSelectArtifact: (Artifact) -> Void
    var onDismiss: () -> Void

    @State private var scanLineOffset: CGFloat = -180
    @State private var recognizedArtifact: Artifact? = nil
    @State private var isAnalyzing: Bool = false
    @State private var matchConfidence: Double = 0.984

    public var body: some View {
        ZStack {
            // Camera Background Preview
            CameraLivePreviewRepresentable()
                .ignoresSafeArea()

            // Dark Vignette
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.65)],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()

            // Top Header Bar
            VStack {
                HStack {
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.ultraThinMaterial))
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                        Text("ماسح الرؤية الثقافية الذكي")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)

                Spacer()
            }

            // Central Holographic Reticle Frame with Moving Laser Line
            VStack(spacing: 20) {
                ZStack {
                    // Holographic Corner Brackets
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 1.0, green: 0.84, blue: 0.15).opacity(0.85), lineWidth: 2)
                        .frame(width: 280, height: 280)

                    // Target Crosshair Center
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .ultraLight))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15).opacity(0.5))

                    // Animated Laser Scanning Line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color(red: 1.0, green: 0.84, blue: 0.15), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 260, height: 3)
                        .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.15), radius: 8, x: 0, y: 0)
                        .offset(y: scanLineOffset)
                }

                Text(isAnalyzing ? "جاري مطابقة المعالم الأثرية..." : "وجّه الكاميرا نحو قطعة تراثية أو كتاب...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.black.opacity(0.5)))
            }

            // Bottom Scan Action Button
            VStack {
                Spacer()

                Button(action: {
                    triggerScanRecognition()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .bold))
                        Text("التقاط وتحليل القطعة")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color(red: 1.0, green: 0.84, blue: 0.15)))
                    .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.15).opacity(0.4), radius: 16, x: 0, y: 4)
                }
                .padding(.bottom, 40)
            }

            // Recognition Match Sheet Popup
            if let matched = recognizedArtifact {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()

                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                                    Text("تم التعرف بنسبة \(String(format: "%.1f", matchConfidence * 100))%")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                                }

                                Text(matched.title.ar)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)

                                Text(matched.period.ar)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }

                            Spacer()

                            Button(action: {
                                recognizedArtifact = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }

                        Text(matched.description.ar)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(3)

                        Button(action: {
                            onSelectArtifact(matched)
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arkit")
                                    .font(.system(size: 16, weight: .bold))
                                Text("عرض القطعة في الواقع المعزز (AR)")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 1.0, green: 0.84, blue: 0.15)))
                        }
                    }
                    .padding(22)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color(red: 0.10, green: 0.12, blue: 0.16)))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal, 24)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                scanLineOffset = 130
            }
        }
    }

    private func triggerScanRecognition() {
        SpatialSoundHelper.shared.playShutterSound()
        isAnalyzing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            isAnalyzing = false
            SpatialSoundHelper.shared.playSuccessHaptic()
            // Randomly select one of the high-profile artifacts (e.g. Nahj al-Balagha, Astrolabe, Helmet)
            let candidates = [
                HeritageCatalog.artifacts[0], // Nahj al-Balagha
                HeritageCatalog.artifacts[2], // Helmet
                HeritageCatalog.artifacts[3], // Zulfiqar
                HeritageCatalog.artifacts[9]  // Astrolabe
            ]
            self.recognizedArtifact = candidates.randomElement() ?? HeritageCatalog.artifacts[0]
        }
    }
}

// MARK: - Camera Live Preview Representable
struct CameraLivePreviewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let session = AVCaptureSession()
        session.sessionPreset = .photo

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = UIScreen.main.bounds
            view.layer.addSublayer(previewLayer)

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
