import Foundation

public struct LocalizedText: Codable, Hashable {
    public let ar: String
    public let en: String

    public func localized(isArabic: Bool = true) -> String {
        return isArabic ? (ar.isEmpty ? en : ar) : (en.isEmpty ? ar : en)
    }
}

public struct ArtifactModelInfo: Codable, Hashable {
    public let glbFilename: String
    public let usdzFilename: String
    public let scale: Float
    public let initialOrbit: OrbitInfo?

    public struct OrbitInfo: Codable, Hashable {
        public let theta: Float
        public let phi: Float
    }
}

public struct ArtifactDetails: Codable, Hashable {
    public let dimensions: String
    public let material: LocalizedText
    public let condition: LocalizedText
    public let binding: LocalizedText?
    public let decoration: LocalizedText?
    public let seals: LocalizedText?
    public let delivery: LocalizedText?
    public let assembly: LocalizedText?
}

public struct Artifact: Identifiable, Codable, Hashable {
    public let id: String
    public let slug: String
    public let title: LocalizedText
    public let subtitle: LocalizedText
    public let category: String
    public let categoryLabel: LocalizedText
    public let period: LocalizedText
    public let creator: LocalizedText
    public let institution: LocalizedText
    public let price: Double
    public let rating: Double
    public let reviewsCount: Int
    public let itemCode: String
    public let image: String
    public let model: ArtifactModelInfo
    public let description: LocalizedText
    public let details: ArtifactDetails

    public static let sample = Artifact(
        id: "ALQ-MSS-006",
        slug: "nahj-al-balagha",
        title: LocalizedText(ar: "مخطوط نهج البلاغة", en: "Nahj al-Balagha Manuscript"),
        subtitle: LocalizedText(ar: "الشيخ الرضي - الشريف الرضي (1022 هـ)", en: "Al-Sharif al-Radi (1022 AH / 1613 CE)"),
        category: "manuscripts",
        categoryLabel: LocalizedText(ar: "المخطوطات والنوادر", en: "Manuscripts"),
        period: LocalizedText(ar: "1022 هـ / 1613 م (العصر الصفوي)", en: "1022 AH / 1613 CE"),
        creator: LocalizedText(ar: "الشريف الرضي (ت 406 هـ)", en: "Al-Sharif al-Radi"),
        institution: LocalizedText(ar: "مستودع علقمي الرقمي التراثي", en: "Alqami Digital Heritage Repository"),
        price: 149.0,
        rating: 4.8,
        reviewsCount: 38,
        itemCode: "ALQ-MSS-1022",
        image: "model-nahj_al_balagha.png",
        model: ArtifactModelInfo(
            glbFilename: "nahj_al_balagha.glb",
            usdzFilename: "nahj_al_balagha.usdz",
            scale: 1.0,
            initialOrbit: ArtifactModelInfo.OrbitInfo(theta: 25, phi: 70)
        ),
        description: LocalizedText(
            ar: "نسخة خطية نادرة ومذهبة من مخطوط نهج البلاغة، تتميز بخط محقق واضح وهوامش ذات زخارف نباتية بديعة.",
            en: "An illuminated manuscript of Nahj al-Balagha transcribed in ornate calligraphy with gold floral margins."
        ),
        details: ArtifactDetails(
            dimensions: "28.5 × 18.2 cm (477 folios)",
            material: LocalizedText(ar: "ورق يدوي مذهب، حبر كربوني، جلد طبيعي", en: "Illuminated rag paper, carbon ink, bound leather"),
            condition: LocalizedText(ar: "ممتازة بعد الترميم الدقيق", en: "Pristine after conservation"),
            binding: LocalizedText(ar: "تجليد إسلامي أصيل مع لسان واقٍ", en: "Authentic Islamic envelope flap binding"),
            decoration: LocalizedText(ar: "عناوين مذهبة مع إطارات لاجوردية", en: "Gilded incipits with lapis lazuli borders"),
            seals: LocalizedText(ar: "أختام تملك تاريخية موثقة", en: "Documented historical ownership seals"),
            delivery: nil,
            assembly: nil
        )
    )
}
