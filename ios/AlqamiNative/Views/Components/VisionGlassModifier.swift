import SwiftUI

// MARK: - Apple Glossy Glass Material System (Liquid Specular Glass + Rim Reflection + Depth Shadow)
public struct AppleGlossyGlassModifier: ViewModifier {
    public var cornerRadius: CGFloat = 24
    public var tintOpacity: Double = 0.14
    public var rimOpacity: Double = 0.42
    public var shadowRadius: CGFloat = 18

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 1. Core Apple UltraThin Material Blur
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // 2. Dark Spatial Contrast Base
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(red: 0.07, green: 0.09, blue: 0.14).opacity(0.55))

                    // 3. Top-to-Bottom Glossy Specular Sheen (Curved Glass Reflection)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(tintOpacity * 1.65), location: 0.0),
                                    .init(color: Color.white.opacity(tintOpacity * 0.45), location: 0.36),
                                    .init(color: Color.clear, location: 0.55),
                                    .init(color: Color.white.opacity(tintOpacity * 0.25), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                // 4. Dual Specular Rim Highlight (Bright Top-Left Edge, Subtle Bottom-Right Edge)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(rimOpacity), location: 0.0),
                                .init(color: Color.white.opacity(rimOpacity * 0.35), location: 0.45),
                                .init(color: Color.white.opacity(0.08), location: 0.8),
                                .init(color: Color.white.opacity(rimOpacity * 0.5), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.38), radius: shadowRadius, x: 0, y: 8)
    }
}

// MARK: - Apple Glossy Glass Capsule / Pill Modifier
public struct AppleGlossyPillModifier: ViewModifier {
    public var isHighlighted: Bool = false
    public var accentColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039)

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if isHighlighted {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accentColor,
                                        accentColor.opacity(0.85)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.45), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    } else {
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                        Capsule(style: .continuous)
                            .fill(Color(red: 0.08, green: 0.10, blue: 0.15).opacity(0.52))
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.22), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isHighlighted ? 0.65 : 0.38),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.28), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Apple Glossy Circle Button Modifier
public struct AppleGlossyCircleModifier: ViewModifier {
    public var size: CGFloat = 38
    public var isHighlighted: Bool = false
    public var accentColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039)

    public func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .background(
                ZStack {
                    if isHighlighted {
                        Circle()
                            .fill(accentColor)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.45), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                        Circle()
                            .fill(Color(red: 0.08, green: 0.10, blue: 0.15).opacity(0.50))
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.26), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isHighlighted ? 0.7 : 0.42),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Legacy Compatibility Wrapper
public typealias VisionGlassModifier = AppleGlossyGlassModifier
public typealias VisionPillModifier = AppleGlossyPillModifier

public extension View {
    func glossyGlass(cornerRadius: CGFloat = 24, tintOpacity: Double = 0.14, rimOpacity: Double = 0.42, shadowRadius: CGFloat = 18) -> some View {
        self.modifier(AppleGlossyGlassModifier(cornerRadius: cornerRadius, tintOpacity: tintOpacity, rimOpacity: rimOpacity, shadowRadius: shadowRadius))
    }

    func glossyPill(isHighlighted: Bool = false, accentColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039)) -> some View {
        self.modifier(AppleGlossyPillModifier(isHighlighted: isHighlighted, accentColor: accentColor))
    }

    func glossyCircle(size: CGFloat = 38, isHighlighted: Bool = false, accentColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039)) -> some View {
        self.modifier(AppleGlossyCircleModifier(size: size, isHighlighted: isHighlighted, accentColor: accentColor))
    }

    func visionGlass(cornerRadius: CGFloat = 20, strokeOpacity: Double = 0.22, shadowRadius: CGFloat = 16) -> some View {
        self.modifier(AppleGlossyGlassModifier(cornerRadius: cornerRadius, tintOpacity: 0.14, rimOpacity: strokeOpacity + 0.15, shadowRadius: shadowRadius))
    }

    func visionPill(isHighlighted: Bool = false) -> some View {
        self.modifier(AppleGlossyPillModifier(isHighlighted: isHighlighted))
    }
}
