package com.alqami.nativeapp.ui.theme

import android.app.Activity
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = AlqamiGoldPrimary,
    secondary = AlqamiGoldLight,
    tertiary = AlqamiGoldDark,
    background = AlqamiDarkBackground,
    surface = AlqamiSurfaceDark,
    onPrimary = AlqamiDarkBackground,
    onSecondary = AlqamiDarkBackground,
    onBackground = AlqamiTextPrimary,
    onSurface = AlqamiTextPrimary
)

@Composable
fun AlqamiNativeTheme(
    content: @Composable () -> Unit
) {
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as? Activity)?.window ?: return@SideEffect
            window.statusBarColor = AlqamiDarkBackground.toArgb()
            window.navigationBarColor = AlqamiDarkBackground.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
        }
    }

    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = Typography,
        content = content
    )
}
