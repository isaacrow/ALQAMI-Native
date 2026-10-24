import SwiftUI
import AVFoundation

// MARK: - Exact 1:1 ARKit 3D Object Scanner & Linked Data RDF Studio (AlqamiARKitObjectScanner.tsx)
public struct CulturalVisionScannerView: View {
    public var onSelectArtifact: (Artifact) -> Void
    public var onDismiss: () -> Void

    @State private var scanState: ScanState = .idle
    @State private var scanProgress: Int = 0
    @State private var activeTab: RDFTab = .turtle
    @State private var selectedArtifact: Artifact = HeritageCatalog.artifacts[0]
    @State private var isCreatingCustom: Bool = false

    // Custom RDF Creator Fields
    @State private var customTitle: String = ""
    @State private var customCreator: String = ""
    @State private var customPeriod: String = ""
    @State private var customMaterial: String = ""
    @State private var customDimensions: String = ""

    public enum ScanState {
        case idle
        case scanning
        case recognized
    }

    public enum RDFTab: String, CaseIterable {
        case turtle = "turtle"
        case rdfxml = "rdfxml"
        case bibframe = "bibframe"
    }

    public init(
        onSelectArtifact: @escaping (Artifact) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onSelectArtifact = onSelectArtifact
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.08).ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Header Bar
                HStack {
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.10)))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Image(systemName: "viewfinder")
                                .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                            Text("ARKit 3D Object Scanner & Linked Data RDF")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("الماسح الضوئي للرموز والمجسمات الأثرية وتوليد بيانات RDF/Bibframe الدلالية")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.55))
                    }

                    Spacer()

                    // Artifact Selector Menu
                    Menu {
                        ForEach(HeritageCatalog.artifacts) { item in
                            Button(item.title.ar) {
                                selectedArtifact = item
                                scanState = .recognized
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedArtifact.title.ar)
                                .font(.system(size: 11.5, weight: .bold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.white.opacity(0.10)))
                    }
                }
                .padding(16)
                .background(Color.black.opacity(0.35))

                Divider().background(Color.white.opacity(0.12))

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        // 1. Live Camera / 3D Bounding Box Point-Cloud Scanner Stage
                        scannerViewportStage

                        // 2. Semantic Web / Linked Data RDF Studio Panel
                        rdfSemanticStudioPanel
                    }
                    .padding(18)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - 1. Live Camera + 3D Bounding Box Point-Cloud Stage
    private var scannerViewportStage: some View {
        ZStack {
            // Live Camera Feed
            CameraLivePreviewRepresentable()
                .frame(height: 270)
                .clipShape(RoundedRectangle(cornerRadius: 24))

            // Dark Overlay & Grid
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.38))

            // 3D Artifact Preview & Bounding Box inside Reticle
            ZStack {
                Artifact3DTurntableSceneView(
                    artifact: selectedArtifact,
                    autoRotate: true,
                    allowsCameraControl: true,
                    cameraDistance: 0.68
                )
                .frame(width: 200, height: 200)

                // Bounding Box Corners
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        scanState == .recognized ? Color.green : Color(red: 1.0, green: 0.839, blue: 0.039),
                        style: StrokeStyle(lineWidth: 2, dash: scanState == .scanning ? [6, 4] : [])
                    )
                    .frame(width: 210, height: 210)
            }

            // Top Status Badge & Bottom Scan Controls
            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(scanState == .recognized ? Color.green : (scanState == .scanning ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.cyan))
                            .frame(width: 8, height: 8)
                        Text(scanState == .recognized
                             ? "OBJECT RECOGNIZED • \(selectedArtifact.itemCode)"
                             : (scanState == .scanning ? "SCANNING POINT CLOUD... \(scanProgress)%" : "ARKIT OBJECT TRACKING READY"))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.black.opacity(0.65)))

                    Spacer()

                    Button(action: {
                        onSelectArtifact(selectedArtifact)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arkit")
                            Text("فتح في AR")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                    }
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(action: { startPointCloudScan() }) {
                        HStack(spacing: 8) {
                            Image(systemName: scanState == .scanning ? "dot.radiowaves.left.and.right" : "qrcode.viewfinder")
                            Text(scanState == .scanning ? "جاري المسح الثلاثي \(scanProgress)%..." : "مسح QR / التعرف على القطعة 3D")
                                .font(.system(size: 12.5, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 11)
                        .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
                    }

                    Button(action: {
                        withAnimation { isCreatingCustom.toggle() }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text(isCreatingCustom ? "عرض الكود" : "إضافة سجل RDF")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Capsule().fill(Color.black.opacity(0.65)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 270)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.16), lineWidth: 1))
    }

    // MARK: - 2. Linked Data RDF / Turtle / Bibframe Semantic Panel
    private var rdfSemanticStudioPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Tabs: Turtle (.ttl), RDF/XML (.rdf), Bibframe 2.0
            HStack(spacing: 8) {
                rdfTabPill(.turtle, label: "Turtle (.ttl)")
                rdfTabPill(.rdfxml, label: "RDF/XML (.rdf)")
                rdfTabPill(.bibframe, label: "Bibframe 2.0")
                Spacer()
            }

            if isCreatingCustom {
                VStack(alignment: .leading, spacing: 10) {
                    Text("إنشاء وثيقة RDF دلالية جديدة (Custom Semantic Record)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))

                    TextField("عنوان المخطوط أو القطعة الأثرية...", text: $customTitle)
                        .textFieldStyle(.roundedBorder)
                    TextField("المؤلف / الصانع (dc:creator)...", text: $customCreator)
                        .textFieldStyle(.roundedBorder)
                    TextField("الحقبة التاريخية (dcterms:temporal)...", text: $customPeriod)
                        .textFieldStyle(.roundedBorder)
                    TextField("المادة والخامة (crm:P45_consists_of)...", text: $customMaterial)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.06)))
            }

            // Code Output Box
            ScrollView(.horizontal, showsIndicators: true) {
                Text(generatedRDFCode())
                    .font(.system(size: 11.5, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(red: 0.55, green: 0.92, blue: 0.72))
                    .padding(16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.black.opacity(0.65)))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.14), lineWidth: 1))
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.14), lineWidth: 1))
    }

    private func rdfTabPill(_ tab: RDFTab, label: String) -> some View {
        let isSelected = activeTab == tab
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            activeTab = tab
        }) {
            Text(label)
                .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? .black : .white.opacity(0.8))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 1.0, green: 0.839, blue: 0.039) : Color.white.opacity(0.08))
                )
        }
    }

    private func startPointCloudScan() {
        SpatialSoundHelper.shared.playSnapHaptic()
        scanState = .scanning
        scanProgress = 0
        Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
            if scanProgress >= 100 {
                timer.invalidate()
                scanState = .recognized
                SpatialSoundHelper.shared.playSuccessHaptic()
            } else {
                scanProgress += 10
            }
        }
    }

    private func generatedRDFCode() -> String {
        let titleAr = customTitle.isEmpty ? selectedArtifact.title.ar : customTitle
        let creatorAr = customCreator.isEmpty ? selectedArtifact.creator.ar : customCreator
        let periodAr = customPeriod.isEmpty ? selectedArtifact.period.ar : customPeriod
        let materialAr = customMaterial.isEmpty ? selectedArtifact.material.ar : customMaterial

        switch activeTab {
        case .turtle:
            return """
            @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
            @prefix dc: <http://purl.org/dc/elements/1.1/> .
            @prefix dcterms: <http://purl.org/dc/terms/> .
            @prefix crm: <http://www.cidoc-crm.org/cidoc-crm/> .
            @prefix bf: <http://id.loc.gov/ontologies/bibframe/> .
            @prefix alqami: <https://alqami.iq/ontology/heritage#> .

            <https://alqami.iq/resource/artifact/\(selectedArtifact.id)>
                a crm:E22_Human-Made_Object , bf:Instance ;
                dc:identifier "\(selectedArtifact.itemCode)" ;
                dc:title "\(titleAr)"@ar , "\(selectedArtifact.title.en)"@en ;
                dc:creator "\(creatorAr)"@ar ;
                dcterms:temporal "\(periodAr)"@ar ;
                crm:P45_consists_of "\(materialAr)"@ar ;
                crm:P50_has_current_keeper "\(selectedArtifact.institution.ar)"@ar ;
                alqami:has3DModel <https://alqami.iq/models/\(selectedArtifact.model.usdzFilename)> ;
                alqami:spatialAnchorAlignment "horizontalPlane" .
            """
        case .rdfxml:
            return """
            <?xml version="1.0" encoding="UTF-8"?>
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                     xmlns:dc="http://purl.org/dc/elements/1.1/"
                     xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
                     xmlns:alqami="https://alqami.iq/ontology/heritage#">
              <crm:E22_Human-Made_Object rdf:about="https://alqami.iq/resource/artifact/\(selectedArtifact.id)">
                <dc:identifier>\(selectedArtifact.itemCode)</dc:identifier>
                <dc:title xml:lang="ar">\(titleAr)</dc:title>
                <dc:title xml:lang="en">\(selectedArtifact.title.en)</dc:title>
                <dc:creator xml:lang="ar">\(creatorAr)</dc:creator>
                <crm:P45_consists_of xml:lang="ar">\(materialAr)</crm:P45_consists_of>
                <alqami:has3DModel rdf:resource="https://alqami.iq/models/\(selectedArtifact.model.usdzFilename)"/>
              </crm:E22_Human-Made_Object>
            </rdf:RDF>
            """
        case .bibframe:
            return """
            @prefix bf: <http://id.loc.gov/ontologies/bibframe/> .
            @prefix bflc: <http://id.loc.gov/ontologies/bflc/> .

            <https://alqami.iq/bibframe/work/\(selectedArtifact.id)> a bf:Work , bf:Object ;
                bf:title [ a bf:Title ; bf:mainTitle "\(titleAr)"@ar ] ;
                bf:contribution [ a bf:Contribution ; bf:agent [ a bf:Agent ; bf:label "\(creatorAr)"@ar ] ] ;
                bf:originDate "\(periodAr)" ;
                bf:hasInstance <https://alqami.iq/bibframe/instance/\(selectedArtifact.id)> .
            """
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
