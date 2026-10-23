import SwiftUI

public struct VisionGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var strokeOpacity: Double = 0.25

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(strokeOpacity),
                                Color.white.opacity(strokeOpacity * 0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

public extension View {
    func visionGlass(cornerRadius: CGFloat = 20, strokeOpacity: Double = 0.25) -> some View {
        self.modifier(VisionGlassModifier(cornerRadius: cornerRadius, strokeOpacity: strokeOpacity))
    }
}
