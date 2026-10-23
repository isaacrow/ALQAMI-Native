package com.alqami.nativeapp.ui.ar

import android.view.MotionEvent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView
import com.alqami.nativeapp.data.model.Artifact
import com.alqami.nativeapp.ui.components.HapticFeedbackManager
import com.alqami.nativeapp.ui.viewmodel.ArViewModel
import com.google.ar.core.Config
import com.google.ar.core.Plane
import com.google.ar.core.TrackingState
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.ar.node.ArModelNode
import io.github.sceneview.ar.node.PlacementMode

@Composable
fun ArExperienceScreen(
    artifact: Artifact,
    isArabic: Boolean,
    viewModel: ArViewModel,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    val haptic = remember { HapticFeedbackManager(context) }
    val uiState by viewModel.uiState.collectAsState()

    var arSceneViewRef by remember { mutableStateOf<ARSceneView?>(null) }
    var currentModelNode by remember { mutableStateOf<ArModelNode?>(null) }

    LaunchedEffect(artifact) {
        viewModel.initialize(artifact, isArabic)
    }

    Box(modifier = Modifier.fillMaxSize()) {
        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { ctx ->
                ARSceneView(ctx).apply {
                    // Configure ARCore Session
                    planeRenderer.isEnabled = true
                    planeRenderer.isVisible = true

                    // Setup Session Features
                    onSessionCreated = { session ->
                        val config = Config(session).apply {
                            planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
                            lightEstimationMode = Config.LightEstimationMode.ENVIRONMENTAL_HDR
                            if (session.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                                depthMode = Config.DepthMode.AUTOMATIC
                            }
                            updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                        }
                        session.configure(config)
                    }

                    // Surface Detection listener
                    onSessionUpdated = { _, frame ->
                        if (!uiState.isPlaced) {
                            val hasTrackedPlane = frame.getUpdatedTrackables(Plane::class.java).any {
                                it.trackingState == TrackingState.TRACKING
                            }
                            viewModel.onSurfaceDetected(hasTrackedPlane)
                        }
                    }

                    // Tap to place
                    onTouchEvent = { e: MotionEvent ->
                        if (e.action == MotionEvent.ACTION_UP && !uiState.isPlaced) {
                            val hitResult = arSceneViewRef?.hitTest(e.x, e.y)?.firstOrNull()
                            if (hitResult != null) {
                                haptic.playPlacement()

                                val modelNode = ArModelNode(
                                    engine = engine,
                                    placementMode = PlacementMode.PLANE_HORIZONTAL_AND_VERTICAL
                                ).apply {
                                    val glbAssetPath = "models/${artifact.model.glbFilename}"
                                    loadModelGlbAsync(
                                        glbFileLocation = glbAssetPath,
                                        autoAnimate = true,
                                        scaleToUnits = artifact.model.scale * uiState.scaleMultiplier,
                                        onLoaded = {
                                            viewModel.onArtifactPlaced()
                                            haptic.playSuccess()
                                        }
                                    )
                                    isPositionEditable = true
                                    isRotationEditable = true
                                    isScaleEditable = true
                                }

                                addChild(modelNode)
                                modelNode.anchor()
                                currentModelNode = modelNode
                            }
                        }
                        false
                    }

                    arSceneViewRef = this
                }
            },
            update = { view ->
                // Apply depth occlusion toggle
                view.session?.let { session ->
                    val config = session.config
                    val desiredDepth = if (uiState.isDepthOcclusionEnabled && session.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                        Config.DepthMode.AUTOMATIC
                    } else {
                        Config.DepthMode.DISABLED
                    }
                    if (config.depthMode != desiredDepth) {
                        config.depthMode = desiredDepth
                        session.configure(config)
                    }
                }

                // Apply scale updates
                currentModelNode?.let { node ->
                    node.scaleToUnits = artifact.model.scale * uiState.scaleMultiplier
                }
            }
        )

        // Glassmorphic HUD overlay
        ArControlOverlay(
            uiState = uiState,
            onBack = onBack,
            onReset = {
                currentModelNode?.let { node ->
                    arSceneViewRef?.removeChild(node)
                    node.destroy()
                }
                currentModelNode = null
                viewModel.resetPlacement()
                haptic.playClick()
            },
            onScaleChange = { delta ->
                viewModel.updateScale(delta)
                haptic.playClick()
            },
            onToggleOcclusion = {
                viewModel.toggleDepthOcclusion()
                haptic.playClick()
            }
        )
    }
}
