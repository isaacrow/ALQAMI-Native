import Foundation
import SwiftUI
import UIKit

// MARK: - LocalizedText
public struct LocalizedText: Codable, Hashable {
    public let ar: String
    public let en: String

    public init(ar: String, en: String) {
        self.ar = ar
        self.en = en
    }

    public func text(isArabic: Bool) -> String {
        isArabic ? ar : en
    }
}

// MARK: - Exact 8 Categories from ALQAMI 6
public enum ArtifactCategory: String, CaseIterable, Codable, Identifiable {
    case all = "all"
    case artifact = "artifact"
    case manuscripts = "manuscripts"
    case islamicArt = "islamic-art"
    case history = "history"
    case heritage = "heritage"
    case museum = "museum"
    case culture = "culture"

    public var id: String { rawValue }

    public func title(isArabic: Bool) -> String {
        switch self {
        case .all:
            return isArabic ? "الكل" : "All"
        case .artifact:
            return isArabic ? "مقتنيات أثرية" : "Artifacts"
        case .manuscripts:
            return isArabic ? "مخطوطات" : "Manuscripts"
        case .islamicArt:
            return isArabic ? "فن إسلامي" : "Islamic Art"
        case .history:
            return isArabic ? "تاريخ" : "History"
        case .heritage:
            return isArabic ? "تراث" : "Heritage"
        case .museum:
            return isArabic ? "متحف" : "Museum"
        case .culture:
            return isArabic ? "ثقافة" : "Culture"
        }
    }
}

// MARK: - 3D Dimensions
public struct ArtifactDimensions: Codable, Hashable {
    public let heightCm: Double
    public let widthCm: Double
    public let depthCm: Double
    public let weightKg: Double?
    public let rawText: String?

    public init(heightCm: Double, widthCm: Double, depthCm: Double, weightKg: Double? = nil, rawText: String? = nil) {
        self.heightCm = heightCm
        self.widthCm = widthCm
        self.depthCm = depthCm
        self.weightKg = weightKg
        self.rawText = rawText
    }

    public func formatted(isArabic: Bool) -> String {
        if let raw = rawText, !raw.isEmpty {
            return raw
        }
        if let weight = weightKg {
            return isArabic
                ? "\(String(format: "%.1f", heightCm)) × \(String(format: "%.1f", widthCm)) × \(String(format: "%.1f", depthCm)) سم • \(String(format: "%.1f", weight)) كجم"
                : "\(String(format: "%.1f", heightCm)) × \(String(format: "%.1f", widthCm)) × \(String(format: "%.1f", depthCm)) cm • \(String(format: "%.1f", weight)) kg"
        } else {
            return isArabic
                ? "\(String(format: "%.1f", heightCm)) × \(String(format: "%.1f", widthCm)) × \(String(format: "%.1f", depthCm)) سم"
                : "\(String(format: "%.1f", heightCm)) × \(String(format: "%.1f", widthCm)) × \(String(format: "%.1f", depthCm)) cm"
        }
    }
}

// MARK: - 3D Visual Archetype
public enum Artifact3DArchetype: String, Codable {
    case manuscriptBook
    case worldTablet
    case battleHelmet
    case curvedSword
    case stoneStele
    case prayerMihrab
    case cuneiformClay
    case bronzeBowl
    case ceramicBowl
    case astrolabeInstrument
    case damascusDagger
}

// MARK: - Artifact Model Specification
public struct ModelSpec: Codable, Hashable {
    public let usdzFilename: String
    public let glbFilename: String
    public let scale: Float
    public let archetype: Artifact3DArchetype
    public let primaryColorHex: String
    public let secondaryColorHex: String
    public let roughness: Float
    public let metallic: Float

    public init(
        usdzFilename: String,
        glbFilename: String,
        scale: Float,
        archetype: Artifact3DArchetype,
        primaryColorHex: String,
        secondaryColorHex: String,
        roughness: Float = 0.35,
        metallic: Float = 0.65
    ) {
        self.usdzFilename = usdzFilename
        self.glbFilename = glbFilename
        self.scale = scale
        self.archetype = archetype
        self.primaryColorHex = primaryColorHex
        self.secondaryColorHex = secondaryColorHex
        self.roughness = roughness
        self.metallic = metallic
    }
}

// MARK: - Audio Narration
public struct AudioNarration: Codable, Hashable {
    public let titleAr: String
    public let titleEn: String
    public let narratorAr: String
    public let narratorEn: String
    public let durationSec: Int
    public let transcriptAr: String
    public let transcriptEn: String

    public init(
        titleAr: String,
        titleEn: String,
        narratorAr: String,
        narratorEn: String,
        durationSec: Int,
        transcriptAr: String,
        transcriptEn: String
    ) {
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.narratorAr = narratorAr
        self.narratorEn = narratorEn
        self.durationSec = durationSec
        self.transcriptAr = transcriptAr
        self.transcriptEn = transcriptEn
    }
}

// MARK: - Bento Hotspot
public struct BentoHotspot: Identifiable, Hashable {
    public let id: String
    public let xPercent: Double
    public let yPercent: Double
    public let artifactId: String
    public let labelAr: String
    public let labelEn: String
    public let areaNameAr: String
    public let areaNameEn: String

    public init(
        id: String,
        xPercent: Double,
        yPercent: Double,
        artifactId: String,
        labelAr: String,
        labelEn: String,
        areaNameAr: String,
        areaNameEn: String
    ) {
        self.id = id
        self.xPercent = xPercent
        self.yPercent = yPercent
        self.artifactId = artifactId
        self.labelAr = labelAr
        self.labelEn = labelEn
        self.areaNameAr = areaNameAr
        self.areaNameEn = areaNameEn
    }
}

// MARK: - Main Artifact Model
public struct Artifact: Identifiable, Codable, Hashable {
    public let id: String
    public let slug: String
    public let itemCode: String
    public let imageName: String
    public let title: LocalizedText
    public let subtitle: LocalizedText
    public let category: ArtifactCategory
    public let categoryLabel: LocalizedText
    public let period: LocalizedText
    public let creator: LocalizedText
    public let institution: LocalizedText
    public let dimensions: ArtifactDimensions
    public let material: LocalizedText
    public let condition: LocalizedText
    public let binding: LocalizedText?
    public let decoration: LocalizedText?
    public let seals: LocalizedText?
    public let delivery: LocalizedText?
    public let assembly: LocalizedText?
    public let description: LocalizedText
    public let historicalContext: LocalizedText
    public let rating: Double
    public let reviewsCount: Int
    public let priceEstimateUSD: Int
    public let model: ModelSpec
    public let audio: AudioNarration

