package com.alqami.nativeapp.ui.catalog

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.alqami.nativeapp.data.model.Artifact
import com.alqami.nativeapp.ui.components.visionGlass
import com.alqami.nativeapp.ui.theme.*
import com.alqami.nativeapp.ui.viewmodel.CatalogViewModel

@Composable
fun CatalogHomeScreen(
    viewModel: CatalogViewModel,
    onSelectArtifact: (Artifact) -> Unit,
    onLaunchAR: (Artifact) -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AlqamiDarkBackground)
    ) {
        // Top Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(AlqamiGoldPrimary),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "ع",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.Black
                    )
                }

                Column {
                    Text(
                        text = if (uiState.isArabic) "علقمي التراثي" else "ALQAMI Heritage",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Native Spatial Edition",
                        style = MaterialTheme.typography.labelSmall,
                        color = AlqamiGoldPrimary
                    )
                }
            }

            // Language Switcher
            OutlinedButton(
                onClick = { viewModel.toggleLanguage() },
                modifier = Modifier.height(34.dp),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 0.dp),
                shape = RoundedCornerShape(10.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White)
            ) {
                Text(
                    text = if (uiState.isArabic) "EN" else "عربي",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        // Search Bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .visionGlass(cornerRadius = 14.dp)
                .padding(horizontal = 12.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Search,
                contentDescription = null,
                tint = AlqamiTextTertiary
            )
            Spacer(modifier = Modifier.width(8.dp))
            TextField(
                value = uiState.searchQuery,
                onValueChange = { viewModel.onSearchQueryChanged(it) },
                placeholder = {
                    Text(
                        text = if (uiState.isArabic) "بحث في المخطوطات والقطع..." else "Search manuscripts & artifacts...",
                        color = AlqamiTextTertiary,
                        fontSize = 13.sp
                    )
                },
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    disabledContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent
                ),
                singleLine = true,
                modifier = Modifier.weight(1f)
            )
            if (uiState.searchQuery.isNotEmpty()) {
                IconButton(
                    onClick = { viewModel.onSearchQueryChanged("") },
                    modifier = Modifier.size(24.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = null,
                        tint = AlqamiTextTertiary
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Horizontal Categories
        val scrollState = rememberScrollState()
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(scrollState)
                .padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            uiState.categories.forEach { (catId, catLabel) ->
                val isSelected = uiState.selectedCategory == catId
                FilterChip(
                    selected = isSelected,
                    onClick = { viewModel.selectCategory(catId) },
                    label = {
                        Text(
                            text = catLabel.localized(uiState.isArabic),
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                        )
                    },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = AlqamiGoldPrimary,
                        selectedLabelColor = Color.Black,
                        containerColor = AlqamiSurfaceDark,
                        labelColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Content
        if (uiState.isLoading) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = AlqamiGoldPrimary)
            }
        } else if (uiState.filteredArtifacts.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(
                    text = if (uiState.isArabic) "لم يتم العثور على قطع تطابق البحث" else "No artifacts match your query",
                    color = AlqamiTextSecondary
                )
            }
        } else {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                contentPadding = PaddingValues(16.dp),
                horizontalArrangement = Arrangement.spacedBy(14.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(uiState.filteredArtifacts, key = { it.id }) { artifact ->
                    ArtifactCard(
                        artifact = artifact,
                        isArabic = uiState.isArabic,
                        onSelect = { onSelectArtifact(artifact) },
                        onLaunchAR = { onLaunchAR(artifact) }
                    )
                }
            }
        }
    }
}
