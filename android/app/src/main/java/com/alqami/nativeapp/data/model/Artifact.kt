package com.alqami.nativeapp.data.model

import kotlinx.serialization.Serializable

@Serializable
data class LocalizedText(
    val ar: String = "",
    val en: String = ""
) {
    fun localized(isArabic: Boolean = true): String {
        return if (isArabic) {
            if (ar.isNotEmpty()) ar else en
        } else {
            if (en.isNotEmpty()) en else ar
        }
    }
}

@Serializable
data class OrbitInfo(
    val theta: Float = 0f,
    val phi: Float = 75f
)

@Serializable
data class ArtifactModelInfo(
    val glbFilename: String,
    val usdzFilename: String,
    val scale: Float = 1.0f,
    val initialOrbit: OrbitInfo? = null
)

@Serializable
data class ArtifactDetails(
    val dimensions: String = "",
    val material: LocalizedText = LocalizedText(),
    val condition: LocalizedText = LocalizedText(),
    val binding: LocalizedText? = null,
    val decoration: LocalizedText? = null,
    val seals: LocalizedText? = null,
    val delivery: LocalizedText? = null,
    val assembly: LocalizedText? = null
)

@Serializable
data class Artifact(
    val id: String,
    val slug: String,
    val title: LocalizedText,
    val subtitle: LocalizedText = LocalizedText(),
    val category: String,
    val categoryLabel: LocalizedText,
    val period: LocalizedText,
    val creator: LocalizedText,
    val institution: LocalizedText,
    val price: Double = 0.0,
    val rating: Double = 5.0,
    val reviewsCount: Int = 0,
    val itemCode: String = "",
    val image: String = "",
    val model: ArtifactModelInfo,
    val description: LocalizedText,
    val details: ArtifactDetails
)