    public init(
        id: String,
        slug: String,
        itemCode: String,
        imageName: String,
        title: LocalizedText,
        subtitle: LocalizedText,
        category: ArtifactCategory,
        categoryLabel: LocalizedText,
        period: LocalizedText,
        creator: LocalizedText,
        institution: LocalizedText,
        dimensions: ArtifactDimensions,
        material: LocalizedText,
        condition: LocalizedText,
        binding: LocalizedText? = nil,
        decoration: LocalizedText? = nil,
        seals: LocalizedText? = nil,
        delivery: LocalizedText? = nil,
        assembly: LocalizedText? = nil,
        description: LocalizedText,
        historicalContext: LocalizedText,
        rating: Double = 4.9,
        reviewsCount: Int = 18,
        priceEstimateUSD: Int = 250,
        model: ModelSpec,
        audio: AudioNarration
    ) {
        self.id = id
        self.slug = slug
        self.itemCode = itemCode
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.categoryLabel = categoryLabel
        self.period = period
        self.creator = creator
        self.institution = institution
        self.dimensions = dimensions
        self.material = material
        self.condition = condition
        self.binding = binding
        self.decoration = decoration
        self.seals = seals
        self.delivery = delivery
        self.assembly = assembly
        self.description = description
        self.historicalContext = historicalContext
        self.rating = rating
        self.reviewsCount = reviewsCount
        self.priceEstimateUSD = priceEstimateUSD
        self.model = model
        self.audio = audio
    }

    public static var sample: Artifact {
        HeritageCatalog.artifacts[0]
    }
}

// MARK: - Bundle Image Helper (Loads from Bundle Resources/Images or Root)
public enum BundleImageLoader {
    public static func uiImage(named filename: String) -> UIImage? {
        let clean = (filename as NSString).lastPathComponent
        let base = (clean as NSString).deletingPathExtension
        let ext = (clean as NSString).pathExtension.isEmpty ? "png" : (clean as NSString).pathExtension

        if let img = UIImage(named: clean) ?? UIImage(named: base) {
            return img
        }
        let subdirs: [String?] = ["Resources/Images", "Images", nil]
        for sub in subdirs {
            if let url = Bundle.main.url(forResource: base, withExtension: ext, subdirectory: sub),
               let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                return img
            }
        }
        return nil
    }

    public static func usdzURL(named filename: String) -> URL? {
        let clean = (filename as NSString).lastPathComponent
        let base = (clean as NSString).deletingPathExtension
        let subdirs: [String?] = ["Resources/Models", "Models", nil]
        for sub in subdirs {
            if let url = Bundle.main.url(forResource: base, withExtension: "usdz", subdirectory: sub) {
                return url
            }
        }
        return nil
    }
}

