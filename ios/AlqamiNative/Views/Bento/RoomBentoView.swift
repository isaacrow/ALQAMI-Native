import SwiftUI

// MARK: - Room Bento Showcase View with 8 Interactive Hotspots & Apple Glossy Glass
public struct RoomBentoView: View {
    var onLaunchAR: (Artifact) -> Void
    var onDismiss: () -> Void

    @State private var selectedHotspot: BentoHotspot? = HeritageCatalog.bentoHotspots[0]
    @State private var pulseScale: CGFloat = 1.0

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Real Room Backdrop Image (bento_showcase.png / custom_room_bg.png)
                if let bgImg = BundleImageLoader.uiImage(named: "bento_showcase.png") ?? BundleImageLoader.uiImage(named: "custom_room_bg.png") {
                    Image(uiImage: bgImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .ignoresSafeArea()
                } else {
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
                }

                Color.black.opacity(0.32).ignoresSafeArea()

                // Top Glossy Header Bar
                VStack {
                    HStack {
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            onDismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .glossyCircle(size: 36)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        VStack(spacing: 2) {
                            Text("معرض الغرفة المكانية التفاعلية")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("Bento Spatial Heritage Room • 8 Hotspots")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))
                        }

                        Spacer()

                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .glossyGlass(cornerRadius: 22, tintOpacity: 0.28)
                    .padding(.horizontal, 14)
                    .padding(.top, 10)

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
                            Circle()
                                .stroke(Color(red: 1.0, green: 0.84, blue: 0.15).opacity(isSelected ? 0.75 : 0.4), lineWidth: 1.5)
                                .frame(width: isSelected ? 42 : 30, height: isSelected ? 42 : 30)
                                .scaleEffect(pulseScale)

                            Circle()
                                .fill(isSelected ? Color(red: 1.0, green: 0.84, blue: 0.15) : Color.white)
                                .frame(width: isSelected ? 16 : 11, height: isSelected ? 16 : 11)
                                .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.15), radius: isSelected ? 8 : 4)

                            if isSelected {
                                Text(hotspot.areaNameAr)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .glossyPill()
                                    .offset(y: -26)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .position(x: posX, y: posY)
                }

                // Bottom Active Hotspot Glossy Glass Card
                if let hotspot = selectedHotspot,
                   let artifact = HeritageCatalog.artifacts.first(where: { $0.id == hotspot.artifactId }) {
                    VStack {
                        Spacer()

                        HStack(spacing: 14) {
                            Artifact3DTurntableSceneView(artifact: artifact, autoRotate: true)
                                .frame(width: 84, height: 84)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.796, green: 0.788, blue: 0.773)))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(hotspot.areaNameAr)
                                    .font(.system(size: 10.5, weight: .bold))
                                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.15))

                                Text(artifact.title.ar)
                                    .font(.system(size: 14.5, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text(artifact.period.ar)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(1)

                                Button(action: {
                                    onLaunchAR(artifact)
                                }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "arkit")
                                            .font(.system(size: 11.5, weight: .bold))
                                        Text("معاينة بالواقع المعزز (AR)")
                                            .font(.system(size: 11.5, weight: .bold))
                                    }
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 6)
                                    .glossyPill(isSelected: true)
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 2)
                            }

                            Spacer()
                        }
                        .padding(14)
                        .glossyGlass(cornerRadius: 24, tintOpacity: 0.28)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
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
