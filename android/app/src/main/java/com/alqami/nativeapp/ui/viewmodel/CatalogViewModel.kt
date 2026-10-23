package com.alqami.nativeapp.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.alqami.nativeapp.data.model.Artifact
import com.alqami.nativeapp.data.model.LocalizedText
import com.alqami.nativeapp.data.repository.CatalogRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class CatalogUiState(
    val artifacts: List<Artifact> = emptyList(),
    val filteredArtifacts: List<Artifact> = emptyList(),
    val categories: List<Pair<String, LocalizedText>> = emptyList(),
    val selectedCategory: String = "all",
    val searchQuery: String = "",
    val isLoading: Boolean = false,
    val isArabic: Boolean = true,
    val error: String? = null
)

class CatalogViewModel(
    private val repository: CatalogRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CatalogUiState())
    val uiState: StateFlow<CatalogUiState> = _uiState.asStateFlow()

    init {
        loadCatalog()
    }

    fun loadCatalog() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val artifacts = repository.getArtifacts()
                val categories = repository.getCategories()
                _uiState.update { state ->
                    state.copy(
                        artifacts = artifacts,
                        categories = categories,
                        isLoading = false
                    )
                }
                filterArtifacts()
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.localizedMessage) }
            }
        }
    }

    fun selectCategory(categoryId: String) {
        _uiState.update { it.copy(selectedCategory = categoryId) }
        filterArtifacts()
    }

    fun onSearchQueryChanged(query: String) {
        _uiState.update { it.copy(searchQuery = query) }
        filterArtifacts()
    }

    fun toggleLanguage() {
        _uiState.update { it.copy(isArabic = !it.isArabic) }
    }

    private fun filterArtifacts() {
        val state = _uiState.value
        var result = state.artifacts

        if (state.selectedCategory != "all") {
            result = result.filter { it.category == state.selectedCategory }
        }

        if (state.searchQuery.isNotBlank()) {
            val q = state.searchQuery.trim().lowercase()
            result = result.filter {
                it.title.ar.lowercase().contains(q) ||
                it.title.en.lowercase().contains(q) ||
                it.period.ar.lowercase().contains(q) ||
                it.period.en.lowercase().contains(q) ||
                it.creator.ar.lowercase().contains(q) ||
                it.creator.en.lowercase().contains(q)
            }
        }

        _uiState.update { it.copy(filteredArtifacts = result) }
    }
}
