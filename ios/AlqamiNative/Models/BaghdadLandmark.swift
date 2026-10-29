import Foundation
import SwiftUI
import CoreLocation

// MARK: - Landmark Category
public enum LandmarkCategory: String, CaseIterable, Codable, Identifiable {
    case all = "all"
    case monument = "monument"
    case heritage = "heritage"
    case ancient = "ancient"

    public var id: String { rawValue }

    public func title(isArabic: Bool) -> String {
        switch self {
        case .all:
            return isArabic ? "جميع المعالم" : "All Landmarks"
        case .monument:
            return isArabic ? "نُصب وتماثيل كبرى" : "Monuments & Statues"
        case .heritage:
            return isArabic ? "معالم تراثية" : "Heritage Sites"
        case .ancient:
            return isArabic ? "آثار حضارية" : "Ancient Civilizations"
        }
    }
}

// MARK: - Baghdad Landmark Data Structure
public struct BaghdadLandmark: Identifiable, Hashable {
    public let id: String
    public let nameAr: String
    public let nameEn: String
    public let category: LandmarkCategory
    public let descriptionAr: String
    public let descriptionEn: String
    public let year: String
    public let distanceKm: Double
    public let latitude: Double
    public let longitude: Double
    public let iconSystemName: String
    public let badgeColorHex: String
    public let modelIdentifier: String?
    public let audioGuideAr: String

