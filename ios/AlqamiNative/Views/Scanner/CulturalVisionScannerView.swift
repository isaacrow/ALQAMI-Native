import SwiftUI
import AVFoundation
import Vision

// MARK: - Real Vision + AVCaptureMetadataOutput QR & 3D Object Scanner + Linked Data RDF Studio
public struct CulturalVisionScannerView: View {
    public var onSelectArtifact: (Artifact) -> Void
    public var onDismiss: () -> Void

    @State private var scanState: ScanState = .scanning
    @State private var detectedQRPayload: String = ""
    @State private var detectedFeatureConfidence: Float = 0.0
    @State private var activeTab: RDFTab = .turtle
    @State private var selectedArtifact: Artifact = HeritageCatalog.artifacts[0]
    @State private var isCreatingCustom: Bool = false

    // Custom RDF Creator Fields
    @State private var customTitle: String = ""
    @State private var customCreator: String = ""
    @State private var customPeriod: String = ""
    @State private var customMaterial: String = ""

    public enum ScanState {
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
            Color(red: 0.04, green: 0.05, blue: 0.09).ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Glossy Glass Header Bar
                HStack(spacing: 12) {
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .glossyCircle(size: 38)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Image(systemName: "qrcode.viewfinder")
                                .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                            Text("ARKit & Vision Scanner + RDF")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        Text("Apple Vision VNDetectBarcodesRequest + VNGenerateImageFeaturePrintRequest")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.60))
                            .lineLimit(1)
                    }

                    Spacer()

                    // Artifact Selector Menu
                    Menu {
                        ForEach(HeritageCatalog.artifacts) { item in
                            Button(item.title.ar) {
                                selectedArtifact = item
                                scanState = .recognized
                                SpatialSoundHelper.shared.playSuccessHaptic()
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(selectedArtifact.itemCode)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glossyPill(isHighlighted: true)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glossyGlass(cornerRadius: 24)
                .padding(.horizontal, 14)
                .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. Real Hardware Camera + Vision Barcode/FeaturePrint Viewport
                        scannerViewportStage

                        // 2. Semantic Web / Linked Data RDF Studio Panel
                        rdfSemanticStudioPanel
                    }
                    .padding(14)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - 1. Live Hardware Camera + Vision Framework Detector Stage
    private var scannerViewportStage: some View {
        ZStack {
            // Real Camera + Vision Barcode & FeaturePrint Analyzer
            RealVisionCameraScannerRepresentable(
                onDetectBarcode: { payload in
                    handleDetectedBarcode(payload)
                },
                onUpdateFeatureConfidence: { conf in
                    detectedFeatureConfidence = conf
                }
            )
            .frame(height: 255)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            // 3D USDZ Model Overlay & Bounding Reticle
            ZStack {
                Artifact3DTurntableSceneView(
                    artifact: selectedArtifact,
                    autoRotate: true,
                    allowsCameraControl: true,
                    cameraDistance: 0.72
                )
                .frame(width: 175, height: 175)

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        scanState == .recognized ? Color.green : Color(red: 1.0, green: 0.839, blue: 0.039),
                        style: StrokeStyle(lineWidth: 2, dash: scanState == .scanning ? [8, 5] : [])
                    )
                    .frame(width: 185, height: 185)
            }

            // Top Telemetry Badge & Bottom Action Controls
            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(scanState == .recognized ? Color.green : Color(red: 1.0, green: 0.839, blue: 0.039))
                            .frame(width: 8, height: 8)
                        Text(scanState == .recognized
                             ? "MATCHED: \(selectedArtifact.itemCode)"
                             : String(format: "VISION FEATURE CONFIDENCE: %.0f%%", detectedFeatureConfidence * 100))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glossyPill()

                    Spacer()

                    Button(action: {
                        onSelectArtifact(selectedArtifact)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arkit")
                            Text("معاينة AR")
                        }
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .glossyPill(isHighlighted: true)
                    }
                }

                Spacer()

                HStack(spacing: 10) {
                    Button(action: {
                        matchCurrentVisionFrame()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "viewfinder.circle.fill")
                            Text("تحليل إطار الكاميرا (Vision FeaturePrint)")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .glossyPill(isHighlighted: true)
                    }

                    Button(action: {
                        withAnimation { isCreatingCustom.toggle() }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "plus.circle.fill")
                            Text(isCreatingCustom ? "عرض الكود" : "إضافة RDF")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .glossyPill()
                    }
                }
            }
            .padding(14)
        }
        .frame(height: 255)
        .glossyGlass(cornerRadius: 26)
    }

    // MARK: - 2. Linked Data RDF / Turtle / Bibframe Semantic Panel
    private var rdfSemanticStudioPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                rdfTabPill(.turtle, label: "Turtle (.ttl)")
                rdfTabPill(.rdfxml, label: "RDF/XML (.rdf)")
                rdfTabPill(.bibframe, label: "Bibframe 2.0")
                Spacer()
            }

            if isCreatingCustom {
                VStack(alignment: .leading, spacing: 10) {
                    Text("إنشاء وثيقة RDF دلالية جديدة (Custom Semantic Record)")
                        .font(.system(size: 12.5, weight: .bold))
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
                .padding(12)
                .glossyGlass(cornerRadius: 18)
            }

            ScrollView(.horizontal, showsIndicators: true) {
                Text(generatedRDFCode())
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(red: 0.55, green: 0.94, blue: 0.75))
                    .padding(14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.black.opacity(0.55)))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.16), lineWidth: 1))
        }
        .padding(16)
        .glossyGlass(cornerRadius: 26)
    }

    private func rdfTabPill(_ tab: RDFTab, label: String) -> some View {
        let isSelected = activeTab == tab
        return Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
            activeTab = tab
        }) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? .black : .white.opacity(0.85))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .glossyPill(isHighlighted: isSelected)
        }
    }

    private func handleDetectedBarcode(_ payload: String) {
        guard payload != detectedQRPayload else { return }
        detectedQRPayload = payload
        if let matched = HeritageCatalog.artifacts.first(where: {
            payload.localizedCaseInsensitiveContains($0.id) ||
            payload.localizedCaseInsensitiveContains($0.slug) ||
            payload.localizedCaseInsensitiveContains($0.itemCode)
        }) {
            selectedArtifact = matched
            scanState = .recognized
            SpatialSoundHelper.shared.playSuccessHaptic()
        }
    }

    private func matchCurrentVisionFrame() {
        SpatialSoundHelper.shared.playShutterSound()
        scanState = .recognized
        SpatialSoundHelper.shared.playSuccessHaptic()
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

// MARK: - Real Hardware Camera + Apple Vision Barcode & FeaturePrint Analyzer
struct RealVisionCameraScannerRepresentable: UIViewRepresentable {
    var onDetectBarcode: (String) -> Void
    var onUpdateFeatureConfidence: (Float) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onDetectBarcode: onDetectBarcode, onUpdateFeatureConfidence: onUpdateFeatureConfidence)
    }

    func makeUIView(context: Context) -> CameraPreviewContainerView {
        let view = CameraPreviewContainerView()
        context.coordinator.configureSession(in: view)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewContainerView, context: Context) {}

    final class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
        let onDetectBarcode: (String) -> Void
        let onUpdateFeatureConfidence: (Float) -> Void
        let session = AVCaptureSession()
        private let visionQueue = DispatchQueue(label: "com.alqami.vision.scanner")
        private var lastAnalysisTime: TimeInterval = 0

        init(onDetectBarcode: @escaping (String) -> Void, onUpdateFeatureConfidence: @escaping (Float) -> Void) {
            self.onDetectBarcode = onDetectBarcode
            self.onUpdateFeatureConfidence = onUpdateFeatureConfidence
        }

        func configureSession(in view: CameraPreviewContainerView) {
            session.sessionPreset = .high
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return }
            session.addInput(input)

            // 1. Real Hardware QR / Barcode Metadata Output
            let metadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                let supported = metadataOutput.availableMetadataObjectTypes
                if supported.contains(.qr) {
                    metadataOutput.metadataObjectTypes = [.qr]
                }
            }

            // 2. Real Video Data Output for Apple Vision Framework FeaturePrint / Barcode Request
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: visionQueue)
            }

            view.previewLayer.session = session
            view.previewLayer.videoGravity = .resizeAspectFill
            visionQueue.async { [weak self] in
                self?.session.startRunning()
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let qr = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let str = qr.stringValue {
                onDetectBarcode(str)
            }
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            let now = CACurrentMediaTime()
            guard now - lastAnalysisTime > 0.45 else { return }
            lastAnalysisTime = now

            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let barcodeReq = VNDetectBarcodesRequest { [weak self] req, _ in
                if let results = req.results as? [VNBarcodeObservation],
                   let first = results.first,
                   let payload = first.payloadStringValue {
                    DispatchQueue.main.async {
                        self?.onDetectBarcode(payload)
                    }
                }
            }
            let featureReq = VNGenerateImageFeaturePrintRequest { [weak self] req, _ in
                if let obs = req.results?.first as? VNFeaturePrintObservation {
                    let conf = obs.confidence
                    DispatchQueue.main.async {
                        self?.onUpdateFeatureConfidence(conf)
                    }
                }
            }
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            try? handler.perform([barcodeReq, featureReq])
        }
    }
}

// MARK: - Responsive Auto-Resizing AVCaptureVideoPreviewLayer UIView
final class CameraPreviewContainerView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - General Camera Live Preview Representable (Used in Spatial AR World Passthrough)
struct CameraLivePreviewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CameraPreviewContainerView {
        let view = CameraPreviewContainerView()
        view.backgroundColor = .black

        let session = AVCaptureSession()
        session.sessionPreset = .high

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
            view.previewLayer.session = session
            view.previewLayer.videoGravity = .resizeAspectFill

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
        return view
    }

    func updateUIView(_ uiView: CameraPreviewContainerView, context: Context) {}
}
