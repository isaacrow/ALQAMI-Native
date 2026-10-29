import SwiftUI

// MARK: - Apple Flagship Liquid Glass Material System
// Designed for iPhone 15 Pro Max Super Retina XDR OLED & ProMotion Displays
public struct AppleLiquidGlassModifier: ViewModifier {
    public var cornerRadius: CGFloat = 24
    public var tintOpacity: Double = 0.16
    public var rimOpacity: Double = 0.45
    public var shadowRadius: CGFloat = 20

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 1. Real Apple UltraThin Blur
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // 2. Deep OLED Contrast Base
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(red: 0.06, green: 0.08, blue: 0.12).opacity(0.62))

                    // 3. Liquid Specular Sheen (Real Curved Surface Light Dispersion)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(tintOpacity * 2.2), location: 0.0),
                                    .init(color: Color.white.opacity(tintOpacity * 0.7), location: 0.28),
                                    .init(color: Color.clear, location: 0.52),
                                    .init(color: Color.white.opacity(tintOpacity * 0.35), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                // 4. Dual Liquid Specular Rim Reflection
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(rimOpacity * 1.5), location: 0.0),
                                .init(color: Color.white.opacity(rimOpacity * 0.4), location: 0.42),
                                .init(color: Color.white.opacity(0.08), location: 0.75),
                                .init(color: Color.white.opacity(rimOpacity * 0.7), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.42), radius: shadowRadius, x: 0, y: 10)
    }
}

// MARK: - Apple Liquid Glass Capsule / Pill
public struct AppleLiquidPillModifier: ViewModifier {
    public var isSelected: Bool = false
    public var activeColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039)

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        activeColor,
                                        activeColor.opacity(0.88)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.55), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    } else {
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                        Capsule(style: .continuous)
                            .fill(Color(red: 0.08, green: 0.10, blue: 0.16).opacity(0.58))
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.28), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isSelected ? 0.75 : 0.42),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.1
                    )
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.35 : 0.22), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Apple Liquid Glass Circle Button
public struct AppleLiquidCircleModifier: ViewModifier {
    public var size: CGFloat = 38
    public var isSelected: Bool = false
    public var activeColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039)

    public func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .background(
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(activeColor)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.55), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                        Circle()
                            .fill(Color(red: 0.08, green: 0.10, blue: 0.16).opacity(0.56))
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.30), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isSelected ? 0.80 : 0.45),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.1
                    )
            )
            .shadow(color: Color.black.opacity(0.30), radius: 8, x: 0, y: 4)
    }
}

// MARK: - View Extension API
public extension View {
    func glossyGlass(cornerRadius: CGFloat = 24, tintOpacity: Double = 0.16, rimOpacity: Double = 0.45, shadowRadius: CGFloat = 20) -> some View {
        self.modifier(AppleLiquidGlassModifier(cornerRadius: cornerRadius, tintOpacity: tintOpacity, rimOpacity: rimOpacity, shadowRadius: shadowRadius))
    }

    func glossyPill(
        isSelected: Bool = false,
        isHighlighted: Bool = false,
        activeColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039),
        accentColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039)
    ) -> some View {
        let color = activeColor != Color(red: 1.0, green: 0.839, blue: 0.039) ? activeColor : accentColor
        return self.modifier(AppleLiquidPillModifier(isSelected: isSelected || isHighlighted, activeColor: color))
    }

    func glossyCircle(
        size: CGFloat = 38,
        isSelected: Bool = false,
        isHighlighted: Bool = false,
        activeColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039),
        accentColor: Color = Color(red: 1.0, green: 0.839, blue: 0.039)
    ) -> some View {
        let color = activeColor != Color(red: 1.0, green: 0.839, blue: 0.039) ? activeColor : accentColor
        return self.modifier(AppleLiquidCircleModifier(size: size, isSelected: isSelected || isHighlighted, activeColor: color))
    }

    func visionGlass(cornerRadius: CGFloat = 20, strokeOpacity: Double = 0.22, shadowRadius: CGFloat = 16) -> some View {
        self.modifier(AppleLiquidGlassModifier(cornerRadius: cornerRadius, tintOpacity: 0.16, rimOpacity: strokeOpacity + 0.18, shadowRadius: shadowRadius))
    }

    func visionPill(isHighlighted: Bool = false) -> some View {
        self.modifier(AppleLiquidPillModifier(isSelected: isHighlighted))
    }
}
