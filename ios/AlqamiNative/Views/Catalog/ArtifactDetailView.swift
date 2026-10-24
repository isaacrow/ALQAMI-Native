import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Exact ALQAMI 6 Split-Pane Product Detail View with Apple Glossy Glass & Real Voice Narration
public struct ArtifactDetailView: View {
    @State public var currentArtifact: Artifact
    public var isArabic: Bool = true
    public var isFavorite: Bool = false
    public var onToggleFavorite: (String) -> Void = { _ in }
    public var onBack: () -> Void
    public var onLaunchAR: (Artifact) -> Void

    @ObservedObject private var hardware = RealHardwareMonitor.shared
    @State private var openAccordion: String? = "details"
    @State private var showQRModal: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var isFoldTransitioning: Bool = false
    @State private var foldAngle: Double = 0

    public init(
        artifact: Artifact,
        isArabic: Bool = true,
        isFavorite: Bool = false,
        onToggleFavorite: @escaping (String) -> Void = { _ in },
        onBack: @escaping () -> Void = {},
        onLaunchAR: @escaping (Artifact) -> Void
    ) {
        _currentArtifact = State(initialValue: artifact)
        self.isArabic = isArabic
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
        self.onBack = onBack
        self.onLaunchAR = onLaunchAR
    }

    public var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > 640
            ZStack {
                if isWide {
                    // Horizontal Split-Pane (Exact screenshot-view2.png layout)
                    HStack(spacing: 0) {
                        leftStudio3DPane(isWide: true)
                            .frame(width: geo.size.width * 0.48)

                        Divider().background(Color.white.opacity(0.18))

                        rightDetailsGlassPane(isWide: true)
                            .frame(width: geo.size.width * 0.52)
                    }
                    .environment(\.layoutDirection, .leftToRight)
                } else {
                    // Proportional Portrait Split-Pane for iPhone
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            leftStudio3DPane(isWide: false)
                                .frame(height: 295)

                            rightDetailsGlassPane(isWide: false)
                        }
                        .padding(.bottom, 56)
                    }
                }

                // QR Code Modal Overlay
                if showQRModal {
                    qrModalOverlay
                }
            }
        }
        .onDisappear {
            hardware.stopSpeaking()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareActivityView(activityItems: [
                "\(currentArtifact.title.ar) — \(currentArtifact.subtitle.ar) | ALQAMI Spatial Museum (\(currentArtifact.itemCode))"
            ])
        }
    }

    // MARK: - Left / Top Pane: #CBC9C5 Warm Stone-Gray 3D Studio with Glossy Action Controls
    private func leftStudio3DPane(isWide: Bool) -> some View {
        ZStack {
            // Exact #CBC9C5 Warm Stone-Gray Studio Background
            Color(red: 0.796, green: 0.788, blue: 0.773)

            // Studio Vignette + Glossy Top Specular Highlight
            RadialGradient(
                colors: [Color.white.opacity(0.18), Color.black.opacity(0.09)],
                center: .center,
                startRadius: 40,
                endRadius: 210
            )

            // Interactive Real USDZ 3D Model with Duo-Fold 3D Transition
            Artifact3DTurntableSceneView(
                artifact: currentArtifact,
                autoRotate: true,
                allowsCameraControl: true,
                cameraDistance: 0.68
            )
            .rotation3DEffect(
                .degrees(foldAngle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .opacity(isFoldTransitioning ? 0.35 : 1.0)
            .padding(.bottom, 42)

            // Curved Orbit Slider Track + Center Rotate3d Badge
            VStack {
                Spacer()
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: 8))
                        path.addQuadCurve(to: CGPoint(x: 180, y: 8), control: CGPoint(x: 100, y: 30))
                    }
                    .stroke(Color.black.opacity(0.20), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 200, height: 32)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .shadow(color: Color.black.opacity(0.22), radius: 5, x: 0, y: 3)
                        .overlay(
                            Image(systemName: "rotate.3d")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black.opacity(0.75))
                        )
                        .offset(y: 5)
                }
                .padding(.bottom, 58)
            }
            .allowsHitTesting(false)

            // Bottom Action Bar: Glossy Prev/Next (< >), QR Code, Yellow AR Scan Button, "معاينة في المكان" Glossy Pill
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    // Prev / Next Artifact Switcher Buttons
                    HStack(spacing: 6) {
                        Button(action: { switchArtifact(delta: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12.5, weight: .bold))
                                .foregroundColor(.white)
                                .glossyCircle(size: 34)
                        }
                        .buttonStyle(.plain)

                        Button(action: { switchArtifact(delta: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12.5, weight: .bold))
                                .foregroundColor(.white)
                                .glossyCircle(size: 34)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 4)

                    // Real CoreImage QR Code Modal Trigger
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring()) { showQRModal = true }
                    }) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 36)
                    }
                    .buttonStyle(.plain)

                    // Round Glossy Yellow #FFD60A AR Mode Scan Icon Button
                    Button(action: {
                        SpatialSoundHelper.shared.playPlacementHaptic()
                        onLaunchAR(currentArtifact)
                    }) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                            .glossyCircle(size: 36, isSelected: true)
                    }
                    .buttonStyle(.plain)

                    // "معاينة في المكان" (Preview in your space) Glossy Glass Pill Button
                    Button(action: {
                        SpatialSoundHelper.shared.playPlacementHaptic()
                        onLaunchAR(currentArtifact)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arkit")
                                .font(.system(size: 13, weight: .bold))
                            Text(isArabic ? "معاينة في المكان" : "Preview in Space")
                                .font(.system(size: 11.5, weight: .bold))
                                .lineLimit(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glossyPill()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
                .environment(\.layoutDirection, .leftToRight)
            }
        }
    }

    // MARK: - Right / Bottom Pane: Apple Glossy Glass Details, Real Voice Narration & 4 Accordions
    private func rightDetailsGlassPane(isWide: Bool) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                // 1. Top Navigation Row: Glossy Back (<) on Left, Real Voice Narration + Share + Heart on Right
                HStack {
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        hardware.stopSpeaking()
                        onBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 36)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    HStack(spacing: 8) {
                        // Real AVSpeechSynthesizer Voice Narration Button (Arabic / English)
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            let narration = "\(currentArtifact.title.text(isArabic: isArabic)). \(currentArtifact.description.text(isArabic: isArabic)). \(currentArtifact.historicalContext.text(isArabic: isArabic))"
                            hardware.speakNarration(narration, isArabic: isArabic)
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: hardware.isSpeaking ? "waveform" : "speaker.wave.2.fill")
                                    .font(.system(size: 12, weight: .bold))
                                Text(hardware.isSpeaking ? (isArabic ? "إيقاف الصوت" : "Stop") : (isArabic ? "استماع صوتي" : "Listen"))
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(hardware.isSpeaking ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .glossyPill(isSelected: hardware.isSpeaking)
                        }
                        .buttonStyle(.plain)

                        // Share Sheet Button
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 13.5, weight: .semibold))
                                .foregroundColor(.white)
                                .glossyCircle(size: 36)
                        }
                        .buttonStyle(.plain)

                        // Favorite Heart Button
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            onToggleFavorite(currentArtifact.id)
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 13.5, weight: .semibold))
                                .foregroundColor(isFavorite ? .black : .white)
                                .glossyCircle(size: 36, isSelected: isFavorite)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)

                // 2. Title + Star Rating Row + Subtitle
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top) {
                        Text(currentArtifact.title.text(isArabic: isArabic))
                            .font(.system(size: isWide ? 22 : 19, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        // 5 Yellow Stars + Reviews Count
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: Double(star) <= round(currentArtifact.rating) ? "star.fill" : "star")
                                        .font(.system(size: 10.5))
                                        .foregroundColor(Double(star) <= round(currentArtifact.rating) ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white.opacity(0.28))
                                }
                            }
                            Text("\(currentArtifact.reviewsCount) \(isArabic ? "تقييم" : "reviews")")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.55))
                        }
                    }

                    Text(currentArtifact.subtitle.text(isArabic: isArabic))
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                }

                // 3. Description Paragraph
                Text(currentArtifact.description.text(isArabic: isArabic))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.86))
                    .lineSpacing(4)

                // 4. Item Code Badge Row ("رقم القطعة" + Glossy itemCode Pill)
                HStack(spacing: 8) {
                    Text(isArabic ? "رقم القطعة" : "Item Code")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))

                    Text(currentArtifact.itemCode)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .glossyPill()
                }

                // 5. Four Collapsible Accordions (Exact ALQAMI 6 Sections)
                VStack(spacing: 0) {
                    accordionItem(
                        id: "details",
                        title: isArabic ? "تفاصيل القطعة (Details)" : "Artifact Details",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 5) {
                                detailBullet(label: isArabic ? "الفترة:" : "Period:", value: currentArtifact.period.text(isArabic: isArabic))
                                detailBullet(label: isArabic ? "الصانع / المؤلف:" : "Creator:", value: currentArtifact.creator.text(isArabic: isArabic))
                                detailBullet(label: isArabic ? "المؤسسة:" : "Institution:", value: currentArtifact.institution.text(isArabic: isArabic))
                                detailBullet(label: isArabic ? "المادة:" : "Material:", value: currentArtifact.material.text(isArabic: isArabic))
                                detailBullet(label: isArabic ? "الحالة:" : "Condition:", value: currentArtifact.condition.text(isArabic: isArabic))
                                if let binding = currentArtifact.binding {
                                    detailBullet(label: isArabic ? "التجليد:" : "Binding:", value: binding.text(isArabic: isArabic))
                                }
                                if let decoration = currentArtifact.decoration {
                                    detailBullet(label: isArabic ? "الزخرفة:" : "Decoration:", value: decoration.text(isArabic: isArabic))
                                }
                            }
                        )
                    )

                    accordionItem(
                        id: "measurements",
                        title: isArabic ? "القياسات (Measurements)" : "Measurements",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 5) {
                                detailBullet(label: isArabic ? "الأبعاد:" : "Dimensions:", value: currentArtifact.dimensions.formatted(isArabic: isArabic))
                                if let seals = currentArtifact.seals {
                                    detailBullet(label: isArabic ? "الأختام والتوثيق:" : "Seals:", value: seals.text(isArabic: isArabic))
                                }
                            }
                        )
                    )

                    accordionItem(
                        id: "delivery",
                        title: isArabic ? "التسليم و التعليمات (Delivery & Packaging)" : "Delivery & Packaging",
                        content: AnyView(
                            Text(currentArtifact.delivery?.text(isArabic: isArabic) ?? "شحن متحفي مؤمّن داخل كبسولة حفظ حرارية.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.78))
                        )
                    )

                    accordionItem(
                        id: "assembly",
                        title: isArabic ? "تعليمات التجميع (Assembly & Mounting)" : "Assembly & Mounting",
                        content: AnyView(
                            Text(currentArtifact.assembly?.text(isArabic: isArabic) ?? "جاهز للعرض المباشر أو المعاينة المكانية بالواقع المعزز.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.78))
                        )
                    )
                }
                .padding(.top, 2)

                // 6. Bottom Glossy Amber 3D Cube Launch Button
                HStack {
                    Spacer()
                    Button(action: {
                        SpatialSoundHelper.shared.playPlacementHaptic()
                        onLaunchAR(currentArtifact)
                    }) {
                        Image(systemName: "cube")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                            .glossyCircle(size: 38, isSelected: true)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(isWide ? 22 : 16)
            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        }
        .background(Color.black.opacity(0.18))
    }

    private func detailBullet(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(label)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            Text(value)
                .font(.system(size: 11.5, weight: .regular))
                .foregroundColor(.white.opacity(0.72))
        }
    }

    private func accordionItem(id: String, title: String, content: AnyView) -> some View {
        let isOpen = openAccordion == id
        return VStack(alignment: .leading, spacing: 0) {
            Divider().background(Color.white.opacity(0.14))

            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    openAccordion = isOpen ? nil : id
                }
            }) {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.94))
                    Spacer()
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if isOpen {
                content
                    .padding(.bottom, 12)
                    .transition(.opacity)
            }
        }
    }

    private func switchArtifact(delta: Int) {
        let all = HeritageCatalog.artifacts
        guard let idx = all.firstIndex(where: { $0.id == currentArtifact.id }) else { return }
        let nextIdx = (idx + delta + all.count) % all.count
        SpatialSoundHelper.shared.playSnapHaptic()
        hardware.stopSpeaking()
        withAnimation(.easeInOut(duration: 0.22)) {
            isFoldTransitioning = true
            foldAngle = delta > 0 ? -45 : 45
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            currentArtifact = all[nextIdx]
            withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                isFoldTransitioning = false
                foldAngle = 0
            }
        }
    }

    // MARK: - Real CoreImage QR Code Modal Overlay (Glossy Glass)
    private var qrModalOverlay: some View {
        ZStack {
            Color.black.opacity(0.74)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showQRModal = false }
                }

            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isArabic ? "مسح رمز QR للواقع المعزز" : "Scan QR for Mobile AR")
                            .font(.system(size: 14.5, weight: .bold))
                            .foregroundColor(.white)
                        Text(currentArtifact.title.text(isArabic: isArabic))
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                    Spacer()
                    Button(action: { withAnimation { showQRModal = false } }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 30)
                    }
                    .buttonStyle(.plain)
                }

                if let qrImage = generateQRCode(from: "https://alqami.spatial/ar?model=\(currentArtifact.slug)&id=\(currentArtifact.id)") {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 175, height: 175)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
                }

                Text(isArabic ? "افتح كاميرا الآيفون أو الماسح الضوئي لفتح المجسم مباشرة في غرفتك" : "Point your iPhone camera or AR scanner to launch this 3D artifact in your room")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.72))
                    .multilineTextAlignment(.center)

                Button(action: {
                    showQRModal = false
                    onLaunchAR(currentArtifact)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arkit")
                        Text(isArabic ? "فتح مباشر بالواقع المعزز الآن" : "Launch Native AR Directly")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .glossyPill(isSelected: true)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .frame(maxWidth: 310)
            .glossyGlass(cornerRadius: 26, tintOpacity: 0.35)
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let outputImage = filter.outputImage else { return nil }
        let transformed = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgimg = context.createCGImage(transformed, from: transformed.extent) else { return nil }
        return UIImage(cgImage: cgimg)
    }
}

// MARK: - Native UIActivityViewController Wrapper
struct ShareActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
