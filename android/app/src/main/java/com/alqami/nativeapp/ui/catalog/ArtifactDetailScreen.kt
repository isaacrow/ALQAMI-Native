package com.alqami.nativeapp.ui.catalog

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.ViewInAr
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.alqami.nativeapp.data.model.Artifact
import com.alqami.nativeapp.ui.components.visionGlass
import com.alqami.nativeapp.ui.theme.*

@Composable
fun ArtifactDetailScreen(
    artifact: Artifact,
    isArabic: Boolean,
    onBack: () -> Unit,
    onLaunchAR: () -> Unit
) {
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AlqamiDarkBackground)
            .verticalScroll(scrollState)
            .padding(16.dp)
    ) {
        // Top Back button and Hero preview
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(260.dp)
                .clip(RoundedCornerShape(22.dp))
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color(0xFF1F2839), Color(0xFF10141D))
                    )
                ),
            contentAlignment = Alignment.Center
        ) {
            IconButton(
                onClick = onBack,
                modifier = Modifier
                    .align(Alignment.TopStart)
                    .padding(12.dp)
                    .clip(CircleShape)
                    .background(Color.Black.copy(alpha = 0.5f))
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = null,
                    tint = Color.White
                )
            }

            Icon(
                imageVector = Icons.Default.AutoAwesome,
                contentDescription = null,
                tint = AlqamiGoldPrimary,
                modifier = Modifier.size(72.dp)
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Titles
        Text(
            text = artifact.title.localized(isArabic),
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )

        Text(
            text = artifact.subtitle.localized(isArabic),
            style = MaterialTheme.typography.titleMedium,
            color = AlqamiGoldPrimary
        )

        Text(
            text = artifact.period.localized(isArabic),
            style = MaterialTheme.typography.bodyMedium,
            color = AlqamiTextSecondary
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Prominent AR Launcher
        Button(
            onClick = onLaunchAR,
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(
                containerColor = AlqamiGoldPrimary,
                contentColor = Color.Black
            ),
            shape = RoundedCornerShape(14.dp),
            contentPadding = PaddingValues(vertical = 14.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.ViewInAr,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp)
                )
                Text(
                    text = if (isArabic) "عرض في الواقع المعزز (AR Space)" else "View in AR Space",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Specifications
        Text(
            text = if (isArabic) "المواصفات التوثيقية" else "Documentation Specifications",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold
        )

        Spacer(modifier = Modifier.height(8.dp))

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .visionGlass(cornerRadius = 16.dp)
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SpecRow(title = if (isArabic) "الأبعاد" else "Dimensions", value = artifact.details.dimensions)
            SpecRow(title = if (isArabic) "المادة" else "Material", value = artifact.details.material.localized(isArabic))
            SpecRow(title = if (isArabic) "حالة الحفظ" else "Condition", value = artifact.details.condition.localized(isArabic))
            SpecRow(title = if (isArabic) "المؤسسة الحافظة" else "Institution", value = artifact.institution.localized(isArabic))
            SpecRow(title = if (isArabic) "رمز القطعة" else "Item Code", value = artifact.itemCode)
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Narrative Description
        Text(
            text = if (isArabic) "الوصف التاريخي" else "Historical Narrative",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = artifact.description.localized(isArabic),
            style = MaterialTheme.typography.bodyLarge,
            lineHeight = 24.sp,
            modifier = Modifier
                .fillMaxWidth()
                .visionGlass(cornerRadius = 16.dp)
                .padding(14.dp)
        )

        Spacer(modifier = Modifier.height(30.dp))
    }
}

@Composable
private fun SpecRow(title: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(text = title, style = MaterialTheme.typography.bodyMedium, color = AlqamiTextTertiary)
        Text(text = value, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.SemiBold, color = Color.White)
    }
}
