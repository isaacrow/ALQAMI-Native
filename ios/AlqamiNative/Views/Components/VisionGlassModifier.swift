import SwiftUI

// MARK: - Vision Glass View Modifier
public struct VisionGlassModifier: ViewModifier {
    public var cornerRadius: CGFloat = 20
    public var strokeOpacity: Double = 0.22
    public var shadowRadius: CGFloat = 16

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(strokeOpacity + 0.15),
                                Color.white.opacity(strokeOpacity * 0.4),
                                Color.white.opacity(strokeOpacity * 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: shadowRadius, x: 0, y: 8)
    }
}

// MARK: - Vision Pill View Modifier
public struct VisionPillModifier: ViewModifier {
    public var isHighlighted: Bool = false

    public func body(content: Content) -> some View {
        content
            .background(
                Capsule(style: .continuous)
                    .fill(isHighlighted ? Color(red: 0.95, green: 0.80, blue: 0.35) : Color.white.opacity(0.14))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - View Extensions
public extension View {
    func visionGlass(cornerRadius: CGFloat = 20, strokeOpacity: Double = 0.22, shadowRadius: CGFloat = 16) -> some View {
        self.modifier(VisionGlassModifier(cornerRadius: cornerRadius, strokeOpacity: strokeOpacity, shadowRadius: shadowRadius))
    }

    func visionPill(isHighlighted: Bool = false) -> some View {
        self.modifier(VisionPillModifier(isHighlighted: isHighlighted))
    }
}
