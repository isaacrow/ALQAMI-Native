import Foundation
import UIKit
import AudioToolbox

public final class SpatialSoundHelper {
    public static let shared = SpatialSoundHelper()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationFeedback.prepare()
    }

    public func playSnapHaptic() {
        lightImpact.impactOccurred()
    }

    public func playPlacementHaptic() {
        mediumImpact.impactOccurred()
        // Standard system audio ping for physical lock
        AudioServicesPlaySystemSound(1104)
    }

    public func playSuccessHaptic() {
        notificationFeedback.notificationOccurred(.success)
    }

    public func playWarningHaptic() {
        notificationFeedback.notificationOccurred(.warning)
    }
}
