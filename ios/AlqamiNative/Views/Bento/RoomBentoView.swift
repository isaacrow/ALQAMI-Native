import SwiftUI

// MARK: - Room Bento Showcase View with 8 Interactive Hotspots
public struct RoomBentoView: View {
    var onLaunchAR: (Artifact) -> Void
    var onDismiss: () -> Void

    @State private var selectedHotspot: BentoHotspot? = HeritageCatalog.bentoHotspots[0]
    @State private var pulseScale: CGFloat = 1.0

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background Atmosphere Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.07, green: 0.08, blue: 0.11),
                        Color(red: 0.12, green: 0.14, blue: 0.18),
                        Color(red: 0.05, green: 0.06, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Room Architectural Wireframe & Spatial Floor Grid
                VStack {
                    Spacer()
                    ZStack {
                        // Perspective Grid Lines
                        Path { path in
                            let w = geo.size.width
                            let h = geo.size.height * 0.55
                            for i in 0...8 {
                                let x = w * CGFloat(i) / 8.0
                                path.move(to: CGPoint(x: x, y: geo.size.height))
                                path.addLine(to: CGPoint(x: w * 0.5 + (x - w * 0.5) * 0.2, y: geo.size.height - h))
                            }
                        }
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    }
                }
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

                        VStack(spacing: 2) {
                            Text("معرض الغرفة المكانية التفاعلية")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("Bento Spatial Heritage Room • 8 Hotspots")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                        }

                        Spacer()

                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)

                    Spacer()
                }

                // 8 Interactive Pulsating Hotspot Markers
                ForEach(HeritageCatalog.bentoHotspots) { hotspot in
                    let posX = geo.size.width * CGFloat(hotspot.xPercent)
                    let posY = geo.size.height * CGFloat(hotspot.yPercent)
                    let isSelected = selectedHotspot?.id == hotspot.id

                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedHotspot = hotspot
                        }
                    }) {
                        ZStack {
                            // Pulsing Outer Glow
                            Circle()
                                .stroke(Color(red: 1.0, green: 0.84, blue: 0.15).opacity(isSelected ? 0.7 : 0.35), lineWidth: 1.5)
                                .frame(width: isSelected ? 44 : 32, height: isSelected ? 44 : 32)
                                .scaleEffect(pulseScale)

                            // Inner Solid Core
                            Circle()
                                .fill(isSelected ? Color(red: 1.0, green: 0.84, blue: 0.15) : Color.white)
                                .frame(width: isSelected ? 18 : 12, height: isSelected ? 18 : 12)
                                .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.15), radius: isSelected ? 10 : 4)

                            // Area Badge Label
                            if isSelected {
                                Text(hotspot.areaNameAr)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.black.opacity(0.7)))
                                    .offset(y: -28)
                            }
                        }
                    }
                    .position(x: posX, y: posY)
                }

                // Bottom Active Hotspot Glass Card
                if let hotspot = selectedHotspot,
                   let artifact = HeritageCatalog.artifacts.first(where: { $0.id == hotspot.artifactId }) {
                    VStack {
                        Spacer()

                        HStack(spacing: 16) {
                            // 3D Mini Turntable
                            Artifact3DTurntableSceneView(artifact: artifact, autoRotate: true)
                                .frame(width: 90, height: 90)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.3)))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(hotspot.areaNameAr)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))

                                Text(artifact.title.ar)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text(artifact.period.ar)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.65))

                                Button(action: {
                                    onLaunchAR(artifact)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "cube.transparent")
                                            .font(.system(size: 12, weight: .bold))
                                        Text("معاينة بالواقع المعزز (AR)")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color(red: 1.0, green: 0.84, blue: 0.15)))
                                }
                                .padding(.top, 4)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 22).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.25), lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.4), radius: 18, x: 0, y: 8)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 36)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
            }
        }
    }
}
