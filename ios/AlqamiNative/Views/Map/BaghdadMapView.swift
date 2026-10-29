import SwiftUI
import MapKit
import AVFoundation

// MARK: - Baghdad Apple Maps Navigation & Heritage View
// Matches Image 2: Native Apple Maps Centered on Baghdad, Custom Pins, Audio Guide, Emergency SOS, Bottom Quick Bar
public struct BaghdadMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661), // Baghdad Center
        span: MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
    )
    
    @State private var selectedLandmark: BaghdadLandmark? = nil
    @State private var inspectingAlephLandmark: BaghdadLandmark? = nil
    @State private var showEmergencySheet: Bool = false
    @State private var isAudioPlaying: Bool = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    public var onSelectLandmarkForAR: (BaghdadLandmark) -> Void
    public var onStartNavigation: (BaghdadLandmark) -> Void
    
    public init(
        onSelectLandmarkForAR: @escaping (BaghdadLandmark) -> Void = { _ in },
        onStartNavigation: @escaping (BaghdadLandmark) -> Void = { _ in }
    ) {
        self.onSelectLandmarkForAR = onSelectLandmarkForAR
        self.onStartNavigation = onStartNavigation
    }
    
    public var body: some View {
        ZStack {
            // 1. Native Apple Maps View with Baghdad Landmarks
            Map(
                coordinateRegion: $region,
                annotationItems: BaghdadLandmarksData.items
            ) { landmark in
                MapAnnotation(coordinate: landmark.coordinate) {
                    LandmarkMapPin(
                        landmark: landmark,
                        isSelected: selectedLandmark?.id == landmark.id
                    ) {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            selectedLandmark = landmark
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
            
            // 2. Floating Top Right Control Buttons (Audio Guide, Emergency, Location)
            VStack {
                HStack(alignment: .top) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Emergency SOS Button
                        Button(action: {
                            SpatialSoundHelper.shared.playWarningHaptic()
                            showEmergencySheet.toggle()
                        }) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                                .glossyCircle(size: 44)
                        }
                        .buttonStyle(.plain)
                        
                        // Audio Guide Narration Button
                        Button(action: {
                            toggleAudioNarration()
                        }) {
                            Image(systemName: isAudioPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(isAudioPlaying ? Color(red: 1.0, green: 0.839, blue: 0.039) : .white)
                                .glossyCircle(size: 44)
                        }
                        .buttonStyle(.plain)
                        
                        // Recenter Baghdad Location Button
                        Button(action: {
                            SpatialSoundHelper.shared.playSnapHaptic()
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661),
                                    span: MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
                                )
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                .glossyCircle(size: 44)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                
                Spacer()
                
                // 3. Selected Landmark Detail Popup or Bottom Apple Maps Bar
                if let landmark = selectedLandmark {
                    landmarkInspectionCard(landmark)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 78)
                } else {
                    bottomAppleMapsBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 78)
                }
            }
        }
        .sheet(isPresented: $showEmergencySheet) {
            EmergencyModalView()
        }
        .fullScreenCover(item: $inspectingAlephLandmark) { landmark in
            Aleph3DGeospatialModalView(
                landmark: landmark,
                onClose: {
                    inspectingAlephLandmark = nil
                },
                onLaunchAR: {
                    inspectingAlephLandmark = nil
                    onSelectLandmarkForAR(landmark)
                }
            )
        }
    }
    
    // MARK: - Selected Landmark Card
    private func landmarkInspectionCard(_ landmark: BaghdadLandmark) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                // Pin Glyph
                ZStack {
                    Circle()
                        .fill(landmark.badgeColor)
                        .frame(width: 38, height: 38)
                    Image(systemName: landmark.iconSystemName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(landmark.nameAr)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("المسافة: \(String(format: "%.1f", landmark.distanceKm)) كم • \(landmark.year)")
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation { selectedLandmark = nil }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .glossyCircle(size: 28)
                }
                .buttonStyle(.plain)
            }
            
            Text(landmark.descriptionAr)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.88))
                .lineLimit(3)
                .lineSpacing(3)
            
            // Aleph 3D Geospatial Button (Powered by Belluxx/Aleph)
            Button(action: {
                SpatialSoundHelper.shared.playPlacementHaptic()
                inspectingAlephLandmark = landmark
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "globe.europe.africa.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.78, blue: 1.0))
                    Text("استكشاف مجسم الأقمار الصناعية (Aleph 3D)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("3D Mesh")
                        .font(.system(size: 9.5, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(red: 0.0, green: 0.78, blue: 1.0)))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 0.0, green: 0.78, blue: 1.0).opacity(0.14))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(red: 0.0, green: 0.78, blue: 1.0).opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Action Buttons (انطلق + عرض ثلاثي الأبعاد AR)
            HStack(spacing: 10) {
                Button(action: {
                    SpatialSoundHelper.shared.playPlacementHaptic()
                    onStartNavigation(landmark)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text("انطلق")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.48, blue: 1.0), Color(red: 0.0, green: 0.35, blue: 0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    onSelectLandmarkForAR(landmark)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arkit")
                            .font(.system(size: 13, weight: .bold))
                        Text("عرض ثلاثي الأبعاد")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.839, blue: 0.039), Color(red: 0.95, green: 0.65, blue: 0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .glossyGlass(cornerRadius: 22, tintOpacity: 0.3, shadowRadius: 20)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - Bottom Apple Maps Quick Bar (Matches Image 2)
    private var bottomAppleMapsBar: some View {
        HStack(spacing: 8) {
            quickBarButton(icon: "house.fill", label: "أضف المنزل", color: .blue)
            quickBarButton(icon: "briefcase.fill", label: "أضف العمل", color: .indigo)
            quickBarButton(icon: "star.fill", label: "المفضلة", color: .yellow)
            quickBarButton(icon: "clock.arrow.circlepath", label: "الأخيرة", color: .gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .glossyGlass(cornerRadius: 26, tintOpacity: 0.28, shadowRadius: 16)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func quickBarButton(icon: String, label: String, color: Color) -> some View {
        Button(action: {
            SpatialSoundHelper.shared.playSnapHaptic()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(color)
                }
                
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Voice Audio Guide Narration
    private func toggleAudioNarration() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isAudioPlaying = false
        } else {
            let textToRead = selectedLandmark?.audioGuideAr ?? "أهلاً بك في خريطة بغداد التراثية، استكشف معالم الرافدين الشامخة من نصب التحرير إلى ساحة المتنبي وساعة القشلة."
            let utterance = AVSpeechUtterance(string: textToRead)
            utterance.voice = AVSpeechSynthesisVoice(language: "ar-XA") ?? AVSpeechSynthesisVoice(language: "ar-SA")
            utterance.rate = 0.48
            speechSynthesizer.speak(utterance)
            isAudioPlaying = true
            SpatialSoundHelper.shared.playPlacementHaptic()
        }
    }
}

// MARK: - Landmark Map Pin Component
public struct LandmarkMapPin: View {
    public let landmark: BaghdadLandmark
    public let isSelected: Bool
    public var onTap: () -> Void
    
    public var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(landmark.badgeColor)
                        .frame(width: isSelected ? 38 : 30, height: isSelected ? 38 : 30)
                        .shadow(color: landmark.badgeColor.opacity(0.6), radius: 6, y: 3)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    Image(systemName: landmark.iconSystemName)
                        .font(.system(size: isSelected ? 15 : 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Pin Arrow Tip
                Image(systemName: "triangle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(landmark.badgeColor)
                    .rotationEffect(.degrees(180))
                    .offset(y: -2)
            }
            .scaleEffect(isSelected ? 1.25 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Emergency SOS Modal
public struct EmergencyModalView: View {
    @Environment(\.presentationMode) var presentationMode
    
    public var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.08).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.red)
                    .padding(.top, 24)
                
                Text("طوارئ بغداد والمساعدة العاجلة")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    emergencyContactRow(number: "104", label: "شرطة النجدة")
                    emergencyContactRow(number: "115", label: "الدفاع المدني والإطفاء")
                    emergencyContactRow(number: "122", label: "الإسعاف الفوري")
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("إغلاق")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .glossyPill()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func emergencyContactRow(number: String, label: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(number)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.red)
            }
            Spacer()
            Button(action: {
                if let url = URL(string: "tel://\(number)") {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .glossyCircle(size: 38)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .glossyGlass(cornerRadius: 16)
    }
}
