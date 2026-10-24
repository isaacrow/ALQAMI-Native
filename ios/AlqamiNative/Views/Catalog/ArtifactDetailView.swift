import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Exact ALQAMI 6 Split-Pane Product Detail View (screenshot-view2.png)
public struct ArtifactDetailView: View {
    @State public var currentArtifact: Artifact
    public var isArabic: Bool = true
    public var isFavorite: Bool = false
    public var onToggleFavorite: (String) -> Void = { _ in }
    public var onBack: () -> Void
    public var onLaunchAR: (Artifact) -> Void

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
            let isWide = geo.size.width > 660
            ZStack {
                if isWide {
                    // Horizontal Split-Pane (Exact screenshot-view2.png layout)
                    HStack(spacing: 0) {
                        leftStudio3DPane
                            .frame(width: geo.size.width * 0.50)

                        Divider().background(Color.white.opacity(0.1))

                        rightDetailsGlassPane
                            .frame(width: geo.size.width * 0.50)
                    }
                    .environment(\.layoutDirection, .leftToRight)
                } else {
                    // Compact Portrait Split-Pane (Top #CBC9C5 3D Studio + Bottom Frosted Details)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            leftStudio3DPane
                                .frame(height: 330)

                            rightDetailsGlassPane
                        }
                    }
                }

                // QR Code Modal Overlay
                if showQRModal {
                    qrModalOverlay
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareActivityView(activityItems: [
                "\(currentArtifact.title.ar) — \(currentArtifact.subtitle.ar) | ALQAMI Spatial Museum (\(currentArtifact.itemCode))"
            ])
        }
    }

    // MARK: - Left / Top Pane: #CBC9C5 Warm Stone-Gray 3D Studio
    private var leftStudio3DPane: some View {
        ZStack {
            // Exact #CBC9C5 Warm Stone-Gray Studio Background
            Color(red: 0.796, green: 0.788, blue: 0.773)

            // Studio Vignette
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.08)],
                center: .center,
                startRadius: 50,
                endRadius: 240
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
            .padding(.bottom, 44)

            // Curved Orbit Slider Track + Center Rotate3d Button
            VStack {
                Spacer()
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: 8))
                        path.addQuadCurve(to: CGPoint(x: 200, y: 8), control: CGPoint(x: 110, y: 34))
                    }
                    .stroke(Color.black.opacity(0.22), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 220, height: 36)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                        .overlay(
                            Image(systemName: "rotate.3d")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.black.opacity(0.75))
                        )
                        .offset(y: 6)
                }
                .padding(.bottom, 64)
            }
            .allowsHitTesting(false)

            // Bottom Action Bar: Prev/Next (< >), QR Code, Yellow AR Scan Button, "معاينة في المكان" Pill
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    // Prev / Next Artifact Switcher Buttons
                    HStack(spacing: 6) {
                        Button(action: { switchArtifact(delta: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(Color.black.opacity(0.32)))
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        Button(action: { switchArtifact(delta: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(Color.black.opacity(0.32)))
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                    }

                    Spacer()

                    // QR Code Modal Trigger
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring()) { showQRModal = true }
                    }) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(Color.black.opacity(0.45)))
                            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    }

                    // Round Yellow #FFD60A AR Mode Scan Icon Button
                    Button(action: {
                        SpatialSoundHelper.shared.playPlacementHaptic()
                        onLaunchAR(currentArtifact)
                    }) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(red: 1.0, green: 0.839, blue: 0.039))) // #FFD60A
                            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                    }

                    // "معاينة في المكان" (Preview in your space) Dark Glass Pill Button
                    Button(action: {
                        SpatialSoundHelper.shared.playPlacementHaptic()
                        onLaunchAR(currentArtifact)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arkit")
                                .font(.system(size: 14, weight: .bold))
                            Text(isArabic ? "معاينة في المكان" : "Preview in Space")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.black.opacity(0.38)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .environment(\.layoutDirection, .leftToRight)
            }
        }
    }

    // MARK: - Right / Bottom Pane: Frosted Dark Glass Details & 4 Accordions
    private var rightDetailsGlassPane: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // 1. Top Navigation Row: Back (<) on Left, Share & Heart on Right
                HStack {
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        onBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(Color.white.opacity(0.10)))
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(Color.white.opacity(0.10)))
                                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                        }

                        Button(action: {
                            onToggleFavorite(currentArtifact.id)
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isFavorite ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white.opacity(0.85))
                                .frame(width: 38, height: 38)
                                .background(
                                    Circle()
                                        .fill(isFavorite ? Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.2) : Color.white.opacity(0.10))
                                )
                                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                        }
                    }
                }
                .environment(\.layoutDirection, .leftToRight)

                // 2. Title + Star Rating Row + Subtitle
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Text(currentArtifact.title.text(isArabic: isArabic))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        // 5 Yellow Stars + Reviews Count
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: Double(star) <= round(currentArtifact.rating) ? "star.fill" : "star")
                                        .font(.system(size: 11))
                                        .foregroundColor(Double(star) <= round(currentArtifact.rating) ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white.opacity(0.25))
                                }
                            }
                            Text("\(currentArtifact.reviewsCount) \(isArabic ? "تقييم" : "reviews")")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.45))
                        }
                    }

                    Text(currentArtifact.subtitle.text(isArabic: isArabic))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))
                }

                // 3. Description Paragraph
                Text(currentArtifact.description.text(isArabic: isArabic))
                    .font(.system(size: 13.5, weight: .regular))
                    .foregroundColor(.white.opacity(0.82))
                    .lineSpacing(5)

                // 4. Item Code Badge Row ("رقم القطعة" + itemCode Pill)
                HStack(spacing: 10) {
                    Text(isArabic ? "رقم القطعة" : "Item Code")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))

                    Text(currentArtifact.itemCode)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.10)))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 1))
                }

                // 5. Four Collapsible Accordions (Exact ALQAMI 6 Sections)
                VStack(spacing: 0) {
                    accordionItem(
                        id: "details",
                        title: isArabic ? "تفاصيل القطعة (Details)" : "Artifact Details",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 6) {
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
                            VStack(alignment: .leading, spacing: 6) {
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
                                .font(.system(size: 12.5))
                                .foregroundColor(.white.opacity(0.75))
                        )
                    )

                    accordionItem(
                        id: "assembly",
                        title: isArabic ? "تعليمات التجميع (Assembly & Mounting)" : "Assembly & Mounting",
                        content: AnyView(
                            Text(currentArtifact.assembly?.text(isArabic: isArabic) ?? "جاهز للعرض المباشر أو المعاينة المكانية بالواقع المعزز.")
                                .font(.system(size: 12.5))
                                .foregroundColor(.white.opacity(0.75))
                        )
                    )
                }
                .padding(.top, 4)

                // 6. Bottom Amber 3D Box Button (Matches bottom-left icon in screenshot-view2.png)
                HStack {
                    Spacer()
                    Button(action: {
                        SpatialSoundHelper.shared.playPlacementHaptic()
                        onLaunchAR(currentArtifact)
                    }) {
                        Image(systemName: "cube")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.18)))
                            .overlay(Circle().stroke(Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.45), lineWidth: 1))
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
        }
        .background(Color.black.opacity(0.22))
    }

    private func detailBullet(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.88))
            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.70))
        }
    }

    private func accordionItem(id: String, title: String, content: AnyView) -> some View {
        let isOpen = openAccordion == id
        return VStack(alignment: .leading, spacing: 0) {
            Divider().background(Color.white.opacity(0.12))

            Button(action: {
                SpatialSoundHelper.shared.playSnapHaptic()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    openAccordion = isOpen ? nil : id
                }
            }) {
                HStack {
                    Text(title)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundColor(.white.opacity(0.92))
                    Spacer()
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.vertical, 14)
            }

            if isOpen {
                content
                    .padding(.bottom, 14)
                    .transition(.opacity)
            }
        }
    }

    private func switchArtifact(delta: Int) {
        let all = HeritageCatalog.artifacts
        guard let idx = all.firstIndex(where: { $0.id == currentArtifact.id }) else { return }
        let nextIdx = (idx + delta + all.count) % all.count
        SpatialSoundHelper.shared.playSnapHaptic()
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

    // MARK: - Real CoreImage QR Code Modal Overlay
    private var qrModalOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showQRModal = false }
                }

            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isArabic ? "مسح رمز QR للواقع المعزز" : "Scan QR for Mobile AR")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text(currentArtifact.title.text(isArabic: isArabic))
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    }
                    Spacer()
                    Button(action: { withAnimation { showQRModal = false } }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                }

                if let qrImage = generateQRCode(from: "https://alqami.spatial/ar?model=\(currentArtifact.slug)&id=\(currentArtifact.id)") {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 190, height: 190)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                }

                Text(isArabic ? "افتح كاميرا الآيفون أو الماسح الضوئي لفتح المجسم مباشرة في غرفتك" : "Point your iPhone camera or AR scanner to launch this 3D artifact in your room")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.65))
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
                    .padding(.vertical, 11)
                    .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                }
            }
            .padding(22)
            .frame(maxWidth: 320)
            .background(RoundedRectangle(cornerRadius: 28).fill(Color(red: 0.08, green: 0.09, blue: 0.13)))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.2), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.6), radius: 24)
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
