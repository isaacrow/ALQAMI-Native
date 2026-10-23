package com.alqami.nativeapp

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.alqami.nativeapp.data.model.Artifact
import com.alqami.nativeapp.data.repository.LocalCatalogRepository
import com.alqami.nativeapp.ui.ar.ArExperienceScreen
import com.alqami.nativeapp.ui.catalog.ArtifactDetailScreen
import com.alqami.nativeapp.ui.catalog.CatalogHomeScreen
import com.alqami.nativeapp.ui.theme.AlqamiDarkBackground
import com.alqami.nativeapp.ui.theme.AlqamiGoldPrimary
import com.alqami.nativeapp.ui.theme.AlqamiNativeTheme
import com.alqami.nativeapp.ui.viewmodel.ArViewModel
import com.alqami.nativeapp.ui.viewmodel.CatalogViewModel

sealed class Screen {
    data object Catalog : Screen()
    data class Detail(val artifact: Artifact) : Screen()
    data class AR(val artifact: Artifact) : Screen()
}

class MainActivity : ComponentActivity() {

    private val catalogViewModel: CatalogViewModel by viewModels {
        object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                val repo = LocalCatalogRepository(applicationContext)
                return CatalogViewModel(repo) as T
            }
        }
    }

    private val arViewModel: ArViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            AlqamiNativeTheme {
                val catalogState by catalogViewModel.uiState.collectAsState()
                val layoutDir = if (catalogState.isArabic) LayoutDirection.Rtl else LayoutDirection.Ltr

                CompositionLocalProvider(LocalLayoutDirection provides layoutDir) {
                    var currentScreen by remember { mutableStateOf<Screen>(Screen.Catalog) }
                    val context = LocalContext.current

                    var hasCameraPermission by remember {
                        mutableStateOf(
                            ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.CAMERA
                            ) == PackageManager.PERMISSION_GRANTED
                        )
                    }

                    val permissionLauncher = rememberLauncherForActivityResult(
                        contract = ActivityResultContracts.RequestPermission()
                    ) { isGranted ->
                        hasCameraPermission = isGranted
                    }

                    when (val screen = currentScreen) {
                        is Screen.Catalog -> {
                            CatalogHomeScreen(
                                viewModel = catalogViewModel,
                                onSelectArtifact = { currentScreen = Screen.Detail(it) },
                                onLaunchAR = { artifact ->
                                    if (hasCameraPermission) {
                                        currentScreen = Screen.AR(artifact)
                                    } else {
                                        permissionLauncher.launch(Manifest.permission.CAMERA)
                                    }
                                }
                            )
                        }

                        is Screen.Detail -> {
                            ArtifactDetailScreen(
                                artifact = screen.artifact,
                                isArabic = catalogState.isArabic,
                                onBack = { currentScreen = Screen.Catalog },
                                onLaunchAR = {
                                    if (hasCameraPermission) {
                                        currentScreen = Screen.AR(screen.artifact)
                                    } else {
                                        permissionLauncher.launch(Manifest.permission.CAMERA)
                                    }
                                }
                            )
                        }

                        is Screen.AR -> {
                            if (hasCameraPermission) {
                                ArExperienceScreen(
                                    artifact = screen.artifact,
                                    isArabic = catalogState.isArabic,
                                    viewModel = arViewModel,
                                    onBack = { currentScreen = Screen.Catalog }
                                )
                            } else {
                                // Fallback permission requester
                                Box(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .background(AlqamiDarkBackground),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Column(
                                        horizontalAlignment = Alignment.CenterHorizontally,
                                        verticalArrangement = Arrangement.spacedBy(16.dp),
                                        modifier = Modifier.padding(24.dp)
                                    ) {
                                        Text(
                                            text = if (catalogState.isArabic)
                                                "يتطلب الواقع المعزز إذن الكاميرا لمسح الأسطح وتثبيت القطع"
                                            else
                                                "Camera permission is required to track surfaces and place 3D artifacts",
                                            color = MaterialTheme.colorScheme.onBackground
                                        )
                                        Button(
                                            onClick = { permissionLauncher.launch(Manifest.permission.CAMERA) },
                                            colors = ButtonDefaults.buttonColors(containerColor = AlqamiGoldPrimary),
                                            shape = RoundedCornerShape(12.dp)
                                        ) {
                                            Text(
                                                text = if (catalogState.isArabic) "منح إذن الكاميرا" else "Grant Camera Permission",
                                                color = androidx.compose.ui.graphics.Color.Black
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
