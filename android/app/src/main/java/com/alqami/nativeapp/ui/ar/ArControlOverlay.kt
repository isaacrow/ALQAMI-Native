package com.alqami.nativeapp.ui.ar

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.alqami.nativeapp.ui.components.visionGlass
import com.alqami.nativeapp.ui.theme.*
import com.alqami.nativeapp.ui.viewmodel.ArUiState

@Composable
fun ArControlOverlay(
    uiState: ArUiState,
    onBack: () -> Unit,
    onReset: () -> Unit,
    onScaleChange: (Float) -> Unit,
    onToggleOcclusion: () -> Unit,
    modifier: Modifier = Modifier
) {
    val artifact = uiState.artifact ?: return

    Box(modifier = modifier.fillMaxSize()) {
        // Top Bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            IconButton(
                onClick = onBack,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(Color.Black.copy(alpha = 0.5f))
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = null,
                    tint = Color.White
                )
            }

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 12.dp)
            ) {
                Text(
                    text = artifact.title.localized(uiState.isArabic),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Text(
                    text = artifact.period.localized(uiState.isArabic),
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.White.copy(alpha = 0.7f)
                )
            }

            // Status Pill
            Row(
                modifier = Modifier
                    .clip(CircleShape)
                    .background(Color.Black.copy(alpha = 0.5f))
                    .padding(horizontal = 10.dp, vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(if (uiState.isSurfaceDetected) AlqamiSuccess else AlqamiWarning)
                )
                Text(
                    text = if (uiState.isPlaced) "مثبت" else (if (uiState.isSurfaceDetected) "سطح جاهز" else "بحث..."),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }

        // Center Guidance Indicator (when not yet placed)
        if (!uiState.isPlaced) {
            Box(
                modifier = Modifier
                    .align(Alignment.Center)
                    .padding(horizontal = 24.dp)
            ) {
                Text(
                    text = uiState.statusMessage,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Medium,
                    color = Color.White,
                    modifier = Modifier
                        .visionGlass(cornerRadius = 16.dp)
                        .padding(horizontal = 16.dp, vertical = 10.dp)
                )
            }
        }

        // Bottom Controls Dock
        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            if (uiState.isPlaced) {
                Row(
                    modifier = Modifier
                        .visionGlass(cornerRadius = 18.dp)
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    IconButton(onClick = { onScaleChange(-0.15f) }) {
                        Icon(imageVector = Icons.Default.ZoomOut, contentDescription = null, tint = Color.White)
                    }

                    Text(
                        text = "${(uiState.scaleMultiplier * 100).toInt()}%",
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp
                    )

                    IconButton(onClick = { onScaleChange(+0.15f) }) {
                        Icon(imageVector = Icons.Default.ZoomIn, contentDescription = null, tint = Color.White)
                    }

                    Divider(
                        modifier = Modifier
                            .height(20.dp)
                            .width(1.dp),
                        color = Color.White.copy(alpha = 0.3f)
                    )

                    // Depth Occlusion Toggle
                    IconButton(onClick = onToggleOcclusion) {
                        Icon(
                            imageVector = if (uiState.isDepthOcclusionEnabled) Icons.Default.Layers else Icons.Default.LayersClear,
                            contentDescription = null,
                            tint = if (uiState.isDepthOcclusionEnabled) AlqamiSuccess else Color.White.copy(alpha = 0.5f)
                        )
                    }

                    // Reset Placement
                    IconButton(
                        onClick = onReset,
                        modifier = Modifier
                            .clip(CircleShape)
                            .background(Color.Red.copy(alpha = 0.3f))
                    ) {
                        Icon(imageVector = Icons.Default.Refresh, contentDescription = null, tint = Color.White)
                    }
                }
            }

            Text(
                text = if (uiState.isPlaced) {
                    "اسحب لتحريك القطعة • اقرص للتحجيم • دوّر بإصبعين"
                } else {
                    "انقر على السطح المرصود لتثبيت القطعة الأثرية"
                },
                fontSize = 12.sp,
                color = Color.White.copy(alpha = 0.8f)
            )
        }
    }
}
