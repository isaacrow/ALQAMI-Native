package com.alqami.nativeapp.data.repository

import android.content.Context
import com.alqami.nativeapp.data.model.Artifact
import com.alqami.nativeapp.data.model.LocalizedText
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

interface CatalogRepository {
    suspend fun getArtifacts(): List<Artifact>
    suspend fun getArtifactById(id: String): Artifact?
    suspend fun getCategories(): List<Pair<String, LocalizedText>>
}

class LocalCatalogRepository(
    private val context: Context,
    private val json: Json = Json { ignoreUnknownKeys = true }
) : CatalogRepository {

    private var cachedArtifacts: List<Artifact>? = null

    override suspend fun getArtifacts(): List<Artifact> = withContext(Dispatchers.IO) {
        cachedArtifacts?.let { return@withContext it }

        val jsonString = context.assets.open("catalog.json").bufferedReader().use { it.readText() }
        val artifacts = json.decodeFromString<List<Artifact>>(jsonString)
        cachedArtifacts = artifacts
        artifacts
    }

    override suspend fun getArtifactById(id: String): Artifact? {
        return getArtifacts().firstOrNull { it.id == id || it.slug == id }
    }

    override suspend fun getCategories(): List<Pair<String, LocalizedText>> {
        val artifacts = getArtifacts()
        val map = linkedMapOf<String, LocalizedText>()
        map["all"] = LocalizedText(ar = "الكل", en = "All")
        for (artifact in artifacts) {
            if (!map.containsKey(artifact.category)) {
                map[artifact.category] = artifact.categoryLabel
            }
        }
        return map.toList()
    }
}
