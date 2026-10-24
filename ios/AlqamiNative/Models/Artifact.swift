import Foundation
import SwiftUI

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

// MARK: - Artifact Category
public enum ArtifactCategory: String, CaseIterable, Codable, Identifiable {
    case all = "all"
    case manuscripts = "manuscripts"
    case weapons = "weapons"
    case tablets = "tablets"
    case artifacts = "artifacts"

    public var id: String { rawValue }

    public func title(isArabic: Bool) -> String {
        switch self {
        case .all:
            return isArabic ? "الكل" : "All"
        case .manuscripts:
            return isArabic ? "المخطوطات والنوادر" : "Manuscripts"
        case .weapons:
            return isArabic ? "الأسلحة والقطع الحربية" : "Weapons & Armor"
        case .tablets:
            return isArabic ? "الألواح والنقوش" : "Tablets & Inscriptions"
        case .artifacts:
            return isArabic ? "التحف والأواني" : "Heritage Objects"
        }
    }
}

// MARK: - 3D Dimensions
public struct ArtifactDimensions: Codable, Hashable {
    public let heightCm: Double
    public let widthCm: Double
    public let depthCm: Double
    public let weightKg: Double?

    public init(heightCm: Double, widthCm: Double, depthCm: Double, weightKg: Double? = nil) {
        self.heightCm = heightCm
        self.widthCm = widthCm
        self.depthCm = depthCm
        self.weightKg = weightKg
    }

