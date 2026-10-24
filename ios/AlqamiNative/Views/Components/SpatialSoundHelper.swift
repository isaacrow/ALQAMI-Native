import Foundation
import UIKit
import AudioToolbox
import AVFoundation

public final class SpatialSoundHelper {
    public static let shared = SpatialSoundHelper()

    private let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
    private let impactFeedbackMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactFeedbackHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        prepare()
    }

    public func prepare() {
        impactFeedbackLight.prepare()
        impactFeedbackMedium.prepare()
        impactFeedbackHeavy.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }

    // MARK: - Haptics
    public func playSnapHaptic() {
        selectionFeedback.selectionChanged()
    }

    public func playSurfaceDetectedHaptic() {
        impactFeedbackLight.impactOccurred()
    }

    public func playPlacementHaptic() {
        impactFeedbackHeavy.impactOccurred()
        AudioServicesPlaySystemSound(1057) // Native Camera/Placement sound
    }

    public func playSuccessHaptic() {
        notificationFeedback.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1025) // Modern iOS chime
    }

    public func playWarningHaptic() {
        notificationFeedback.notificationOccurred(.warning)
        AudioServicesPlaySystemSound(1073)
    }

    public func playScaleTickHaptic() {
        impactFeedbackMedium.impactOccurred(intensity: 0.8)
    }

    public func playShutterSound() {
        AudioServicesPlaySystemSound(1108) // Camera shutter
    }
}