// MARK: - Master Heritage Catalog Data (Exact 11 Artifacts from ALQAMI 6)
public struct HeritageCatalog {
    public static let artifacts: [Artifact] = [
        // 1. ALQ-MSS-006: Nahj al-Balagha Manuscript
        Artifact(
            id: "ALQ-MSS-006",
            slug: "nahj-al-balagha",
            itemCode: "1022 هـ / هـ",
            imageName: "model-nahj_al_balagha.png",
            title: LocalizedText(ar: "مخطوط نهج البلاغة", en: "Nahj al-Balagha Manuscript"),
            subtitle: LocalizedText(ar: "الشيخ الرضي - الشريف الرضي (1022 هـ)", en: "Al-Sharif al-Radi (1022 AH / 1613 CE)"),
            category: .manuscripts,
            categoryLabel: LocalizedText(ar: "المخطوطات والنوادر", en: "Manuscripts"),
            period: LocalizedText(ar: "1022 هـ / 1613 م (العصر الصفوي)", en: "1022 AH / 1613 CE"),
            creator: LocalizedText(ar: "الشريف الرضي (ت 406 هـ) • الناسخ: شمس الدين علي الشيرازي", en: "Al-Sharif al-Radi • Scribe: Shams al-Din Ali al-Shirazi"),
            institution: LocalizedText(ar: "مكتبة العتبة الرضوية المقدسة (1861) • مستودع علقمي الرقمي", en: "Central Library of Astan Quds Razavi • Alqami Repository"),
            dimensions: ArtifactDimensions(heightCm: 28.5, widthCm: 18.2, depthCm: 6.5, weightKg: 1.4, rawText: "28.5 × 18.2 سم (477 ورقة)"),
            material: LocalizedText(ar: "ورق مجدول ومذهب، حبر أسود، مداد أحمر، خط النسخ الأصيل", en: "Gold-ruled paper, carbon ink, cinnabar rubrication, Naskh script"),
            condition: LocalizedText(ar: "نادرة ومحفوظة بعناية فائقة مع تجليد إسلامي أصيل ومحكم", en: "Extremely rare, well-preserved in historic Islamic binding"),
            binding: LocalizedText(ar: "تجليد جلدي إسلامي أصيل مزخرف بنقوش هندسية مذهبة ومحكمة", en: "Authentic Islamic leather binding with gilded geometric tooling"),
            decoration: LocalizedText(ar: "النسخة مجدولة بالذهب، وأولها لوحة فنية مذهبة بديعة وعناوين بالمداد الأحمر", en: "Gold-illuminated borders, gilded frontispiece, and rubricated chapter headers"),
            seals: LocalizedText(ar: "تحتوي على قيود تملكية وأختام مكتبة العتبة الرضوية المقدسة برقم 1861", en: "Bears historic ownership seals and endowment inscription no. 1861"),
            delivery: LocalizedText(ar: "شحن آمن في حافظة حرارية مضادة للصدمات مع شهادة توثيق رقمية NFT.", en: "Shipped in climate-controlled archival case with digital museum NFT certificate."),
            assembly: LocalizedText(ar: "لا تتطلب تجميع؛ جاهزة للعرض المكتبي أو التثبيت في منصة العرض المتحفي الزجاجية.", en: "No assembly required; ready for tabletop display or archival museum vitrine."),
            description: LocalizedText(
                ar: "نسخة خطية من مخطوط نهج البلاغة، تُنسب إلى الشريف الرضي الذي جمعها وشرحها، تتميز هذه النسخة بخط جميل وواضح، وتحتوي على زخارف وهامش مذهب، وهي من أقدم النسخ المحفوظة التي تحمل هذا النص القيّم.",
                en: "Illuminated manuscript of Nahj al-Balagha compiled by Al-Sharif al-Radi, transcribed in 1022 AH with ornate gold borders, intricate arabesque frontispiece, and red ink chapter markings."
            ),
            historicalContext: LocalizedText(
                ar: "كُتبت هذه النسخة في ذروة ازدهار فنون الخط والتذهيب في شيراز وأصفهان، واحتفظ بها كبار العلماء حتى استقرت كوقف نفيس في خزانة المخطوطات التراثية.",
                en: "Transcribed at the zenith of Persian and Islamic book illumination arts in Shiraz, held by elite scholars before being endowed into sacred institutional trust."
            ),
            rating: 4.0,
            reviewsCount: 12,
            priceEstimateUSD: 149,
            model: ModelSpec(
                usdzFilename: "nahj_al_balagha.usdz",
                glbFilename: "nahj_al_balagha.glb",
                scale: 1.0,
                archetype: .manuscriptBook,
                primaryColorHex: "#9B7644",
                secondaryColorHex: "#D4AF37",
                roughness: 0.65,
                metallic: 0.25
            ),
            audio: AudioNarration(
                titleAr: "تلاوة وقراءة بلاغية من خطب المخطوط",
                titleEn: "Oratorical Reading from the Nahj al-Balagha Folios",
                narratorAr: "صوتيات دار التراث العربي",
                narratorEn: "Arab Heritage Sound Archives",
                durationSec: 185,
                transcriptAr: "الحمد لله الذي لا يبلغ مدحته القائلون، ولا يحصي نعماءه العادون، ولا يؤدي حقه المجتهدون...",
                transcriptEn: "Praise be to Allah, whose praise cannot be reached by speakers, nor His bounties counted by reckoners..."
            )
        ),

        // 2. ALQ-HLM-004: Old Islamic Helmet
        Artifact(
            id: "ALQ-HLM-004",
            slug: "old-islamic-helmet",
            itemCode: "HLM-OTT-15",
            imageName: "model-Old_Islamic_Helmet.png",
            title: LocalizedText(ar: "خوذة إسلامية حربية مذهبة", en: "Old Islamic Gilded Helmet"),
            subtitle: LocalizedText(ar: "خوذة خيالة عثمانية مصفحة مع أنفية ودرع زرد (القرن 15 م)", en: "Ottoman cavalry helmet with mail aventail, 15th century."),
            category: .artifact,
            categoryLabel: LocalizedText(ar: "الأسلحة والقطع الحربية", en: "Artifact"),
            period: LocalizedText(ar: "القرن الخامس عشر الميلادي", en: "15th century"),
            creator: LocalizedText(ar: "حدادو البلاط السلطاني العثماني", en: "Imperial Ottoman Armory"),
            institution: LocalizedText(ar: "المتحف العسكري • مستودع علقمي الرقمي", en: "Military Museum Collection • Alqami"),
            dimensions: ArtifactDimensions(heightCm: 34.0, widthCm: 22.0, depthCm: 24.5, weightKg: 1.8, rawText: "الارتفاع: 34 سم • القطر: 22 سم • الوزن: 1.8 كجم"),
            material: LocalizedText(ar: "فولاذ كربوني مقسى، تذهيب مكفت عيار 24، حلقات حديد مشبك", en: "Tempered carbon steel, 24k gold inlay, riveted iron mail rings"),
            condition: LocalizedText(ar: "تحفة متحفية بحالة استثنائية مع لمعان النحاس والذهب الأصلي", en: "Museum grade with intact mail aventail and original gilt sheen"),
            delivery: LocalizedText(ar: "شحن دولي مصفح مع قاعدة عرض معدنية مكسوة بالمخمل الأسود.", en: "Armored dispatch with velvet-lined steel pedestal."),
            assembly: LocalizedText(ar: "تأتي مثبتة على عمود العرض المخملي مع إمكانية الفك السريع.", en: "Pre-assembled on museum display pole."),
            description: LocalizedText(
                ar: "خوذة حربية مخروطية الشكل مصنوعة من الفولاذ الصلب المنقوش بآيات النصر والفتح ومكفتة بخيوط الذهب، مع درع زردي متدلي لحماية العنق والرقبة وقضيب حماية الأنف المتحرك.",
                en: "Conical Ottoman turban helmet of forged steel, inscribed with calligraphic cartouches in gold damascening, complete with nasal bar and interlocking steel mail aventail."
            ),
            historicalContext: LocalizedText(
                ar: "كانت ترتديها قيادات النخبة في الفرسان، وتجمع بين الحماية الفائقة من ضربات السيوف والرمزية الروحية لثبات المقاتل في الميدان.",
                en: "Worn by elite cavalry commanders, harmonizing impenetrable ballistic protection with profound spiritual symbolism on the battlefield."
            ),
            rating: 4.9,
            reviewsCount: 34,
            priceEstimateUSD: 220,
            model: ModelSpec(
                usdzFilename: "Old_Islamic_Helmet.usdz",
                glbFilename: "Old_Islamic_Helmet.glb",
                scale: 1.1,
                archetype: .battleHelmet,
                primaryColorHex: "#54585E",
                secondaryColorHex: "#D4AF37",
                roughness: 0.3,
                metallic: 0.92
            ),
            audio: AudioNarration(
                titleAr: "تاريخ صناعة السيوف والدروع الإسلامية الفولاذية",
                titleEn: "The Metallurgical Mastery of Islamic Steel Armor",
                narratorAr: "خبير الأسلحة التراثية د. أحمد الشامي",
                narratorEn: "Historic Arms Curator Dr. A. Al-Shami",
                durationSec: 160,
                transcriptAr: "الخوذة العمامة صُممت بحيث تُشتت طاقة الضربة الهابطة من السيوف المستقيمة، بينما يمنح التذهيب الكفتكاري بريقاً نفسياً مهيباً...",
                transcriptEn: "The fluted conical profile deflected direct downward blows, while the gold koftgari calligraphic inscriptions inspired steadfast courage..."
            )
        ),

        // 3. ALQ-SWD-002: Zulfiqar Sword
        Artifact(
            id: "ALQ-SWD-002",
            slug: "zulfiqar-sword",
            itemCode: "SWD-OTT-16",
            imageName: "model-Zulfiqar_Sword.png",
            title: LocalizedText(ar: "سيف ذو الفقار التاريخي", en: "Zulfiqar Sword Artifact"),
            subtitle: LocalizedText(ar: "سيف عثماني مرصع بالذهب (القرن 16-17 م)", en: "Ottoman ceremonial sword, 16th–17th century."),
            category: .artifact,
            categoryLabel: LocalizedText(ar: "الأسلحة والقطع الحربية", en: "Artifact"),
            period: LocalizedText(ar: "القرن السادس عشر - السابع عشر الميلادي", en: "16th–17th century"),
            creator: LocalizedText(ar: "صناع السلاح الإمبراطوري في إسطنبول", en: "Imperial Armoury Craftsmen"),
            institution: LocalizedText(ar: "مجموعة الأسلحة الإسلامية • علقمي", en: "Alqami Islamic Arms & Armour Collection"),
            dimensions: ArtifactDimensions(heightCm: 96.0, widthCm: 14.0, depthCm: 5.5, weightKg: 0.98, rawText: "الطول الكلي: 96 سم • وزن النصل: 980 غرام"),
            material: LocalizedText(ar: "فولاذ دمشقي ووتز، ذهب عيار 24 مطروق، عاج طبيعي", en: "Pattern-welded Wootz steel, 24k gold koftgari inlay, ivory"),
            condition: LocalizedText(ar: "حد السيف ناصع، خالي من الأكسدة، الغمد الخشبي مكسو بالجلد المخملي", en: "Mint preserved blade edge, wood scabbard bound in crimson velvet"),
            delivery: LocalizedText(ar: "شحن مؤمّن برقم تتبع خاص وصندوق خشبي مبطن بالساتان.", en: "Insured courier dispatch in satin-lined hardwood chest."),
            assembly: LocalizedText(ar: "مرفق بحامل حائطي مغناطيسي معتمد للعرض الأفقي أو المائل.", en: "Supplied with magnetic spatial wall mounting brackets."),
            description: LocalizedText(
                ar: "سيف تاريخي احتفالي مستوحى من طراز ذي الفقار الشهير، مصوغ من الفولاذ الدمشقي الجوهري، مع مقبض مطعم بالعاج ونصل منقوش بآيات قرآنية مطلية بالذهب الخالص.",
                en: "Historic ceremonial curved scimitar forged from folded Damascus crucible steel, decorated with Quranic calligraphic cartouches inlaid with 24k gold, and ivory hilt."
            ),
            historicalContext: LocalizedText(
                ar: "يعد ذو الفقار رمزاً عالمياً للعدالة والشجاعة والفروسية في الثقافة العربية والإسلامية، وتوارثت الأجيال تصميم نصله المزدوج في المخطوطات والرايات الحربية.",
                en: "Zulfiqar stands as an enduring emblem of justice, courage, and virtue across Islamic civilization, reflected across manuscripts and royal heraldry."
            ),
            rating: 4.8,
            reviewsCount: 28,
            priceEstimateUSD: 165,
            model: ModelSpec(
                usdzFilename: "Zulfiqar_Sword.usdz",
                glbFilename: "Zulfiqar_Sword.glb",
                scale: 1.2,
                archetype: .curvedSword,
                primaryColorHex: "#7A8288",
                secondaryColorHex: "#E5C07B",
                roughness: 0.22,
                metallic: 0.95
            ),
            audio: AudioNarration(
                titleAr: "رمزية سيف ذي الفقار في تاريخ الفروسية والأدب العربي",
                titleEn: "Symbolism of Zulfiqar in Arabic Literature and Lore",
                narratorAr: "إذاعة التراث الثقافي",
                narratorEn: "Cultural Heritage Broadcast",
                durationSec: 175,
                transcriptAr: "نصل ذي الفقار لم يكن مجرد سلاح قتال، بل تحول في الوجدان الشعبي إلى راية ترفع لواء الشجاعة والحق...",
                transcriptEn: "Zulfiqar transcended being an instrument of battle to become a transcendent moral beacon of honor, valor, and righteousness..."
            )
        ),

        // 4. ALQ-MAP-001: Babylonian Map of the World
        Artifact(
            id: "ALQ-MAP-001",
            slug: "babylonian-map-of-the-world",
            itemCode: "MAP-BAB-001",
            imageName: "model-babylonian_map_of_the_world_tablet_-_imago_mundi.png",
            title: LocalizedText(ar: "خريطة بابل للعالم (إيماجو موندي)", en: "Babylonian Map of the World"),
            subtitle: LocalizedText(ar: "أقدم خريطة جغرافية وفلكية في تاريخ البشرية (القرن 6 ق.م)", en: "Earliest known world map tablet, 6th century BCE."),
            category: .history,
            categoryLabel: LocalizedText(ar: "تراث بلاد الرافدين", en: "History"),
            period: LocalizedText(ar: "القرن السادس قبل الميلاد (بابل)", en: "6th century BCE"),
            creator: LocalizedText(ar: "كاهن بابلي فلكي مجهول", en: "Babylonian Astronomer-Priest"),
            institution: LocalizedText(ar: "المتحف البريطاني (BM 92687) • مستودع علقمي", en: "British Museum • Alqami Spatial Vault"),
            dimensions: ArtifactDimensions(heightCm: 12.2, widthCm: 8.2, depthCm: 2.4, weightKg: 0.42, rawText: "12.2 × 8.2 × 2.4 سم"),
            material: LocalizedText(ar: "طين بابلي مفخور طبيعي، خط مسماري محفور بدقة", en: "Baked alluvial clay, incised cuneiform inscription"),
            condition: LocalizedText(ar: "سليمة جزئياً مع ثبات كامل للهيكل الطيني التاريخي", en: "Partially intact with stable clay substrate"),
            delivery: LocalizedText(ar: "شحن في كبسولة مبطنة بطبقات الرغوة العازلة مع رصد الرطوبة.", en: "Dispatched in humidity-monitored archival vault."),
            assembly: LocalizedText(ar: "حامل تثبيت شفاف يعرض الوجهين الأمامي والخلفي للوح.", en: "Double-sided transparent display bracket."),
            description: LocalizedText(
                ar: "لوح طيني تاريخي فريد يمثل خريطة بابل للعالم القديم، حيث تظهر بابل كمستطيل في المركز يمر به نهر الفرات، وتحيط بها الدائرة المائية المحيطية المسماة 'نهر المرارة' وجزر أسطورية مثلثة.",
                en: "The Imago Mundi clay tablet from ancient Mesopotamia. Depicts Babylon as the center of the world bisected by the Euphrates and encircled by the Bitter Ocean."
            ),
            historicalContext: LocalizedText(
                ar: "اكتُشف في موقع سيبار جنوب بغداد، ويعكس الفلسفة الكونية لبلاد ما بين النهرين في ربط الجغرافيا المادية بالأساطير الكونية وأبراج السماء.",
                en: "Discovered at Sippar near Baghdad, reflecting Mesopotamian cosmology uniting physical geography, sacred topography, and celestial myth."
            ),
            rating: 4.8,
            reviewsCount: 42,
            priceEstimateUSD: 180,
            model: ModelSpec(
                usdzFilename: "babylonian_map_of_the_world_tablet_-_imago_mundi.usdz",
                glbFilename: "babylonian_map_of_the_world_tablet_-_imago_mundi.glb",
                scale: 1.3,
                archetype: .worldTablet,
                primaryColorHex: "#A8896C",
                secondaryColorHex: "#70563E",
                roughness: 0.9,
                metallic: 0.05
            ),
            audio: AudioNarration(
                titleAr: "شرح فلكي وجغرافي لأقاليم لوح العالم البابلي",
                titleEn: "Cosmological Analysis of the Babylonian World Tablet",
                narratorAr: "مركز دراسات بلاد الرافدين",
                narratorEn: "Mesopotamian Studies Center",
                durationSec: 140,
                transcriptAr: "في هذا اللوح، بابل تقع في مركز الدائرة الكونية، ويحيط بها النهر المر كإطار يربط الأرض المعمورة بجزر السماء...",
                transcriptEn: "In this tablet, Babylon lies at the cosmic center, surrounded by the Bitter Ocean linking known lands with uncharted realms..."
            )
        ),

        // 5. ALQ-TAB-005: Old Babylonian Cuneiform Tablet S264
        Artifact(
            id: "ALQ-TAB-005",
            slug: "old-babylonian-cuneiform-tablet",
            itemCode: "TAB-BAB-S264",
            imageName: "model-old-babylonian_cuneiform_tablet_s264.png",
            title: LocalizedText(ar: "لوح مسماري بابلي قديم (S264)", en: "Old Babylonian Cuneiform Tablet"),
            subtitle: LocalizedText(ar: "لوح عقود ومعاملات اقتصادية من طين الرافدين (1900 ق.م)", en: "Administrative Cuneiform Tablet, c. 1900 BCE"),
            category: .history,
            categoryLabel: LocalizedText(ar: "تراث بلاد الرافدين", en: "History"),
            period: LocalizedText(ar: "1900–1600 قبل الميلاد (العصر البابلي القديم)", en: "c. 1900–1600 BCE"),
            creator: LocalizedText(ar: "كاتب سومري بابلي رسمي", en: "Royal Scribe of Larsa"),
            institution: LocalizedText(ar: "مجموعة المسماريات البابلية • علقمي", en: "Mesopotamian Collection • Alqami"),
            dimensions: ArtifactDimensions(heightCm: 8.5, widthCm: 5.2, depthCm: 2.0, weightKg: 0.18, rawText: "8.5 × 5.2 × 2.0 سم"),
            material: LocalizedText(ar: "طين نيلي مفخور، حفر بقلم القصب المسماري", en: "Baked clay, reed stylus cuneiform script"),
            condition: LocalizedText(ar: "كامل الأحرف والرموز بحالة ممتازة دون كسور", en: "Intact inscriptions with pristine seal rollings"),
            delivery: LocalizedText(ar: "كبسولة أرشيفية مفرغة من الأكسجين لحفظ الطين القديم.", en: "Nitrogen-flushed archival display capsule."),
            assembly: LocalizedText(ar: "حامل مكتبي مائل للعرض ثلاثي الأبعاد.", en: "Angled desktop presentation easel."),
            description: LocalizedText(
                ar: "لوح طيني مفخور بحجم قبضة اليد يوثق حسابات القمح والزيوت مع أختام أسطوانية ضاغطة على الجوانب، مكتوب بالخط المسماري البابلي القديم الواضح.",
                en: "Hand-sized baked clay administrative tablet recording grain and oil disbursements, impressed with royal cylinder seal rolling."
            ),
            historicalContext: LocalizedText(
                ar: "كانت هذه الألواح تُحفظ أحياناً داخل أظرف طينية خاصة لا تُفتح إلا عند النزاع أمام القضاة في ساحة المعبد.",
                en: "Frequently encased within clay envelopes bearing duplicate text, opened only before temple magistrates to adjudicate disputes."
            ),
            rating: 4.6,
            reviewsCount: 17,
            priceEstimateUSD: 95,
            model: ModelSpec(
                usdzFilename: "old-babylonian_cuneiform_tablet_s264.usdz",
                glbFilename: "old-babylonian_cuneiform_tablet_s264.glb",
                scale: 1.2,
                archetype: .cuneiformClay,
                primaryColorHex: "#9E846A",
                secondaryColorHex: "#5E4A37",
                roughness: 0.95,
                metallic: 0.02
            ),
            audio: AudioNarration(
                titleAr: "كيف كان يكتب السومريون والبابليون بالقلم المسماري على الطين",
                titleEn: "Deciphering the Mesopotamian Stylus: Writing on Clay",
                narratorAr: "قسم الآثار واللغات الشرقية",
                narratorEn: "Ancient Languages Faculty",
                durationSec: 130,
                transcriptAr: "الكاتب البابلي يمسك قلم القصب بزاوية مائلة، ويضغط رأسه المثلث برفق لإنتاج علامات الإسفين المتشابكة...",
                transcriptEn: "The Babylonian scribe angled the beveled reed stylus, pressing the triangular head into pliable wet clay..."
            )
        ),

        // 6. ALQ-BWL-006: Saqakhane Sacred Bronze Bowl
        Artifact(
            id: "ALQ-BWL-006",
            slug: "saqakhane-sacred-bowl",
            itemCode: "BWL-SAQ-18",
            imageName: "model-saqakhane_bowl.png",
            title: LocalizedText(ar: "طاسة سقاخانة برونزية أثرية", en: "Saqakhane Sacred Bronze Bowl"),
            subtitle: LocalizedText(ar: "وعاء ماء تراثي منقوش بآيات الشفاء والأدعية (القرن 18 م)", en: "Engraved Bronze Water Vessel, 18th Century"),
            category: .artifact,
            categoryLabel: LocalizedText(ar: "المعادن الإسلامية", en: "Artifact"),
            period: LocalizedText(ar: "القرن الثامن عشر الميلادي", en: "18th Century"),
            creator: LocalizedText(ar: "حرفيو النحاس والبرونز في أصفهان", en: "Isfahan Bronze Masters"),
            institution: LocalizedText(ar: "مجموعة الأواني الإسلامية • علقمي", en: "Islamic Metalwork Collection • Alqami"),
            dimensions: ArtifactDimensions(heightCm: 6.2, widthCm: 18.5, depthCm: 18.5, weightKg: 0.68, rawText: "القطر: 18.5 سم • العمق: 6.2 سم"),
            material: LocalizedText(ar: "برونز مسبوك ومطروق يدوياً، حفر إزميل دقيق", en: "Hand-chiseled cast bronze with natural patina"),
            condition: LocalizedText(ar: "برونز أصيل مع طبقة زنجار خضراء تاريخية طبيعية", en: "Pristine historic bronze patina and crisp inscriptions"),
            delivery: LocalizedText(ar: "حقيبة مبطنة بالحرير للمحافظة على معدن البرونز.", en: "Silk-lined presentation box."),
            assembly: LocalizedText(ar: "حلقة تثبيت دائرية ثلاثية الأبعاد.", en: "Circular museum ring mount."),
            description: LocalizedText(
                ar: "وعاء برونزي مقدس من أروقة السقاخانة، محفور من الداخل والخارج بآيات الشفاء وسور قرآنية بخط الثلث المتقن، مع مركز يحمل قبة شمسية بارزة.",
                en: "Historic bronze drinking bowl used at public water fountains (Saqakhane), engraved inside and out with Quranic healing verses and central boss."
            ),
            historicalContext: LocalizedText(
                ar: "كانت السقاخانات محطات تضامن اجتماعي وروحاني في الأزقة التراثية تروي عطش الغرباء والفقراء بالمياه الباردة المعطرة بماء الورد.",
                en: "Public fountains stood at street corners as enduring acts of social solidarity and spiritual charity, offering rose-scented cold water."
            ),
            rating: 4.7,
            reviewsCount: 23,
            priceEstimateUSD: 110,
            model: ModelSpec(
                usdzFilename: "saqakhane_bowl.usdz",
                glbFilename: "saqakhane_bowl.glb",
                scale: 1.0,
                archetype: .bronzeBowl,
                primaryColorHex: "#9E7842",
                secondaryColorHex: "#C5A059",
                roughness: 0.4,
                metallic: 0.85
            ),
            audio: AudioNarration(
                titleAr: "حكايات السقاخانة وتقاليد سقاية الماء في المدن التراثية",
                titleEn: "Lore of the Saqakhane: The Tradition of Consecrated Water",
                narratorAr: "حكواتي التراث البغدادي",
                narratorEn: "Baghdad Heritage Archives",
                durationSec: 145,
                transcriptAr: "كان المار يمسك هذه الطاسة بحبلها النحاسي، ويشرب الماء العذب ويدعو لمن أوقف السقاية بالرحمة...",
                transcriptEn: "Travelers would raise the bowl chained to the brass grill, drinking cool water while offering prayers..."
            )
        ),

        // 7. ALQ-MHR-007: Prayer Niche Mihrab
        Artifact(
            id: "ALQ-MHR-007",
            slug: "prayer-niche-mihrab",
            itemCode: "MHR-KAS-14",
            imageName: "model-prayer_niche_mihrab.png",
            title: LocalizedText(ar: "محراب الصلاة الإسلامي المقرنص", en: "Prayer Niche Mihrab"),
            subtitle: LocalizedText(ar: "محراب مزخرف بالفسيفساء الخزفية والخط الثلث (القرن 14 م)", en: "Glazed Ceramic Architectural Mihrab, 14th Century"),
            category: .islamicArt,
            categoryLabel: LocalizedText(ar: "العمارة والفنون الإسلامية", en: "Islamic Art"),
            period: LocalizedText(ar: "القرن الرابع عشر الميلادي (العصر الإيلخاني)", en: "14th Century"),
            creator: LocalizedText(ar: "أساتذة الخزف في كاشان", en: "Kashan Master Ceramists"),
            institution: LocalizedText(ar: "متحف الفن الإسلامي • مستودع علقمي", en: "Museum of Islamic Art Collection"),
            dimensions: ArtifactDimensions(heightCm: 110.0, widthCm: 65.0, depthCm: 32.0, weightKg: 85.0, rawText: "الارتفاع: 110 سم • العرض: 65 سم"),
            material: LocalizedText(ar: "خزف مزجج بريق معدني، أصباغ كوبالت وفيروز، جبس تراثي", en: "Luster-glazed ceramic, cobalt and turquoise oxides"),
            condition: LocalizedText(ar: "البريق المعدني والزخارف النباتية الهندسية بحالة ممتازة", en: "Luster glaze and arabesque flora in superb preservation"),
            delivery: LocalizedText(ar: "نقل مع حماية مضاعفة في صندوق خشبي معزول ومؤمّن.", en: "Crated in shock-absorbing timber frame."),
            assembly: LocalizedText(ar: "قابل للتعليق على الحائط أو التثبيت العمودي في الفضاء الحقيقي.", en: "Can be wall-mounted or anchored spatially in room AR."),
            description: LocalizedText(
                ar: "تحفة معمارية إسلامية من بلاط الفسيفساء الخزفي المزجج بلوني الفيروزي واللازوردي مع آية الكرسي بخط الثلث المورق حول إطار القوس المعقود المقرنص.",
                en: "Architectural prayer niche adorned with turquoise and cobalt glazed mosaic tiles, framed with Quranic Ayatul Kursi in floriated Thuluth calligraphy."
            ),
            historicalContext: LocalizedText(
                ar: "يمثل قمة ما وصل إليه فن الخزف القاشاني، حيث كانت المساجد تُزين بهذه المحاريب لتشع بالضوء والروحانية في ساعات الصلاة.",
                en: "Represents the summit of Islamic mosaic faience, engineered so flickering oil lamps illuminated the shimmering metallic luster glazes."
            ),
            rating: 4.9,
            reviewsCount: 31,
            priceEstimateUSD: 310,
            model: ModelSpec(
                usdzFilename: "prayer_niche_mihrab.usdz",
                glbFilename: "prayer_niche_mihrab.glb",
                scale: 0.85,
                archetype: .prayerMihrab,
                primaryColorHex: "#1565C0",
                secondaryColorHex: "#00897B",
                roughness: 0.25,
                metallic: 0.45
            ),
            audio: AudioNarration(
                titleAr: "هندسة الضوء والروحانية في محاريب العمارة الإسلامية",
                titleEn: "Sacred Geometry & Luminosity in Islamic Architectural Niches",
                narratorAr: "مركز بحوث الفنون الإسلامية",
                narratorEn: "Islamic Arts Research Forum",
                durationSec: 155,
                transcriptAr: "تجاويف المحراب تعمل كمضخم صوتي طبيعي لقراءة الإمام، بينما تعكس الزخارف الفيروزية الضوء في محراب الصلاة...",
                transcriptEn: "The niche geometry amplified the imam's recitation acoustic resonance while the turquoise luster tiles refracted ambient light..."
            )
        ),

        // 8. ALQ-STL-008: Stela of Hammurabi
        Artifact(
            id: "ALQ-STL-008",
            slug: "stela-of-hammurabi",
            itemCode: "STL-HAM-1750",
            imageName: "model-stela_of_hammurabi_replica.png",
            title: LocalizedText(ar: "مسلة شريعة حمورابي البابلية", en: "Stela of Hammurabi Code"),
            subtitle: LocalizedText(ar: "أقدم شريعة قانونية متكاملة مكتوبة في التاريخ (1750 ق.م)", en: "Old Babylonian Law Code Replica, c. 1750 BCE"),
            category: .history,
            categoryLabel: LocalizedText(ar: "تراث بلاد الرافدين", en: "History"),
            period: LocalizedText(ar: "1792–1750 قبل الميلاد (بابل)", en: "c. 1750 BCE"),
            creator: LocalizedText(ar: "نحاتو القصر الملكي البابلي في عهد الملك حمورابي", en: "Royal Sculptors of King Hammurabi"),
            institution: LocalizedText(ar: "مستودع علقمي للمنحوتات الأثرية", en: "Alqami Antiquities Vault"),
            dimensions: ArtifactDimensions(heightCm: 75.0, widthCm: 25.0, depthCm: 20.0, weightKg: 45.0, rawText: "الارتفاع: 75 سم • القاعدة: 25 × 20 سم"),
            material: LocalizedText(ar: "ديوريت أسود مصقول، نقش مسماري أكدي غائر", en: "Polished black basalt/diorite, incised Akkadian cuneiform"),
            condition: LocalizedText(ar: "نسخة متحفية ملموسة بنقوش واضحة مطابقة للأصلية", en: "Museum-grade replica with crisp relief sculpture"),
            delivery: LocalizedText(ar: "شحن مصفح على منصة خشبية محمية.", en: "Heavy-duty palletized courier transport."),
            assembly: LocalizedText(ar: "قاعدة تثبيت حجرية مانعة للانزلاق.", en: "Weighted stone anti-slip plinth."),
            description: LocalizedText(
                ar: "منحوتة تاريخية شامخة من حجر الديوريت الأسود، يظهر في أعلاها الملك حمورابي وهو يتلقى شريعة العدل من إله الشمس شمش، وتحتها 282 مادة قانونية بليغة.",
                en: "Monumental black diorite stela depicting King Hammurabi receiving laws from Shamash the sun god, inscribed with 282 legal edicts in cuneiform."
            ),
            historicalContext: LocalizedText(
                ar: "أُريد للمسلة أن تُنصب في الساحات العامة لكي يقرأها المظلوم ويعرف حقه، ومثلت أول محاولة لحكم القانون فوق إرادة الأفراد.",
                en: "Erected publicly in Babylonia so any wronged citizen could read the law and find justice, establishing the cornerstone of statutory law."
            ),
            rating: 4.8,
            reviewsCount: 39,
            priceEstimateUSD: 260,
            model: ModelSpec(
                usdzFilename: "stela_of_hammurabi_replica.usdz",
                glbFilename: "stela_of_hammurabi_replica.glb",
                scale: 0.9,
                archetype: .stoneStele,
                primaryColorHex: "#22252A",
                secondaryColorHex: "#3A3E45",
                roughness: 0.75,
                metallic: 0.1
            ),
            audio: AudioNarration(
                titleAr: "قراءة في نصوص شريعة حمورابي: من عين بعين إلى حماية الضعيف",
                titleEn: "Readings in Hammurabi's Code: Protecting the Vulnerable",
                narratorAr: "مختبر دراسات الآثار الشرقية",
                narratorEn: "Near Eastern Archeology Lab",
                durationSec: 190,
                transcriptAr: "لكي لا يظلم القوي الضعيف، ولكي ينال اليتيم والأرملة حقهما، نقشت كلماتي النفيسة على مسلتي...",
                transcriptEn: "That the strong might not oppress the weak, that the orphan and widow may attain justice, I inscribed my precious words..."
            )
        ),

        // 9. ALQ-BWL-009: Ancient Ceramic Bowl
        Artifact(
            id: "ALQ-BWL-009",
            slug: "ancient-ceramic-bowl",
            itemCode: "BWL-NIS-10",
            imageName: "model-bowl.png",
            title: LocalizedText(ar: "وعاء خزفي إسلامي أثري", en: "Ancient Ceramic Slipware Bowl"),
            subtitle: LocalizedText(ar: "خزف نيسابوري مزجج بحروف كوفية مذهبة (القرن 10 م)", en: "Nishapur Calligraphic Ceramic Bowl, 10th Century"),
            category: .islamicArt,
            categoryLabel: LocalizedText(ar: "الخزف والفنون الإسلامية", en: "Islamic Art"),
            period: LocalizedText(ar: "القرن العاشر الميلادي (العصر الساماني)", en: "10th Century"),
            creator: LocalizedText(ar: "خزافو نيسابور وسمرقند", en: "Nishapur Slipware Potters"),
            institution: LocalizedText(ar: "المتحف الوطني للفنون الخزفية • علقمي", en: "National Ceramic Arts Museum • Alqami"),
            dimensions: ArtifactDimensions(heightCm: 7.0, widthCm: 21.4, depthCm: 21.4, weightKg: 0.65, rawText: "القطر: 21.4 سم • الارتفاع: 7.0 سم"),
            material: LocalizedText(ar: "طين خزفي أبيض، طلاء زجاجي رصاصي شفاف", en: "White earthenware, underglaze slip, clear lead glaze"),
            condition: LocalizedText(ar: "سليم وخالٍ من الشروخ مع رنين نقي للقطعة", en: "Intact with fine micro-crazing and resonant ring"),
            delivery: LocalizedText(ar: "كبسولة رغوية محكمة ضد الصدمات.", en: "Custom form-fitted high density foam casing."),
            assembly: LocalizedText(ar: "حامل ثلاثي الأرجل لعرض الوجه الداخلي.", en: "Three-point acrylic bowl stand."),
            description: LocalizedText(
                ar: "وعاء خزفي ناصع البياض مزجج بطلاء رائق، محلى بحافة خط كوفي أندلسي يحمل حكم وأمثال في الكرم والأدب باللون البني المحروق.",
                en: "Elegantly proportioned white earthenware bowl painted in dark slip with floriated Kufic aphorism on generosity and good manners."
            ),
            historicalContext: LocalizedText(
                ar: "كانت تقنية الخزف النيسابوري تجمع بين نقاء البياض والحكم العربية المرسومة بفرشاة الخطاطين الكبار على حواف الأواني.",
                en: "Nishapur slipware united minimalist white expanses with bold Kufic calligraphy celebrating wisdom and hospitality."
            ),
            rating: 4.5,
            reviewsCount: 16,
            priceEstimateUSD: 75,
            model: ModelSpec(
                usdzFilename: "bowl.usdz",
                glbFilename: "bowl.glb",
                scale: 1.1,
                archetype: .ceramicBowl,
                primaryColorHex: "#D8C29D",
                secondaryColorHex: "#A57A42",
                roughness: 0.28,
                metallic: 0.42
            ),
            audio: AudioNarration(
                titleAr: "سر صناعة الخزف الإسلامي في نيسابور وسمرقند",
                titleEn: "Alchemy of Nishapur Calligraphic Ceramics",
                narratorAr: "متحف الخزف الإسلامي",
                narratorEn: "Islamic Ceramic Guild Lectures",
                durationSec: 150,
                transcriptAr: "تزينت حواف الأواني النيسابورية بالحكم المأثورة بالخط الكوفي المورق لتجمع بين جمال المائدة وغذاء الروح...",
                transcriptEn: "The rims of Nishapur bowls carried proverbs of generosity in floriated Kufic script..."
            )
        ),

        // 10. ALQ-MS-003: Al-Qabasat — Mir Damad
        Artifact(
            id: "ALQ-MS-003",
            slug: "al-qabasat-mir-damad",
            itemCode: "MSS-QAB-1650",
            imageName: "model-model.png",
            title: LocalizedText(ar: "مخطوط القبسات — الميرداماد", en: "Al-Qabasat Manuscript — Mir Damad"),
            subtitle: LocalizedText(ar: "تراث الحكمة والفلسفة الإسلامية المتعالية (1650 م)", en: "Safavid Philosophical Codex, 1650 CE"),
            category: .manuscripts,
            categoryLabel: LocalizedText(ar: "المخطوطات والنوادر", en: "Manuscripts"),
            period: LocalizedText(ar: "1650 م [1061 هـ]", en: "1650 CE [1061 AH]"),
            creator: LocalizedText(ar: "الميرداماد محمد باقر الحسيني الإسترآبادي", en: "Mir Damad (d. 1040 AH)"),
            institution: LocalizedText(ar: "مكتبة مجلس الشورى (4662) • علقمي", en: "Majlis Library Tehran (4662) • Alqami"),
            dimensions: ArtifactDimensions(heightCm: 26.0, widthCm: 17.5, depthCm: 5.0, weightKg: 1.1, rawText: "26.0 × 17.5 سم (344 ورقة)"),
            material: LocalizedText(ar: "ورق قطني، حبر أسود، خط النستعليق، جلد أحمر", en: "Cotton paper, black ink, Nastaliq script, red leather"),
            condition: LocalizedText(ar: "نادرة وسليمة، مجدولة ومذهبة والغلاف جلد أحمر ممتاز", en: "Gold-ruled margins, intact original red leather binding"),
            delivery: LocalizedText(ar: "تغليف حراري مفرغ من الرطوبة مع بطاقة الأرشفة.", en: "Hermetic humidity-monitored archival delivery."),
            assembly: LocalizedText(ar: "جاهز للمعاينة ثلاثية الأبعاد في الغرفة.", en: "Ready for spatial room exploration."),
            description: LocalizedText(
                ar: "كتاب فلسفي كلامي للميرداماد يناقش حدوث العالم وقدمه ومسألة الدهر والزمان، النسخة مجدولة ومذهبة وغلافها جلد أحمر أصيل بنظام التعقيبات التاريخية.",
                en: "Theological and philosophical treatise by Mir Damad discussing cosmos origination, time and eternity (Dahr), in gold-ruled margins and red leather binding."
            ),
            historicalContext: LocalizedText(
                ar: "يعد كتاب القبسات حجر الزاوية في مدرسة أصفهان الفلسفية ونظرية الحدوث الدهري التي جمعت بين البرهان العقلي والنص الشرعي.",
                en: "Al-Qabasat stands as the magnum opus of the School of Isfahan, introducing the concept of Perpetual Creation (Huduth Dahri)."
            ),
            rating: 4.7,
            reviewsCount: 14,
            priceEstimateUSD: 135,
            model: ModelSpec(
                usdzFilename: "model.usdz",
                glbFilename: "model.glb",
                scale: 1.0,
                archetype: .astrolabeInstrument,
                primaryColorHex: "#C59B27",
                secondaryColorHex: "#8B6914",
                roughness: 0.32,
                metallic: 0.9
            ),
            audio: AudioNarration(
                titleAr: "قراءة في فلسفة الزمان والدهر في مخطوط القبسات للميرداماد",
                titleEn: "Time and Eternity in Mir Damad's Al-Qabasat Codex",
                narratorAr: "الجمعية الفلسفية التراثية",
                narratorEn: "Islamic Philosophy Archives",
                durationSec: 165,
                transcriptAr: "يتناول الميرداماد في القبسات علاقة المتغير بالثابت، والزمان بالدهر، والدهر بالسرمد بلغة فلسفية رصينة...",
                transcriptEn: "Mir Damad explores the relation of time (Zaman) to meta-time (Dahr) and eternity (Sarmad)..."
            )
        ),

        // 11. ALQ-MSH-010: Alqami 3D Heritage Sculpture
        Artifact(
            id: "ALQ-MSH-010",
            slug: "alqami-3d-heritage-sculpture",
            itemCode: "MSH-ALQ-3D",
            imageName: "model-meshy-model.png",
            title: LocalizedText(ar: "مجسم تحفة علقمي التراثي", en: "Alqami 3D Heritage Sculpture"),
            subtitle: LocalizedText(ar: "منحوتة هندسية ثلاثية الأبعاد تمثل الهوية الحضارية والمتحفية", en: "Spatial 3D Cultural Geometry Monolith"),
            category: .culture,
            categoryLabel: LocalizedText(ar: "الهوية الثقافية", en: "Culture"),
            period: LocalizedText(ar: "العصر الحديث والتراث المتجدد", en: "Contemporary Spatial Heritage"),
            creator: LocalizedText(ar: "استوديو علقمي للنمذجة الرقمية التراثية", en: "Alqami Spatial Heritage Labs"),
            institution: LocalizedText(ar: "مستودع علقمي الرقمي السحابي", en: "Alqami Cloud Repository"),
            dimensions: ArtifactDimensions(heightCm: 45.0, widthCm: 35.0, depthCm: 35.0, weightKg: 2.4, rawText: "35 × 35 × 45 سم"),
            material: LocalizedText(ar: "راتنج بولي صلب، طلاء ميتاليك نحاسي وذهبي معتق", en: "High-density composite resin, antique bronze-gold patina"),
            condition: LocalizedText(ar: "تحفة جديدة مصنوعة بدقة ميكرونية فائقة", en: "Pristine new condition with museum seal"),
            delivery: LocalizedText(ar: "صندوق أسود فاخر مع قفل مغناطيسي وشهادة الأصالة.", en: "Luxury presentation case with magnetic closure."),
            assembly: LocalizedText(ar: "قاعدة دائرية متوازنة مع إضاءة حافة خافتة.", en: "Integrated weighted circular plinth."),
            description: LocalizedText(
                ar: "مجسم فراغي ثلاثي الأبعاد مصمم بأعلى دقة PBR ليجسد تناغم الفنون الإسلامية والزخارف الهندسية المعقدة في فضاء الواقع المعزز المكاني.",
                en: "A high-fidelity spatial 3D artifact celebrating Islamic geometric harmony, designed with photorealistic PBR textures for visionOS augmented reality."
            ),
            historicalContext: LocalizedText(
                ar: "صُممت هذه المنحوتة الرقمية لتكون جسراً بين التراث المعماري الإسلامي العريق وتقنيات الحوسبة المكانية الحديثة.",
                en: "Sculpted as a bridge between classical Islamic geometric craftsmanship and modern spatial computing."
            ),
            rating: 4.9,
            reviewsCount: 48,
            priceEstimateUSD: 195,
            model: ModelSpec(
                usdzFilename: "meshy-model.usdz",
                glbFilename: "meshy-model.glb",
                scale: 1.0,
                archetype: .damascusDagger,
                primaryColorHex: "#5E6367",
                secondaryColorHex: "#D4AF37",
                roughness: 0.24,
                metallic: 0.94
            ),
            audio: AudioNarration(
                titleAr: "النمذجة ثلاثية الأبعاد للتراث الإسلامي في فضاء الواقع المعزز",
                titleEn: "Spatial 3D Preservation of Islamic Geometric Heritage",
                narratorAr: "مختبر علقمي المكاني",
                narratorEn: "Alqami Spatial Labs",
                durationSec: 150,
                transcriptAr: "تجسد هذه القطعة تلاقي الحرف التراثية الأصيلة مع محركات الإضاءة الفيزيائية الحديثة...",
                transcriptEn: "This piece embodies the convergence of classical heritage artistry with physically based rendering..."
            )
        )
    ]

