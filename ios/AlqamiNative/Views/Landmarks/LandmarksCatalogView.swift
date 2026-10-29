import SwiftUI

// MARK: - 3D Landmarks & Heritage Catalog View
// Matches Image 3: "دليل المعالم ثلاثي الأبعاد", Explorer Progress Card (0/15, 0 نقاط, الفئة الأولى), Filter Tabs, Landmark Cards with "انطلق"
public struct LandmarksCatalogView: View {
    @State private var selectedCategory: LandmarkCategory = .all
    @State private var discoveredCount: Int = 0
    @State private var explorerPoints: Int = 0
    
    public var onSelectLandmarkForAR: (BaghdadLandmark) -> Void
    public var onStartNavigation: (BaghdadLandmark) -> Void
    
    public init(
        onSelectLandmarkForAR: @escaping (BaghdadLandmark) -> Void = { _ in },
        onStartNavigation: @escaping (BaghdadLandmark) -> Void = { _ in }
    ) {
        self.onSelectLandmarkForAR = onSelectLandmarkForAR
        self.onStartNavigation = onStartNavigation
    }
    
    public var filteredLandmarks: [BaghdadLandmark] {
        if selectedCategory == .all {
            return BaghdadLandmarksData.items
        }
        return BaghdadLandmarksData.items.filter { $0.category == selectedCategory }
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // 1. Header Title & Subtitle
                headerSection
                    .padding(.top, 4)
                
                // 2. Explorer Progress Bento Card (سجل استكشاف معالم بغداد والرافدين)
                explorerProgressCard
                
                // 3. Category Filter Chips
                categoryFilterChips
                
                // 4. Landmarks List
                LazyVStack(spacing: 14) {
                    ForEach(filteredLandmarks) { landmark in
                        LandmarkRowCard(
                            landmark: landmark,
                            onLaunchAR: {
                                onSelectLandmarkForAR(landmark)
                            },
                            onNavigate: {
                                onStartNavigation(landmark)
                            }
                        )
                    }
                }
                .padding(.bottom, 96) // Space for floating bottom dock
            }
            .padding(.horizontal, 16)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - 1. Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("دليل المعالم ثلاثي الأبعاد")
                .font(.system(size: 22, weight: .black, design: .serif))
                .foregroundColor(.white)
            
            Text("سجل استكشاف معالم بغداد والرافدين")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 2. Explorer Progress Bento Card
    private var explorerProgressCard: some View {
        VStack(spacing: 12) {
            // Rank Badge Header
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.25))
                        .frame(width: 32, height: 32)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("مستكشف بغداد الواعد")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("الرتبة المكانية للمستكشفين")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text("المستوى 1")
                    .font(.system(size: 10.5, weight: .heavy, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039)))
            }
            
            Divider()
                .background(Color.white.opacity(0.12))
            
            // 3 KPI Counters (0/15 المعالم المكتشفة • 0 نقاط المستكشف • الفئة الأولى)
            HStack(spacing: 8) {
                kpiCounterPill(
                    value: "\(discoveredCount)/\(BaghdadLandmarksData.items.count)",
                    label: "المعالم المكتشفة",
                    icon: "sparkles",
                    color: Color(red: 1.0, green: 0.839, blue: 0.039)
                )
                
                kpiCounterPill(
                    value: "\(explorerPoints)",
                    label: "نقاط المستكشف",
                    icon: "star.fill",
                    color: Color(red: 0.0, green: 0.78, blue: 1.0)
                )
                
                kpiCounterPill(
                    value: "الفئة الأولى",
                    label: "الرتبة المكانية",
                    icon: "shield.checkered",
                    color: Color(red: 0.6, green: 0.4, blue: 0.95)
                )
            }
        }
        .padding(14)
        .glossyGlass(cornerRadius: 22, tintOpacity: 0.25, shadowRadius: 18)
    }
    
    private func kpiCounterPill(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
    
    // MARK: - 3. Category Filter Chips
    private var categoryFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LandmarkCategory.allCases) { cat in
                    let isSelected = selectedCategory == cat
                    Button(action: {
                        SpatialSoundHelper.shared.playSnapHaptic()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedCategory = cat
                        }
                    }) {
                        Text(cat.title(isArabic: true))
                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .black : .white.opacity(0.85))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glossyPill(isSelected: isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Single Landmark Row Card Component (Matches Image 3)
public struct LandmarkRowCard: View {
    public let landmark: BaghdadLandmark
    public var onLaunchAR: () -> Void
    public var onNavigate: () -> Void
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Landmark Badge Icon
                ZStack {
                    Circle()
                        .fill(landmark.badgeColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(landmark.badgeColor.opacity(0.6), lineWidth: 1.2)
                        )
                    
                    Image(systemName: landmark.iconSystemName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(landmark.badgeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(landmark.nameAr)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Text("المسافة: \(String(format: "%.1f", landmark.distanceKm)) كم")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.35))
                        
                        Text(landmark.year)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
                
                Spacer()
                
                // Blue "انطلق" Navigation Action Button
                Button(action: {
                    SpatialSoundHelper.shared.playPlacementHaptic()
                    onNavigate()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("انطلق")
                            .font(.system(size: 12, weight: .black))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.48, blue: 1.0), Color(red: 0.0, green: 0.35, blue: 0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.4), radius: 6, y: 2)
                }
                .buttonStyle(.plain)
            }
            
            // Full Historic Description Paragraph
            Text(landmark.descriptionAr)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.82))
                .lineSpacing(3.5)
            
            // AR 3D Inspect Quick Pill
            HStack {
                Spacer()
                Button(action: {
                    SpatialSoundHelper.shared.playSnapHaptic()
                    onLaunchAR()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arkit")
                            .font(.system(size: 11, weight: .bold))
                        Text("استعراض ثلاثي الأبعاد بالواقع المعزز (AR)")
                            .font(.system(size: 10.5, weight: .bold))
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.12)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .glossyGlass(cornerRadius: 20, tintOpacity: 0.22, shadowRadius: 14)
    }
}
