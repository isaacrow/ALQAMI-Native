package com.alqami.nativeapp.ui.viewmodel

import androidx.lifecycle.ViewModel
import com.alqami.nativeapp.data.model.Artifact
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

data class ArUiState(
    val artifact: Artifact? = null,
    val isSurfaceDetected: Boolean = false,
    val isPlaced: Boolean = false,
    val scaleMultiplier: Float = 1.0f,
    val isDepthOcclusionEnabled: Boolean = true,
    val statusMessage: String = "جاري البحث عن سطح مستوٍ...",
    val isArabic: Boolean = true
)

class ArViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(ArUiState())
    val uiState: StateFlow<ArUiState> = _uiState.asStateFlow()

    fun initialize(artifact: Artifact, isArabic: Boolean) {
        _uiState.update {
            it.copy(
                artifact = artifact,
                isArabic = isArabic,
                scaleMultiplier = artifact.model.scale,
                isPlaced = false,
                isSurfaceDetected = false,
                statusMessage = if (isArabic) "وجه الكاميرا ببطء نحو الأرضية أو الطاولة لرصد السطح" else "Point camera at a flat surface..."
            )
        }
    }

    fun onSurfaceDetected(detected: Boolean) {
        if (_uiState.value.isPlaced) return
        _uiState.update {
            it.copy(
                isSurfaceDetected = detected,
                statusMessage = if (detected) {
                    if (it.isArabic) "تم رصد سطح مستقر - المس لتثبيت القطعة" else "Surface detected. Tap to place artifact."
                } else {
                    if (it.isArabic) "وجه الكاميرا نحو سطح مستوٍ..." else "Searching for surface..."
                }
            )
        }
    }

    fun onArtifactPlaced() {
        _uiState.update {
            it.copy(
                isPlaced = true,
                statusMessage = if (it.isArabic) "تم التثبيت بنجاح! اسحب للتحريك واقرص للتكبير" else "Artifact placed! Drag to move, pinch to scale."
            )
        }
    }

    fun resetPlacement() {
        _uiState.update {
            it.copy(
                isPlaced = false,
                statusMessage = if (it.isArabic) "تمت إزالة القطعة. وجه الكاميرا لتحديد سطح جديد" else "Placement reset. Search for a new surface."
            )
        }
    }

    fun updateScale(delta: Float) {
        _uiState.update {
            val newScale = (it.scaleMultiplier + delta).coerceIn(0.1f, 5.0f)
            it.copy(scaleMultiplier = newScale)
        }
    }

    fun toggleDepthOcclusion() {
        _uiState.update { it.copy(isDepthOcclusionEnabled = !it.isDepthOcclusionEnabled) }
    }
}