    // MARK: - Bento Room Hotspots (Matching exact artifact IDs)
    public static let bentoHotspots: [BentoHotspot] = [
        BentoHotspot(
            id: "hs-table",
            xPercent: 0.255,
            yPercent: 0.390,
            artifactId: "ALQ-MAP-001",
            labelAr: "خريطة بابل للعالم (إيماجو موندي)",
            labelEn: "Babylonian Map of the World",
            areaNameAr: "طاولة الفحص الرئيسية",
            areaNameEn: "Main Living Table"
        ),
        BentoHotspot(
            id: "hs-vase",
            xPercent: 0.365,
            yPercent: 0.355,
            artifactId: "ALQ-BWL-009",
            labelAr: "وعاء خزفي إسلامي أثري",
            labelEn: "Ancient Ceramic Slipware Bowl",
            areaNameAr: "وسط الطاولة",
            areaNameEn: "Table Centerpiece"
        ),
        BentoHotspot(
            id: "hs-rug",
            xPercent: 0.130,
            yPercent: 0.710,
            artifactId: "ALQ-MSS-006",
            labelAr: "مخطوط نهج البلاغة",
            labelEn: "Nahj al-Balagha Manuscript",
            areaNameAr: "منصة القراءة التراثية",
            areaNameEn: "Reading Platform"
        ),
        BentoHotspot(
            id: "hs-art",
            xPercent: 0.785,
            yPercent: 0.125,
            artifactId: "ALQ-MHR-007",
            labelAr: "محراب الصلاة الإسلامي المقرنص",
            labelEn: "Prayer Niche Mihrab",
            areaNameAr: "الجدار التراثي المعلق",
            areaNameEn: "Wall Architecture"
        ),
        BentoHotspot(
            id: "hs-credenza",
            xPercent: 0.875,
            yPercent: 0.260,
            artifactId: "ALQ-STL-008",
            labelAr: "مسلة شريعة حمورابي البابلية",
            labelEn: "Stela of Hammurabi Code",
            areaNameAr: "ركن الآثار الكبرى",
            areaNameEn: "Grand Stele Alcove"
        ),
        BentoHotspot(
            id: "hs-lamp",
            xPercent: 0.690,
            yPercent: 0.695,
            artifactId: "ALQ-HLM-004",
            labelAr: "خوذة إسلامية حربية مذهبة",
            labelEn: "Old Islamic Gilded Helmet",
            areaNameAr: "منصة السلاح والدرع",
            areaNameEn: "Armor Pedestal"
        ),
        BentoHotspot(
            id: "hs-stools",
            xPercent: 0.820,
            yPercent: 0.775,
            artifactId: "ALQ-MSH-010",
            labelAr: "مجسم تحفة علقمي التراثي",
            labelEn: "Alqami 3D Heritage Sculpture",
            areaNameAr: "طاولة النوادر ثلاثية الأبعاد",
            areaNameEn: "Spatial Sculpture Display"
        ),
        BentoHotspot(
            id: "hs-sofa",
            xPercent: 0.930,
            yPercent: 0.565,
            artifactId: "ALQ-SWD-002",
            labelAr: "سيف ذو الفقار التاريخي",
            labelEn: "Zulfiqar Sword Artifact",
            areaNameAr: "جدارية السيوف التذكارية",
            areaNameEn: "Memorial Swords Wall"
        )
    ]
}
