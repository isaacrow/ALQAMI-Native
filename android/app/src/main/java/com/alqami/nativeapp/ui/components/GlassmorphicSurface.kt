package com.alqami.nativeapp.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

fun Modifier.visionGlass(
    cornerRadius: Dp = 20.dp,
    strokeAlpha: Float = 0.22f,
    bgAlpha: Float = 0.16f
): Modifier = composed {
    val shape = RoundedCornerShape(cornerRadius)
    this
        .shadow(elevation = 12.dp, shape = shape, spotColor = Color.Black)
        .clip(shape)
        .background(
            Brush.linearGradient(
                colors = listOf(
                    Color(0xFF26334A).copy(alpha = bgAlpha * 1.5f),
                    Color(0xFF141A24).copy(alpha = bgAlpha)
                )
            )
        )
        .border(
            width = 1.dp,
            brush = Brush.linearGradient(
                colors = listOf(
                    Color.White.copy(alpha = strokeAlpha),
                    Color.White.copy(alpha = strokeAlpha * 0.25f),
                    Color.Transparent
                )
            ),
            shape = shape
        )
}