    public func formatted(isArabic: Bool) -> String {
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

// MARK: - 3D Visual Archetype for Procedural Rendering
public enum Artifact3DArchetype: String, Codable {
    case manuscriptBook      // Nahj al-Balagha
    case worldTablet         // Babylonian Map
    case battleHelmet        // Islamic Helmet
    case curvedSword         // Zulfiqar
    case stoneStele          // Hammurabi
    case prayerMihrab        // Mihrab
    case cuneiformClay       // Cuneiform Tablet
    case bronzeBowl          // Saqakhane Bowl
    case ceramicBowl         // Ceramic Bowl
    case astrolabeInstrument // Astronomical Astrolabe
    case damascusDagger      // Damascus Inlaid Dagger
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
    public let title: LocalizedText
    public let subtitle: LocalizedText
    public let category: ArtifactCategory
    public let period: LocalizedText
    public let creator: LocalizedText
    public let institution: LocalizedText
    public let dimensions: ArtifactDimensions
    public let material: LocalizedText
    public let condition: LocalizedText
    public let binding: LocalizedText?
    public let decoration: LocalizedText?
    public let seals: LocalizedText?
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
        title: LocalizedText,
        subtitle: LocalizedText,
        category: ArtifactCategory,
        period: LocalizedText,
        creator: LocalizedText,
        institution: LocalizedText,
        dimensions: ArtifactDimensions,
        material: LocalizedText,
        condition: LocalizedText,
        binding: LocalizedText? = nil,
        decoration: LocalizedText? = nil,
        seals: LocalizedText? = nil,
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
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.period = period
        self.creator = creator
        self.institution = institution
        self.dimensions = dimensions
        self.material = material
        self.condition = condition
        self.binding = binding
        self.decoration = decoration
        self.seals = seals
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

// MARK: - Master Heritage Catalog Data (All 11 Artifacts & Bento Hotspots)
public struct HeritageCatalog {
    public static let artifacts: [Artifact] = [
        // 1. Nahj al-Balagha Illuminated Manuscript
        Artifact(
            id: "ALQ-MSS-006",
            slug: "nahj-al-balagha",
            title: LocalizedText(ar: "مخطوط نهج البلاغة المذهب", en: "Illuminated Nahj al-Balagha Manuscript"),
            subtitle: LocalizedText(ar: "الشيخ الرضي - الناسخ شمس الدين الشيرازي (1022 هـ)", en: "Al-Sharif al-Radi • Calligrapher Shams al-Din al-Shirazi (1022 AH)"),
            category: .manuscripts,
            period: LocalizedText(ar: "1022 هـ / 1613 م (العصر الصفوي)", en: "1022 AH / 1613 CE (Safavid Era)"),
            creator: LocalizedText(ar: "الشريف الرضي (ت 406 هـ) • الناسخ: شمس الدين الشيرازي", en: "Al-Sharif al-Radi • Scribe: Shams al-Din al-Shirazi"),
            institution: LocalizedText(ar: "مكتبة العتبة الرضوية المقدسة (1861) • مستودع علقمي للتراث الرقمي", en: "Astan Quds Razavi Library • Alqami Spatial Heritage Repository"),
            dimensions: ArtifactDimensions(heightCm: 28.5, widthCm: 18.2, depthCm: 6.5, weightKg: 1.4),
            material: LocalizedText(ar: "ورق سمرقندي مجدول ومذهب، حبر كربوني، مداد زنجفري أحمر، جلد طبيعي", en: "Samarkand gold-ruled paper, carbon ink, cinnabar rubrication, natural leather"),
            condition: LocalizedText(ar: "نادرة ومحفوظة بعناية فائقة مع تجليد إسلامي أصيل ومحكم", en: "Exceptional preservation in authentic Islamic tooled leather binding"),
            binding: LocalizedText(ar: "تجليد جلدي إسلامي أصيل مزخرف بنقوش هندسية مذهبة ولسان حماية", en: "Tooled Islamic goatskin binding with flap and gilded arabesque roundels"),
            decoration: LocalizedText(ar: "النسخة مجدولة بالذهب الخالص، وأولها ديباجة شمسية مذهبة وعناوين بالمداد الياقوتي", en: "Illuminated with pure leaf gold, celestial shamsa frontispiece, ruby headers"),
            seals: LocalizedText(ar: "تحتوي على قيود تملكية وأختام وقفية مكتبة العتبة الرضوية برقم 1861", en: "Bears historic ownership seals and endowment inscription no. 1861"),
            description: LocalizedText(
                ar: "نسخة خطية نادرة وفائقة النفاسة من مخطوط نهج البلاغة، تُنسب إلى الشريف الرضي الذي جمع خطب ورسائل وحكم أمير المؤمنين علي بن أبي طالب (ع). تتميز هذه النسخة بخط نسخ متقن ومحلى بجداول الذهب والأزورد الطبيعي، وتعد درة المخطوطات البلاغية الإسلامية.",
                en: "A rare and masterfully illuminated manuscript of Nahj al-Balagha compiled by Al-Sharif al-Radi, containing the sermons, letters, and aphorisms of Imam Ali ibn Abi Talib. Penned in exquisite Naskh script bordered by lapis lazuli and burnished gold leaf."
            ),
            historicalContext: LocalizedText(
                ar: "كُتبت هذه النسخة في ذروة ازدهار فنون الخط والتذهيب في أصفهان وشيراز، واحتفظ بها كبار العلماء حتى استقرت كوقف نفيس في خزانة المخطوطات التراثية.",
                en: "Transcribed at the zenith of Persian and Islamic book illumination arts in Shiraz, held by elite scholars before being endowed into sacred institutional trust."
            ),
            rating: 5.0,
            reviewsCount: 34,
            priceEstimateUSD: 1450,
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

        // 2. Babylonian Map of the World Tablet (Imago Mundi)
        Artifact(
            id: "ALQ-TAB-004",
            slug: "babylonian-map",
            title: LocalizedText(ar: "لوح بابل لخريطة العالم (إيماجو موندي)", en: "Babylonian Map of the World Tablet (Imago Mundi)"),
            subtitle: LocalizedText(ar: "أقدم خريطة جغرافية وفلكية معروفة في تاريخ البشرية", en: "Oldest known geographic and cosmological map in human history"),
            category: .tablets,
            period: LocalizedText(ar: "القرن السادس قبل الميلاد (العصر البابلي الحديث)", en: "6th Century BCE (Neo-Babylonian Era)"),
            creator: LocalizedText(ar: "حكماء وكتبة مدينة سيبار البابلية", en: "Scribes and astronomers of ancient Sippar"),
            institution: LocalizedText(ar: "المتحف البريطاني (BM 92687) • سجلات علقمي التاريخية", en: "The British Museum (BM 92687) • Alqami Historical Records"),
            dimensions: ArtifactDimensions(heightCm: 12.2, widthCm: 8.2, depthCm: 2.8, weightKg: 0.42),
            material: LocalizedText(ar: "طين سومري محروق، نقوش خط مسماري أكدي دقيق", en: "Baked Mesopotamian clay, incised Akkadian cuneiform inscriptions"),
            condition: LocalizedText(ar: "لوح أثري سليم جزئياً مع بقاء الدائرة الجغرافية الكونية بوضوح", en: "Intact central circular cartographic section with visible cuneiform registers"),
            description: LocalizedText(
                ar: "لوح طيني شهير يمثل أقدم خريطة للعالم في التاريخ. يصور نهر الفرات متدفقاً من الشمال عبر بابل إلى البحر المر (الخليج العربي المحيط بالعالم المأهول)، وتتفرع منه ثماني مناطق نائية مثلثية ترمز للأراضي الأسطورية البعيدة.",
                en: "The famous clay tablet representing the world's earliest surviving map. It depicts the Euphrates River flowing from northern mountains through Babylon into the Bitter River ocean, surrounded by triangular outer regions."
            ),
            historicalContext: LocalizedText(
                ar: "اكتُشف في موقع سيبار (أبو حبة) جنوب بغداد، ويعكس الفلسفة الكونية لبلاد ما بين النهرين في ربط الجغرافيا المادية بالأساطير الكونية وأبراج السماء.",
                en: "Discovered at Sippar near Baghdad, reflecting Mesopotamian cosmology uniting physical geography, sacred topography, and celestial myth."
            ),
            rating: 4.9,
            reviewsCount: 28,
            priceEstimateUSD: 890,
            model: ModelSpec(
                usdzFilename: "babylonian_map_of_the_world_tablet_-_imago_mundi.usdz",
                glbFilename: "babylonian_map_of_the_world_tablet_-_imago_mundi.glb",
                scale: 1.0,
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
                transcriptAr: "في هذا اللوح، بابل تقع في مركز الدائرة الكونية، ويحيط بها النهر المر كإطار يربط الأرض المعمورة بجزر السماء المجهولة...",
                transcriptEn: "In this tablet, Babylon lies at the cosmic center, surrounded by the Bitter Ocean linking known lands with uncharted realms..."
            )
        ),

        // 3. Old Islamic Battle Helmet
        Artifact(
            id: "ALQ-HLM-001",
            slug: "old-islamic-helmet",
            title: LocalizedText(ar: "خوذة حربية إسلامية مذهبة", en: "Gilded Islamic Battle Helmet"),
            subtitle: LocalizedText(ar: "خوذة خيالة مصفحة مع أنفية ودرع زرد (القرن 15 م)", en: "Cavalry armored turban helmet with mail aventail (15th Century)"),
            category: .weapons,
            period: LocalizedText(ar: "القرن 15 م (العصر المملوكي / العثماني المبكر)", en: "15th Century CE (Mamluk / Early Ottoman)"),
            creator: LocalizedText(ar: "صناع الدروع السلطانية في بلاد الشام وإسطنبول", en: "Imperial Armourers of Damascus & Istanbul"),
            institution: LocalizedText(ar: "متحف طوب قابي سراي • دار الأسلحة التراثية", en: "Topkapi Palace Museum • Heritage Armory"),
            dimensions: ArtifactDimensions(heightCm: 34.0, widthCm: 22.0, depthCm: 24.5, weightKg: 2.35),
            material: LocalizedText(ar: "صلب دمشقي مقسى، تطعيم بالذهب (طراز كفتكاري)، حلقات زرد حديدية", en: "Tempered damascene steel, Koftgari gold inlay, interlinked iron mail rings"),
            condition: LocalizedText(ar: "حالة ممتازة مع بقاء النقوش القرآنية وكتابات النصر واضحة الملامح", en: "Excellent museum state with crisp Quranic battle inscriptions and nasal bar"),
            description: LocalizedText(
                ar: "خوذة قتالية مخروطية مهيبة، مستوحاة من طراز قبة المسجد (الخوذة العمامة)، ومحفورة بآيات النصر والتمكين ونقوش نباتية دقيقة مطعمة بخيوط الذهب الخالص، مزودة بأنفية متحركة وحلقات زرد تحمي الرقبة والكتفين.",
                en: "An imposing conical turban helmet forged from water-tempered steel, covered in gold-damascened verses of victory and protection. Features an adjustable nasal bar and mail aventail guarding the neck and shoulders."
            ),
            historicalContext: LocalizedText(
                ar: "كانت ترتديها قيادات النخبة في الفرسان، وتجمع بين الحماية الفائقة من ضربات السيوف والرمزية الروحية لثبات المقاتل في الميدان.",
                en: "Worn by elite cavalry commanders, harmonizing impenetrable ballistic protection with profound spiritual symbolism on the battlefield."
            ),
            rating: 4.95,
            reviewsCount: 42,
            priceEstimateUSD: 2100,
            model: ModelSpec(
                usdzFilename: "Old_Islamic_Helmet.usdz",
                glbFilename: "Old_Islamic_Helmet.glb",
                scale: 1.0,
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
                transcriptAr: "الخوذة العمامة صُممت بحيث تُشتت طاقة الضربة الهابطة من السيوف المستقيمة، بينما يمنح التذهيب الكفتكاري بريقاً نفسياً مهيباً في ساحة اللقاء...",
                transcriptEn: "The fluted conical profile deflected direct downward blows, while the gold koftgari calligraphic inscriptions inspired steadfast courage..."
            )
        ),

        // 4. Zulfiqar Sword
        Artifact(
            id: "ALQ-SWD-005",
            slug: "zulfiqar-sword",
            title: LocalizedText(ar: "سيف ذو الفقار التاريخي الفولاذي", en: "Historic Zulfiqar Double-Bladed Sword"),
            subtitle: LocalizedText(ar: "سيف الشهامة والفروسية الإسلامية ذو النصلين", en: "The iconic bifurcated blade of Islamic chivalry"),
            category: .weapons,
            period: LocalizedText(ar: "القرن 10 - 16 م (تراث الفروسية الإسلامية)", en: "10th - 16th Century CE (Islamic Chivalry Heritage)"),
            creator: LocalizedText(ar: "أساتذة الحدادة والسيوف في الكوفة وخراسان", en: "Master Swordsmiths of Kufa & Khorasan"),
            institution: LocalizedText(ar: "خزانة التراث الحربي التاريخي • علقمي", en: "Islamic Chivalry Vaults • Alqami"),
            dimensions: ArtifactDimensions(heightCm: 98.0, widthCm: 14.0, depthCm: 5.5, weightKg: 1.65),
            material: LocalizedText(ar: "فولاذ جوهري ووتز (Wootz Steel)، مقبض عاجي، صلب مذهب، غمد جلدي مطرز", en: "Crucible Wootz steel, ivory-inlaid hilt, gold damascened quillons, velvet scabbard"),
            condition: LocalizedText(ar: "نصل محفوظ بحالة براقة مع تموجات الجوهر الفولاذي البديعة", en: "Pristine blade showcasing natural crystalline watering patterns of authentic wootz"),
            description: LocalizedText(
                ar: "السيف الإسلامي الخالد بنصله المزدوج الشهير، منقوش عليه العبارة التاريخية المأثورة: 'لا فتى إلا علي ولا سيف إلا ذو الفقار'. صُنع من فولاذ الجوهر عالي الكربون الذي يجمع بين الصلابة القاطعة والمرونة الفريدة.",
                en: "The historic bifurcated blade associated with legendary chivalry, inscribed with the timeless motto: 'There is no knight like Ali, and no sword like Zulfiqar.' Forged from legendary high-carbon wootz steel."
            ),
            historicalContext: LocalizedText(
                ar: "يعد ذو الفقار رمزاً عالمياً للعدالة والشجاعة والفروسية في الثقافة العربية والإسلامية، وتوارثت الأجيال تصميم نصله المزدوج في المخطوطات والرايات الحربية.",
                en: "Zulfiqar stands as an enduring emblem of justice, courage, and virtue across Islamic civilization, reflected across manuscripts and royal heraldry."
            ),
            rating: 5.0,
            reviewsCount: 56,
            priceEstimateUSD: 3200,
            model: ModelSpec(
                usdzFilename: "Zulfiqar_Sword.usdz",
                glbFilename: "Zulfiqar_Sword.glb",
                scale: 1.0,
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
                transcriptAr: "نصل ذي الفقار لم يكن مجرد سلاح قتال، بل تحول في الوجدان الشعبي إلى راية ترفع لواء الشجاعة والحق ونصرة المظلوم...",
                transcriptEn: "Zulfiqar transcended being an instrument of battle to become a transcendent moral beacon of honor, valor, and righteousness..."
            )
        ),

        // 5. Code of Hammurabi Stele
        Artifact(
            id: "ALQ-STE-003",
            slug: "hammurabi-stele",
            title: LocalizedText(ar: "مسلة شريعة حمورابي التذكارية", en: "Code of Hammurabi Commemorative Stele"),
            subtitle: LocalizedText(ar: "أقدم وأشمل مدونة تشريعية قانونية متكاملة في التاريخ", en: "The foundational monument of ancient jurisprudence and statutory law"),
            category: .tablets,
            period: LocalizedText(ar: "حوالي 1754 ق.م (العصر البابلي القديم)", en: "c. 1754 BCE (Old Babylonian Kingdom)"),
            creator: LocalizedText(ar: "الملك حمورابي، سادس ملوك سلالة بابل الأولى", en: "King Hammurabi, 6th ruler of Babylon's First Dynasty"),
            institution: LocalizedText(ar: "متحف اللوفر (باريس) • النسخة الأثرية الموثقة في علقمي", en: "Musée du Louvre • Documented Archeological Cast in Alqami"),
            dimensions: ArtifactDimensions(heightCm: 225.0, widthCm: 65.0, depthCm: 55.0, weightKg: 450.0),
            material: LocalizedText(ar: "حجر الديوريت الأسود المصقول، خط مسماري أكدي غائر", en: "Polished black basalt diorite, deeply incised Akkadian cuneiform registers"),
            condition: LocalizedText(ar: "مسلة تذكارية شاهقة محفوظة بنقوشها القانونية الـ 282 كاملة", en: "Towering monolith preserved with all 282 legal provisions and relief header intact"),
            description: LocalizedText(
                ar: "مسلة مهيبة من حجر الديوريت الأسود، يتوجها نحت بارز يصور الملك حمورابي وهو يتسلم رموز العدالة والشريعة (العصا والحلقة) من إله الشمس والعدالة شمش. ونُقش تحتها 282 مادة قانونية تنظم العدالة والتجارة وحقوق الأفراد.",
                en: "A monumental stele of black diorite. The top bas-relief depicts King Hammurabi receiving the sceptre and ring of sovereignty from Shamash, god of justice, above 282 meticulously chiseled legal edicts."
            ),
            historicalContext: LocalizedText(
                ar: "أُريد للمسلة أن تُنصب في الساحات العامة لكي يقرأها المظلوم ويعرف حقه، ومثلت أول محاولة لحكم القانون فوق إرادة الأفراد العشوائية.",
                en: "Erected publicly in Babylonia so any wronged citizen could read the law and find justice, establishing the cornerstone of statutory law."
            ),
            rating: 4.88,
            reviewsCount: 38,
            priceEstimateUSD: 1800,
            model: ModelSpec(
                usdzFilename: "stela_of_hammurabi_replica.usdz",
                glbFilename: "stela_of_hammurabi_replica.glb",
                scale: 1.0,
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
                transcriptEn: "That the strong might not oppress the weak, that the orphan and widow may attain justice, I inscribed my precious words upon my stele..."
            )
        ),

        // 6. Prayer Niche Mihrab
        Artifact(
            id: "ALQ-MIH-007",
            slug: "prayer-niche-mihrab",
            title: LocalizedText(ar: "محراب وقبلية إسلامية كاشانية", en: "Gilded Ceramic Mosaic Prayer Mihrab"),
            subtitle: LocalizedText(ar: "تحفة الزخرفة الهندسية والخط الثلث القرآني (القرن 14 م)", en: "Masterwork of luster tilework and Thuluth Quranic calligraphy (14th C.)"),
            category: .artifacts,
            period: LocalizedText(ar: "القرن 14 م (العصر الإيلخاني المتقدم)", en: "14th Century CE (Ilkhanid Architecture)"),
            creator: LocalizedText(ar: "خزافو ومهندسو كاشان الكبار (آل أبي طاهر)", en: "Master Ceramists of Kashan (Abu Tahir atelier)"),
            institution: LocalizedText(ar: "متحف المتروبوليتان للفنون • مستودع علقمي المعماري", en: "The Metropolitan Museum of Art • Alqami Architectural Repository"),
            dimensions: ArtifactDimensions(heightCm: 290.0, widthCm: 185.0, depthCm: 32.0, weightKg: 280.0),
            material: LocalizedText(ar: "بلاط قاشاني فسيفسائي مزجج بريق معدني، خط ثلث بارز، ألوان فيروزية وكوبالتية", en: "Faience mosaic tilework, luster-glaze, relief Thuluth script, turquoise and cobalt glazes"),
            condition: LocalizedText(ar: "محراب تاريخي مكتمل بآية الكرسي المنقوشة في إطاره الخارجي البديع", en: "Magnificently preserved architectural niche framed by the Throne Verse (Ayat al-Kursi)"),
            description: LocalizedText(
                ar: "محراب مسجد تحفة في العمارة الإسلامية، يتألف من آلاف قطع الفسيفساء الخزفية المقطوعة يدوياً بتدرجات الأزرق الفيروزي والكوبالتي. يحيط به شريط خطي بالثلث القرآني البارز مع ديباجة شمسية في الطاسة المجوفة توجه قلوب المصلين نحو الكعبة المشرفة.",
                en: "A monumental prayer niche composed of hand-cut glazed ceramic mosaics in radiant turquoise, cobalt blue, and golden lusterware, encircled by Quranic calligraphic friezes pointing toward Mecca."
            ),
            historicalContext: LocalizedText(
                ar: "يمثل قمة ما وصل إليه فن الخزف القاشاني في بلاد فارس والعراق، حيث كانت المساجد تُزين بهذه المحاريب لتشع بالضوء والروحانية في ساعات الصلاة.",
                en: "Represents the summit of Islamic mosaic faience, engineered so flickering oil lamps illuminated the shimmering metallic luster glazes."
            ),
            rating: 4.96,
            reviewsCount: 45,
            priceEstimateUSD: 3600,
            model: ModelSpec(
                usdzFilename: "prayer_niche_mihrab.usdz",
                glbFilename: "prayer_niche_mihrab.glb",
                scale: 1.0,
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
                transcriptEn: "The niche geometry amplified the imam's recitation acoustic resonance while the turquoise luster tiles refracted ambient morning light..."
            )
        ),

        // 7. Old Babylonian Cuneiform Tablet S264
        Artifact(
            id: "ALQ-CUN-002",
            slug: "cuneiform-tablet",
            title: LocalizedText(ar: "لوح مسماري بابلي قديم S264", en: "Old Babylonian Cuneiform Tablet S264"),
            subtitle: LocalizedText(ar: "وثيقة اقتصادية وتجارية بالخط المسماري الأكدي السليم", en: "Pristine economic and legal covenant in Akkadian cuneiform script"),
            category: .tablets,
            period: LocalizedText(ar: "حوالي 1800 ق.م (سلالة بابل الأولى)", en: "c. 1800 BCE (First Dynasty of Babylon)"),
            creator: LocalizedText(ar: "كتبة المعابد البابلية الرسمية", en: "Temple Scribes of Babylon"),
            institution: LocalizedText(ar: "المتحف العراقي (بغداد) • قسم الآثار المسمارية", en: "The Iraq Museum (Baghdad) • Cuneiform Antiquities Division"),
            dimensions: ArtifactDimensions(heightCm: 9.5, widthCm: 5.4, depthCm: 2.2, weightKg: 0.18),
            material: LocalizedText(ar: "طين نهري نقي غير محروق (محفوظ بحرارة الشمس الطبيعية)", en: "Fine alluvial river clay, sun-cured, impressed with stylus reed incisions"),
            condition: LocalizedText(ar: "نقوش مسمارية غائرة وحادة الحواف مع بصمات أختام أسطوانية حية", en: "Crisp reed-stylus wedges with intact cylinder seal impressions across the reverse"),
            description: LocalizedText(
                ar: "لوح طيني إداري وقانوني أصيل كُتب بقلم البوص المثلث على الطين الرطب قبل تجفيفه. يوثق اتفاقاً تجارياً وعقداً مع شهود، ويعد نموذجاً رائعاً للحياة اليومية المنظمة في مدن بابل القديمة.",
                en: "An authentic cuneiform administrative contract stamped into moist alluvial clay with a reed stylus, recording commodity transfers and witness signatures from the dawn of recorded economic law."
            ),
            historicalContext: LocalizedText(
                ar: "كانت هذه الألواح تُحفظ أحياناً داخل أظرف طينية خاصة لا تُفتح إلا عند النزاع أمام القضاة في ساحة المعبد.",
                en: "Frequently encased within clay envelopes bearing duplicate text, opened only before temple magistrates to adjudicate disputes."
            ),
            rating: 4.85,
            reviewsCount: 19,
            priceEstimateUSD: 520,
            model: ModelSpec(
                usdzFilename: "old-babylonian_cuneiform_tablet_s264.usdz",
                glbFilename: "old-babylonian_cuneiform_tablet_s264.glb",
                scale: 1.0,
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
                transcriptEn: "The Babylonian scribe angled the beveled reed stylus, pressing the triangular head into pliable wet clay to produce interlocking wedges..."
            )
        ),

        // 8. Saqakhane Incised Bronze Bowl
        Artifact(
            id: "ALQ-SAQ-008",
            slug: "saqakhane-bowl",
            title: LocalizedText(ar: "طاسة سقاخانة برونزية مباركة", en: "Saqakhane Incised Blessing Bronze Bowl"),
            subtitle: LocalizedText(ar: "طاسة مياه وقفية منقوشة بالأدعية وآيات الشفاء (القرن 17 م)", en: "Endowed brass healing vessel with incised talismanic invocations (17th C.)"),
            category: .artifacts,
            period: LocalizedText(ar: "القرن 17 م (العصر الإسلامي المتأخر)", en: "17th Century CE (Safavid / Ottoman Era)"),
            creator: LocalizedText(ar: "نقاشو النحاس والبرونز في أصفهان وبغداد", en: "Master Coppersmiths of Isfahan & Baghdad"),
            institution: LocalizedText(ar: "متحف الفن الإسلامي • مجموعة التحف الوقفية", en: "Museum of Islamic Art • Endowed Antiquities Collection"),
            dimensions: ArtifactDimensions(heightCm: 8.5, widthCm: 19.5, depthCm: 19.5, weightKg: 0.68),
            material: LocalizedText(ar: "برونز أصفر مطروق، حفر يدوي غائر بالخط الثلث والكوفي، كيمياء الفضة", en: "Hammered brass-bronze alloy, hand-chased Thuluth calligraphic bands, silver niello patina"),
            condition: LocalizedText(ar: "حالة أثرية ممتازة مع احتفاظها بلون الأكسدة التراثي الأخضر النبيل (Patina)", en: "Superb condition bearing authentic historic olive patina and sharp incised talismans"),
            description: LocalizedText(
                ar: "طاسة شرب تقليدية كانت توضع في السقاخانات (محطات سقاية المارة في المدن الإسلامية التراثية كأصفهان وكربلاء والقاهرة). محفورة بالكامل بآيات الشفاء ودعاء السقاية وأسماء الأئمة والأولياء طلباً للبركة والرحمة لمن يشرب منها.",
                en: "A consecrated brass drinking bowl from historical public water fountains (Saqakhaneh). Encircled with talismanic verses of healing and blessing for passersby seeking refreshment in historic cities."
            ),
            historicalContext: LocalizedText(
                ar: "كانت السقاخانات محطات تضامن اجتماعي وروحاني في الأزقة التراثية تروي عطش الغرباء والفقراء بالمياه الباردة المعطرة بماء الورد.",
                en: "Public fountains stood at street corners as enduring acts of social solidarity and spiritual charity, offering rose-scented cold water to all travelers."
            ),
            rating: 4.89,
            reviewsCount: 22,
            priceEstimateUSD: 480,
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
                transcriptAr: "كان المار يمسك هذه الطاسة بحبلها النحاسي، ويشرب الماء العذب ويدعو لمن أوقف السقاية بالرحمة والمغفرة...",
                transcriptEn: "Travelers would raise the bowl chained to the brass grill, drinking cool water while offering prayers of blessing for the endowment..."
            )
        ),

        // 9. Antique Islamic Ceramic Bowl
        Artifact(
            id: "ALQ-BWL-009",
            slug: "ceramic-bowl",
            title: LocalizedText(ar: "سلطانية خزفية إسلامية ببريق معدني", en: "Antique Lusterware Islamic Ceramic Bowl"),
            subtitle: LocalizedText(ar: "خزف نيشابور وسامراء المزجج بالبريق الذهبي (القرن 11 م)", en: "Nishapur & Samarra golden metallic lusterware bowl (11th Century CE)"),
            category: .artifacts,
            period: LocalizedText(ar: "القرن 11 م (العصر الفاطمي / العباسي المتأخر)", en: "11th Century CE (Fatimid / Late Abbasid)"),
            creator: LocalizedText(ar: "صناع الخزف ذو البريق المعدني في الفسطاط ونيشابور", en: "Luster Ceramists of Fustat & Nishapur"),
            institution: LocalizedText(ar: "متحف الفن الإسلامي بالقاهرة • مجموعة الخزف النادر", en: "Museum of Islamic Art Cairo • Rare Ceramics Vault"),
            dimensions: ArtifactDimensions(heightCm: 11.2, widthCm: 24.0, depthCm: 24.0, weightKg: 0.82),
            material: LocalizedText(ar: "فخار صلصالي مطلي بزجاج قصديري أبيض، أكاسيد النحاس والفضة ذات البريق الذهبي", en: "Clay body, tin-opacified glaze, silver and copper metallic luster pigments"),
            condition: LocalizedText(ar: "محفوظة بعناية مع بريق لوني زاهٍ يتغير مع زاوية سقوط الضوء", en: "Remarkably preserved with radiant iridescent sheen shifting with ambient illumination"),
            description: LocalizedText(
                ar: "سلطانية خزفية أثرية رائعة، استُخدم في حرقها تقنية البريق المعدني الثورية التي ابتكرها المسلمون ليحاكوا بها بريق أواني الذهب والفضة. تزينها في المركز حمامة تراثية محاطة بأوراق نباتية مجردة وكتابات دعائية بالخط الكوفي المورق: 'البركة واليُمن والسرور لصاحبه'.",
                en: "A historic lusterware ceramic bowl reflecting iridescent light through a groundbreaking Islamic firing technique simulating gold. Features a central stylized bird encircled by Kufic blessings of happiness and prosperity."
            ),
            historicalContext: LocalizedText(
                ar: "كانت تقنية البريق المعدني سراً مهنياً دقيقاً يتوارثه كبار الخزافين في القاهرة وبغداد، وتعد هذه القطعة نموذجاً لجماليات المائدة الإسلامية الراقية.",
                en: "Lusterware production was a jealously guarded guild secret across Cairo and Baghdad, treasured among royal courts throughout the Mediterranean."
            ),
            rating: 4.92,
            reviewsCount: 31,
            priceEstimateUSD: 760,
            model: ModelSpec(
                usdzFilename: "bowl.usdz",
                glbFilename: "bowl.glb",
                scale: 1.0,
                archetype: .ceramicBowl,
                primaryColorHex: "#D8C29D",
                secondaryColorHex: "#A57A42",
                roughness: 0.28,
                metallic: 0.42
            ),
            audio: AudioNarration(
                titleAr: "سر صناعة البريق المعدني الإسلامي: كيف حوّل الخزافون الطين إلى ذهب",
                titleEn: "Alchemy of Islamic Luster: How Potters Turned Clay to Gold",
                narratorAr: "متحف الخزف الإسلامي",
                narratorEn: "Islamic Ceramic Guild Lectures",
                durationSec: 150,
                transcriptAr: "عبر عملية اختزال كيميائية داخل الأفران، ترسبت ذرات الفضة والنحاس لتخلق طبقة مجهرية تعكس أشعة الشمس كالمعدن النفيس...",
                transcriptEn: "Through an oxygen-starved reduction firing, copper and silver ions formed a microscopic metallic skin gleaming like solid gold..."
            )
        ),

        // 10. Astronomical Astrolabe
        Artifact(
            id: "ALQ-AST-010",
            slug: "astrolabe",
            title: LocalizedText(ar: "إسطرلاب نحاسي فلكي عربي أندلسي", en: "Andalusian Arab Brass Planispheric Astrolabe"),
            subtitle: LocalizedText(ar: "حاسوب الفلك والملاحة التاريخي لتحديد مواقيت الصلاة والقبلة", en: "The astronomical analog computer for celestial navigation and prayer calculation"),
            category: .artifacts,
            period: LocalizedText(ar: "القرن 13 م (العصر الأندلسي الزاهر)", en: "13th Century CE (Golden Age of al-Andalus)"),
            creator: LocalizedText(ar: "إبراهيم بن محمد الإشبيلي الأندلسي", en: "Ibrahim ibn Muhammad al-Ishbili al-Andalusi"),
            institution: LocalizedText(ar: "متحف تاريخ العلوم (أكسفورد) • مستودع علقمي الفلكي", en: "History of Science Museum (Oxford) • Alqami Celestial Vault"),
            dimensions: ArtifactDimensions(heightCm: 22.0, widthCm: 16.5, depthCm: 2.5, weightKg: 1.15),
            material: LocalizedText(ar: "نحاس أصفر مصقول، نقش يدوي دقيق لخطوط المقنطرات والبروج، عقرب عضادة نحاسي", en: "Polished brass, hand-engraved almucantar plates, rete pointers, alidade sight"),
            condition: LocalizedText(ar: "جهاز كامل بكافة صفائحه الإقليمية (قرطبة، مكة، بغداد) ومحور دورانه السليم", en: "Fully functional instrument with original climate plates for Cordoba, Mecca, and Baghdad"),
            description: LocalizedText(
                ar: "حاسوب فلكي تناظري عبقري أبدعه علماء الفلك المسلمون. يتكون من شبكة العنكوت المفرغة التي تمثل مواقع ألمع النجوم، وصفائح متعددة لخطوط العرض، وعضادة في الخلف لحساب ارتفاع الشمس وتحديد اتجاه القبلة بدقة متناهية في أي بقعة من الأرض.",
                en: "The quintessential scientific instrument of the Islamic Golden Age. Features an openwork brass rete pointing to principal stars, interchangeable latitude plates, and an alidade on the back for solar altitude and Qibla reckoning."
            ),
            historicalContext: LocalizedText(
                ar: "اعتمد عليه البحارة والقوافل الصحراوية لقرون طويلة في الملاحة عبر النجوم، وكان هدية ملوك الشرق لنظرائهم في أوروبا لندرته ودقته الحسابية الفائقة.",
                en: "The astrolabe was indispensable for oceanic navigation, desert travel, and astronomical calculation, bridging medieval Arabic sciences into Europe."
            ),
            rating: 4.98,
            reviewsCount: 64,
            priceEstimateUSD: 2800,
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
                titleAr: "كيف يعمل الإسطرلاب العربي في رصد النجوم وتحديد القبلة",
                titleEn: "How the Arab Astrolabe Tracked the Stars and Determined the Qibla",
                narratorAr: "الجمعية الفلكية العربية",
                narratorEn: "Arab Astronomical Society",
                durationSec: 165,
                transcriptAr: "عبر توجيه ثقبي العضادة نحو نجم القطب أو الشمس، يقرأ الفلكي الدرجات بدقة ليحدد الوقت في الليل بدقة الدقائق...",
                transcriptEn: "By aligning the sights of the alidade with the pole star, the astronomer calculates the exact time of night to within minutes..."
            )
        ),

        // 11. Damascus Steel Inlaid Dagger
        Artifact(
            id: "ALQ-DAG-011",
            slug: "damascus-dagger",
            title: LocalizedText(ar: "خنجر دمشقي فولاذي مذهب بالمينا", en: "Gold-Damascened Steel Jambiya Dagger"),
            subtitle: LocalizedText(ar: "نصل فولاذ جوهري مقوس مع مقبض يشمي مرصع بالأحجار", en: "Curved wootz steel jambiya with jade hilt inlaid with rubies"),
            category: .weapons,
            period: LocalizedText(ar: "القرن 17 م (العصر المغولي / الصفوي)", en: "17th Century CE (Mughal-Safavid Royal Workshops)"),
            creator: LocalizedText(ar: "صاغة السلاح الملكي في حلب ودمشق", en: "Royal Weaponsmiths of Damascus & Aleppo"),
            institution: LocalizedText(ar: "متحف فيكتوريا وألبرت (لندن) • علقمي للأسلحة النادرة", en: "Victoria & Albert Museum • Alqami Rare Blades Archive"),
            dimensions: ArtifactDimensions(heightCm: 38.0, widthCm: 9.0, depthCm: 3.5, weightKg: 0.58),
            material: LocalizedText(ar: "فولاذ دمشقي ووتز بتموجات خشب البتولا، حجر اليشم الأخضر، ياقوت طبيعي، ذهب 24 قيراط", en: "Crucible damascus steel, nephrite jade hilt, cabochon rubies, pure 24K gold wire"),
            condition: LocalizedText(ar: "تحفة ملكية سليمة تماماً تحتفظ بحافة نصلها الفولاذي القاطع وغمدها المزخرف", en: "Pristine royal condition retaining razored tempered edge and velvet-covered sheath"),
            description: LocalizedText(
                ar: "خنجر جنبية عربي تراثي فائق البراعة، صيغ نصله من الفولاذ الدمشقي الأصيل الذي تتلألأ فيه أمواج الجوهر المعدنية. نُحت مقبضه من قطعة واحدة من حجر اليشم الأخضر الطبيعي، ورُصع بالذهب الخالص والياقوت الأحمر بأسلوب الكفتكاري السلطاني.",
                en: "A royal jambiya dagger forged from legendary crucible Damascus steel displaying natural watered banding. The hilt is sculpted from a single piece of nephrite jade, lavishly inlaid with gold wire and rubies."
            ),
            historicalContext: LocalizedText(
                ar: "كان هذا الخنجر شارة فخر وسيادة يتوارثها الأمراء والفرسان في المشرق، ويجسد أوج المهارة الحرفية في المزاوجة بين الصلابة القاطعة والفخامة الجمالية.",
                en: "Worn as an emblem of nobility and sovereign status by princes across the Levant, representing the zenith of Eastern metallurgy and gem-setting."
            ),
            rating: 4.95,
            reviewsCount: 37,
            priceEstimateUSD: 1950,
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
                titleAr: "أسطورة الفولاذ الدمشقي: سر النصل الذي حير علماء المعادن في العالم",
                titleEn: "The Legend of Damascus Steel: Secrets of the Watered Blade",
                narratorAr: "سلسلة الحرف التراثية الشامية",
                narratorEn: "Levantine Metallurgy Chronicles",
                durationSec: 150,
                transcriptAr: "التموجات الساحرة على نصل الخنجر الدمشقي ليست مجرد زينة، بل هي بلورات من الكاربيد متناهية الصغر تمنح السيف حدة أسطورية...",
                transcriptEn: "The flowing water patterns on the blade are microscopic carbon nanotubes and carbide crystals granting the steel unmatched sharpness..."
            )
        )
    ]

    // MARK: - Bento Room Hotspots
    public static let bentoHotspots: [BentoHotspot] = [
        BentoHotspot(
            id: "hs-table",
            xPercent: 0.255,
            yPercent: 0.390,
            artifactId: "ALQ-TAB-004",
            labelAr: "لوح خريطة العالم البابلية",
            labelEn: "Babylonian World Map Tablet",
            areaNameAr: "طاولة الفحص الرئيسية",
            areaNameEn: "Main Living Table"
        ),
        BentoHotspot(
            id: "hs-vase",
            xPercent: 0.365,
            yPercent: 0.355,
            artifactId: "ALQ-BWL-009",
            labelAr: "سلطانية خزفية ببريق معدني",
            labelEn: "Lusterware Ceramic Centerpiece",
            areaNameAr: "وسط الطاولة",
            areaNameEn: "Table Centerpiece"
        ),
        BentoHotspot(
            id: "hs-rug",
            xPercent: 0.130,
            yPercent: 0.710,
            artifactId: "ALQ-MSS-006",
            labelAr: "مخطوط نهج البلاغة المذهب",
            labelEn: "Illuminated Nahj al-Balagha",
            areaNameAr: "منصة القراءة التراثية",
            areaNameEn: "Reading Platform"
        ),
        BentoHotspot(
            id: "hs-art",
            xPercent: 0.785,
            yPercent: 0.125,
            artifactId: "ALQ-MIH-007",
            labelAr: "محراب وقبلية إسلامية",
            labelEn: "Ceramic Mosaic Mihrab",
            areaNameAr: "الجدار التراثي المعلق",
            areaNameEn: "Wall Architecture"
        ),
        BentoHotspot(
            id: "hs-credenza",
            xPercent: 0.875,
            yPercent: 0.260,
            artifactId: "ALQ-STE-003",
            labelAr: "مسلة شريعة حمورابي",
            labelEn: "Hammurabi Code Stele",
            areaNameAr: "ركن الآثار الكبرى",
            areaNameEn: "Grand Stele Alcove"
        ),
        BentoHotspot(
            id: "hs-lamp",
            xPercent: 0.690,
            yPercent: 0.695,
            artifactId: "ALQ-HLM-001",
            labelAr: "خوذة حربية إسلامية مذهبة",
            labelEn: "Gilded Islamic Helmet",
            areaNameAr: "منصة السلاح والدرع",
            areaNameEn: "Armor Pedestal"
        ),
        BentoHotspot(
            id: "hs-stools",
            xPercent: 0.820,
            yPercent: 0.775,
            artifactId: "ALQ-DAG-011",
            labelAr: "خنجر دمشقي فولاذي مذهب",
            labelEn: "Damascus Inlaid Dagger",
            areaNameAr: "طاولة الخناجر والنوادر",
            areaNameEn: "Accent Dagger Display"
        ),
        BentoHotspot(
            id: "hs-sofa",
            xPercent: 0.930,
            yPercent: 0.565,
            artifactId: "ALQ-SWD-005",
            labelAr: "سيف ذو الفقار التاريخي",
            labelEn: "Historic Zulfiqar Sword",
            areaNameAr: "جدارية السيوف التذكارية",
            areaNameEn: "Memorial Swords Wall"
        )
    ]
}
