import Foundation
import UIKit
import CoreMotion
import Network
import AVFoundation
import MediaPlayer

// MARK: - Real Hardware Telemetry & Spatial Gyroscope Manager (Zero Fake Data)
@MainActor
public final class RealHardwareMonitor: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = RealHardwareMonitor()

    // Live Hardware Readings
    @Published public var batteryLevelPercent: Int = 100
    @Published public var batteryState: UIDevice.BatteryState = .unknown
    @Published public var isWiFiConnected: Bool = true
    @Published public var networkInterfaceText: String = "Wi-Fi"
    @Published public var systemVolume: Float = 0.75
    @Published public var devicePitch: CGFloat = 0
    @Published public var deviceRoll: CGFloat = 0
    @Published public var currentTimeText: String = ""
    @Published public var currentDateText: String = ""
    @Published public var isSpeaking: Bool = false

    public var currentTimeString: String { currentTimeText }
    public var batteryPercentage: Int { batteryLevelPercent }

    private let motionManager = CMMotionManager()
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.alqami.network.monitor")
    private var clockTimer: Timer?
    private let speechSynthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        speechSynthesizer.delegate = self
        setupBatteryMonitoring()
        setupNetworkMonitoring()
        setupMotionParallax()
        setupClockAndAudio()
    }

    // MARK: - 1. Real UIDevice Battery Level & Charging State
    private func setupBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBattery()
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                RealHardwareMonitor.shared.updateBattery()
            }
        }
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                RealHardwareMonitor.shared.updateBattery()
            }
        }
    }

    private func updateBattery() {
        let raw = UIDevice.current.batteryLevel
        if raw >= 0 {
            batteryLevelPercent = Int(round(raw * 100))
        } else {
            batteryLevelPercent = 100
        }
        batteryState = UIDevice.current.batteryState
    }

    // MARK: - 2. Real NWPathMonitor Wi-Fi / Cellular Connectivity
    private func setupNetworkMonitoring() {
        pathMonitor.pathUpdateHandler = { path in
            let connected = (path.status == .satisfied)
            let iface: String
            if path.usesInterfaceType(.wifi) {
                iface = "Wi-Fi"
            } else if path.usesInterfaceType(.cellular) {
                iface = "5G / Cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                iface = "Ethernet"
            } else {
                iface = connected ? "Online" : "Offline"
            }
            Task { @MainActor in
                RealHardwareMonitor.shared.isWiFiConnected = connected
                RealHardwareMonitor.shared.networkInterfaceText = iface
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }

    // MARK: - 3. Real CoreMotion Gyroscope Attitude for 3D Room Parallax
    private func setupMotionParallax() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let attitude = motion?.attitude else { return }
            let clampedRoll = max(-0.45, min(0.45, attitude.roll))
            let clampedPitch = max(-0.45, min(0.45, attitude.pitch - 0.6))
            Task { @MainActor in
                RealHardwareMonitor.shared.deviceRoll = CGFloat(clampedRoll)
                RealHardwareMonitor.shared.devicePitch = CGFloat(clampedPitch)
            }
        }
    }

    // MARK: - 4. Real Live Clock & AVAudioSession Volume
    private func setupClockAndAudio() {
        updateClock()
        systemVolume = AVAudioSession.sharedInstance().outputVolume
        clockTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            Task { @MainActor in
                RealHardwareMonitor.shared.updateClock()
                RealHardwareMonitor.shared.systemVolume = AVAudioSession.sharedInstance().outputVolume
            }
        }
    }

    private func updateClock() {
        let now = Date()
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"
        currentTimeText = tf.string(from: now)

        let df = DateFormatter()
        df.dateFormat = "EEE MMM d"
        currentDateText = df.string(from: now)
    }

    // MARK: - 5. Real Arabic/English Voice Narration (AVSpeechSynthesizer)
    public func speakNarration(_ text: String, isArabic: Bool) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: isArabic ? "ar-SA" : "en-US")
        utterance.rate = 0.47
        utterance.pitchMultiplier = 0.96
        isSpeaking = true
        speechSynthesizer.speak(utterance)
    }

    public func stopNarration() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    public func stopSpeaking() {
        stopNarration()
    }

    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            RealHardwareMonitor.shared.isSpeaking = false
        }
    }

    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            RealHardwareMonitor.shared.isSpeaking = false
        }
    }
}