    public init(
        id: String,
        nameAr: String,
        nameEn: String,
        category: LandmarkCategory,
        descriptionAr: String,
        descriptionEn: String,
        year: String,
        distanceKm: Double,
        latitude: Double,
        longitude: Double,
        iconSystemName: String,
        badgeColorHex: String = "#FF9500",
        modelIdentifier: String? = nil,
        audioGuideAr: String = ""
    ) {
        self.id = id
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.category = category
        self.descriptionAr = descriptionAr
        self.descriptionEn = descriptionEn
        self.year = year
        self.distanceKm = distanceKm
        self.latitude = latitude
        self.longitude = longitude
        self.iconSystemName = iconSystemName
        self.badgeColorHex = badgeColorHex
        self.modelIdentifier = modelIdentifier
        self.audioGuideAr = audioGuideAr.isEmpty ? descriptionAr : audioGuideAr
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public func localizedName(isArabic: Bool) -> String {
        isArabic ? nameAr : nameEn
    }

    public func localizedDescription(isArabic: Bool) -> String {
        isArabic ? descriptionAr : descriptionEn
    }

    public var badgeColor: Color {
        Color(hex: badgeColorHex)
    }
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 149, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Baghdad Heritage Landmark Catalog
public struct BaghdadLandmarksData {
    public static let items: [BaghdadLandmark] = [
        BaghdadLandmark(
            id: "tahrir-monument",
            nameAr: "نصب التحرير",
            nameEn: "Freedom Monument (Tahrir)",
            category: .monument,
            descriptionAr: "أيقونة بغداد الخالدة في ساحة التحرير، صممه جواد سليم عام 1961 ليجسد ملحمة تحرر الشعب العراقي عبر 14 قطعة برونزية متصلة تروي قصة الثورة والحرية.",
            descriptionEn: "Baghdad's immortal icon in Tahrir Square, sculpted by Jawad Saleem in 1961. It depicts the Iraqi struggle for liberty through 14 interconnected bronze reliefs.",
            year: "1961 م",
            distanceKm: 88.4,
            latitude: 33.3283,
            longitude: 44.4095,
            iconSystemName: "flag.fill",
            badgeColorHex: "#FF9500",
            modelIdentifier: "stela_of_hammurabi_replica",
            audioGuideAr: "أهلاً بك في نصب التحرير، قلب بغداد النابض وصرح الفنان جواد سليم الشامخ."
        ),
        BaghdadLandmark(
            id: "shaheed-monument",
            nameAr: "نصب الشهيد",
            nameEn: "Al-Shaheed Monument",
            category: .monument,
            descriptionAr: "تحفة معمارية عالمية على ضفاف الرصافة، قبة فيروزية إسلامية منقسمة ترتفع 40 متراً تحتضن الراية والينبوع الخالد لشهداء العراق.",
            descriptionEn: "A world-renowned architectural masterpiece on the Rusafa bank: a split turquoise dome rising 40 meters, cradling the eternal spring and flag.",
            year: "1983 م",
            distanceKm: 91.3,
            latitude: 33.3429,
            longitude: 44.4443,
            iconSystemName: "sparkles",
            badgeColorHex: "#00C7BE",
            modelIdentifier: "prayer_niche_mihrab",
            audioGuideAr: "نصب الشهيد، قبة الياقوت الفيروزية المنقسمة التي تحبس الأنفاس بهيبتها وجمالها المعماري."
        ),
        BaghdadLandmark(
            id: "baghdad-tower",
            nameAr: "برج بغداد (برج المأمون)",
            nameEn: "Baghdad Tower (Al-Ma'amoun)",
            category: .monument,
            descriptionAr: "أعلى صرح معماري في بغداد بارتفاع 205 أمتار، يطل على جانبي الكرخ والرصافة ويضم مطعماً دواراً وشرفة رصد بانورامية فريدة.",
            descriptionEn: "Baghdad's tallest architectural landmark standing at 205 meters, featuring a revolving restaurant and a panoramic observation deck.",
            year: "1994 م",
            distanceKm: 83.9,
            latitude: 33.3039,
            longitude: 44.3541,
            iconSystemName: "antenna.radiowaves.left.and.right",
            badgeColorHex: "#AF52DE",
            modelIdentifier: "astrolabe",
            audioGuideAr: "برج بغداد في اليرموك، قمة العاصمة التي تكشف مجرى نهر دجلة الساحر وأفق بلاد الرافدين."
        ),
        BaghdadLandmark(
            id: "qushla-clock",
            nameAr: "ساعة القشلة وسراي بغداد",
            nameEn: "Al-Qushla Clock & Serai",
            category: .heritage,
            descriptionAr: "برج الساعة التاريخي في قلب شارع المتنبي التراثي، شيدت ساعته الشهيرة عام 1869 كرمز للإدارة المدنية ومركز الإشعاع الثقافي البغدادي.",
            descriptionEn: "Historic Ottoman clock tower and courtyard along Al-Mutanabbi Street, constructed in 1869 as a beacon of Baghdad's intellectual and cultural heritage.",
            year: "1869 م",
            distanceKm: 88.8,
            latitude: 33.3396,
            longitude: 44.3861,
            iconSystemName: "clock.fill",
            badgeColorHex: "#FFCC00",
            modelIdentifier: "manuscript_book",
            audioGuideAr: "ساعة القشلة في شارع المتنبي، هنا تجتمع رائحة الكتب وأصالة دجلة ونبض المثقفين."
        ),
        BaghdadLandmark(
            id: "kahramana-statue",
            nameAr: "تمثال كهرمانة",
            nameEn: "Kahramana Fountain",
            category: .heritage,
            descriptionAr: "نصب ساحة كهرمانة وسط الكرادة، يجسد شخصية كهرمانة الذكية من قصص ألف ليلة وليلة وهي تسكب الزيت المغلي في جرار اللصوص الأربعين.",
            descriptionEn: "The famous fountain in Karrada square by Mohammed Ghani Hikmat, depicting Ali Baba's clever Kahramana pouring oil into forty jars.",
            year: "1971 م",
            distanceKm: 87.4,
            latitude: 33.3134,
            longitude: 44.4239,
            iconSystemName: "drop.fill",
            badgeColorHex: "#FF9500",
            modelIdentifier: "saqakhane_bowl",
            audioGuideAr: "تمثال كهرمانة، سحر ألف ليلة وليلة ينبض وسط بغداد بريشة النحات محمد غني حكمت."
        ),
        BaghdadLandmark(
            id: "mutanabbi-statue",
            nameAr: "تمثال المتنبي",
            nameEn: "Al-Mutanabbi Monument",
            category: .monument,
            descriptionAr: "يقف شاعراً ملحمياً على ضفاف نهر دجلة الخالد في نهاية شارع المتنبي، تم نحته تخليداً لأعظم شعراء العربية أبو الطيب المتنبي.",
            descriptionEn: "Epic riverside statue honoring the greatest Arab poet Abu at-Tayyib Al-Mutanabbi, standing proudly at the foot of the Tigris river.",
            year: "1960 م",
            distanceKm: 88.8,
            latitude: 33.3411,
            longitude: 44.3872,
            iconSystemName: "book.closed.fill",
            badgeColorHex: "#FF9500",
            modelIdentifier: "nahj_al_balagha",
            audioGuideAr: "الخيل والليل والبيداء تعرفني، والسيف والرمح والقرطاس والقلم. هنا تمثال المتنبي."
        ),
        BaghdadLandmark(
            id: "iraq-museum",
            nameAr: "المتحف العراقي الوطني",
            nameEn: "The National Museum of Iraq",
            category: .ancient,
            descriptionAr: "خزينة الحضارة الإنسانية الكبرى في العلاوي، يحفظ نفائس سومر وأكد وبابل وآشور ومنها مسلة حمورابي وثيران خورساباد المجنحة واللوحات المسمارية.",
            descriptionEn: "The treasure house of human civilization holding Sumerian, Akkadian, Babylonian and Assyrian masterworks including Hammurabi's code.",
            year: "1923 م",
            distanceKm: 86.2,
            latitude: 33.3281,
            longitude: 44.3853,
            iconSystemName: "building.columns.fill",
            badgeColorHex: "#007AFF",
            modelIdentifier: "babylonian_map_of_the_world_tablet_-_imago_mundi",
            audioGuideAr: "المتحف العراقي الوطني، هنا ولدت الحضارة الأولى وتعلّم البشر تدوين المعرفة والقوانين."
        ),
        BaghdadLandmark(
            id: "mustansiriya-madrasah",
            nameAr: "المدرسة المستنصرية",
            nameEn: "Mustansiriya Madrasah",
            category: .heritage,
            descriptionAr: "أقدم جامعة علمية إسلامية على ضفاف دجلة أسسها الخليفة المستنصر بالله عام 1233 م، تدرس العلوم والفلك والطب والشريعة وساعتها المائية العجيبة.",
            descriptionEn: "One of the oldest Islamic universities in the world founded in 1233 AD, renowned for astronomy, medicine, law and its ancient water clock.",
            year: "1233 م",
            distanceKm: 88.5,
            latitude: 33.3382,
            longitude: 44.3888,
            iconSystemName: "graduationcap.fill",
            badgeColorHex: "#FF9500",
            modelIdentifier: "prayer_niche_mihrab",
            audioGuideAr: "المدرسة المستنصرية، منارة العلم التي صمدت لثمانية قرون على ضفاف دجلة العظيم."
        ),
        BaghdadLandmark(
            id: "baghdad-university",
            nameAr: "جامعة بغداد - الجادرية",
            nameEn: "University of Baghdad (Jadriya)",
            category: .heritage,
            descriptionAr: "أم الجامعات العراقية وصرح التعليم العالي الحديث الممتد على شبه جزيرة الجادرية المحاطة بدجلة والتي صمم حرمها المعماري فالتر غروپيوس.",
            descriptionEn: "The mother of Iraqi universities on the Jadriya peninsula, with an iconic campus masterplanned by Walter Gropius.",
            year: "1957 م",
            distanceKm: 82.1,
            latitude: 33.2736,
            longitude: 44.3789,
            iconSystemName: "graduationcap.fill",
            badgeColorHex: "#5856D6",
            modelIdentifier: "manuscript_book",
            audioGuideAr: "جامعة بغداد في الجادرية، ملتقى أجيال العلماء والرواد في قلب الرافدين."
        ),
        BaghdadLandmark(
            id: "mansour-mall",
            nameAr: "مول المنصور",
            nameEn: "Mansour Mall",
            category: .heritage,
            descriptionAr: "أبرز مركز تجاري وتسوقي حديث في جانب الكرخ بقلب حي المنصور الراقي، يجمع بين الحداثة ونبض الحياة البغدادية المعاصرة.",
            descriptionEn: "The premier modern shopping and entertainment hub in Karkh's upscale Mansour district.",
            year: "2013 م",
            distanceKm: 84.5,
            latitude: 33.3132,
            longitude: 44.3533,
            iconSystemName: "bag.fill",
            badgeColorHex: "#FF2D55",
            modelIdentifier: "bowl",
            audioGuideAr: "مول المنصور، نبض التسوق والحياة العصرية في بغداد الحبيبة."
        ),
        BaghdadLandmark(
            id: "medical-city",
            nameAr: "مدينة الطب",
            nameEn: "Baghdad Medical City",
            category: .heritage,
            descriptionAr: "أكبر مجمع طبي وصحي واستشفائي في العراق والشرق الأوسط على ضفاف دجلة في باب المعظم، يضم مستشفيات تخصصية ومراكز بحثية كبرى.",
            descriptionEn: "The largest medical and healthcare complex in Iraq and the Middle East, located on the Tigris at Bab Al-Muadham.",
            year: "1973 م",
            distanceKm: 89.2,
            latitude: 33.3556,
            longitude: 44.3783,
            iconSystemName: "cross.fill",
            badgeColorHex: "#34C759",
            modelIdentifier: "saqakhane_bowl",
            audioGuideAr: "مدينة الطب، صرح الاستشفاء العريق ورمز العطاء الإنساني في العراق."
        ),
        BaghdadLandmark(
            id: "baghdad-airport",
            nameAr: "مطار بغداد الدولي",
            nameEn: "Baghdad International Airport",
            category: .heritage,
            descriptionAr: "بوابة العراق الجوية الرئيسية ومحطة العبور التاريخية بين الشرق والغرب بصالاته بابل ونينوى وسامراء.",
            descriptionEn: "Iraq's primary international airport featuring its historic terminals Babylon, Nineveh and Samarra.",
            year: "1982 م",
            distanceKm: 98.6,
            latitude: 33.2572,
            longitude: 44.2344,
            iconSystemName: "airplane",
            badgeColorHex: "#32ADE6",
            modelIdentifier: "babylonian_map_of_the_world_tablet_-_imago_mundi",
            audioGuideAr: "مطار بغداد الدولي، البوابة الجوية العريقة التي تفتح ذراعيها لزوار بلاد الرافدين."
        )
    ]
}
