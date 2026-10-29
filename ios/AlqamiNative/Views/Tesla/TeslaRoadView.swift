import SwiftUI
import SceneKit
import CoreMotion

// MARK: - Tesla 3D Autonomous Perception View (Apple Metal & SceneKit)
// Matches Image 1: 3-Lane Highway, Muhammad Al-Qasim Highway, 88 KM/H, Surrounding Cars & Truck, Apple LiDAR Badge
public struct TeslaRoadView: View {
    @ObservedObject private var hardware = RealHardwareMonitor.shared
    
    // Live Vehicle State
    @State private var currentSpeed: Int = 88
    @State private var targetLane: Int = 0 // -1: Left, 0: Center, 1: Right
    @State private var laneOffset: CGFloat = 0.0
    @State private var isBraking: Bool = false
    @State private var radarPulse: CGFloat = 0.0
    @State private var roadOffset: CGFloat = 0.0
    @State private var leadDistance: Int = 32
    @State private var truckDistance: Int = 48
    @State private var timerActive: Bool = true
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // 1. OLED Deep Dark Base
            Color(red: 0.04, green: 0.05, blue: 0.07)
                .ignoresSafeArea()
            
            // 2. 3D Road Highway View (SceneKit / Apple Metal)
            TeslaRoadSceneRepresentable(
                laneOffset: laneOffset,
                isBraking: isBraking,
                radarPulse: radarPulse
            )
            .ignoresSafeArea()
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        if value.translation.width < -30 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                targetLane = max(-1, targetLane - 1)
                                laneOffset = CGFloat(targetLane) * -0.9
                            }
                        } else if value.translation.width > 30 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                targetLane = min(1, targetLane + 1)
                                laneOffset = CGFloat(targetLane) * 0.9
                            }
                        }
                    }
            )
            
            // 3. Native Flagship Tesla UI Overlays
            VStack(spacing: 0) {
                // Top Autonomous Driving HUD
                topAutonomousHUD
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                
                // Navigation Turn-by-Turn Banner (طريق محمد القاسم السريع)
                turnByTurnNavigationBanner
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                
                Spacer()
                
                // Bottom LiDAR Hardware Badge
                bottomHardwareLiDARBadge
                    .padding(.bottom, 78) // Positioned nicely above bottom navigation dock
            }
            .padding(.horizontal, 8)
        }
        .onAppear {
            startSimulationTimers()
        }
    }
    
    // MARK: - 1. Top Autonomous HUD
    private var topAutonomousHUD: some View {
        HStack(alignment: .top) {
            // Left: Speed Limit Sign (100 MAX)
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.red, lineWidth: 3.5)
                        .background(Circle().fill(Color.white))
                        .frame(width: 44, height: 44)
                    
                    Text("100")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                }
                
                Text("MAX")
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Center: Real-time Speed Display
            VStack(spacing: -2) {
                Text("\(currentSpeed)")
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Text("KM/H")
                    .font(.system(size: 11, weight: .black, design: .default))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1.5)
            }
            .offset(y: -4)
            
            Spacer()
            
            // Right: PRND Gear Selector & System Status
            VStack(alignment: .trailing, spacing: 6) {
                // Gear Indicators
                HStack(spacing: 7) {
                    gearText("P", active: false)
                    gearText("R", active: false)
                    gearText("N", active: false)
                    gearText("D", active: true)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .glossyPill()
                
                // Battery & Headlight Badges
                HStack(spacing: 6) {
                    // Ready Badge
                    Text("READY")
                        .font(.system(size: 8, weight: .heavy))
                        .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.4))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(red: 0.2, green: 0.85, blue: 0.4).opacity(0.18)))
                    
                    // Headlamp beam
                    Image(systemName: "headlight.high.beam.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                    
                    // Battery indicator
                    HStack(spacing: 2) {
                        Image(systemName: "battery.75")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.4))
                        Text("\(hardware.batteryPercentage)%")
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func gearText(_ char: String, active: Bool) -> some View {
        Text(char)
            .font(.system(size: 12, weight: active ? .black : .bold))
            .foregroundColor(active ? Color(red: 0.2, green: 0.6, blue: 1.0) : .white.opacity(0.4))
            .scaleEffect(active ? 1.15 : 1.0)
    }
    
    // MARK: - 2. Turn-by-Turn Navigation Banner (طريق محمد القاسم السريع)
    private var turnByTurnNavigationBanner: some View {
        HStack(spacing: 12) {
            // Blue Navigation Arrow Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.48, blue: 1.0), Color(red: 0.0, green: 0.35, blue: 0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.blue.opacity(0.4), radius: 6, y: 2)
                
                Image(systemName: "arrow.turn.up.left")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("2.5 كم")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("انعطف يساراً نحو المخرج")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                }
                
                Text("طريق محمد القاسم السريع")
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.839, blue: 0.039))
            }
            .environment(\.layoutDirection, .rightToLeft)
            
            Spacer()
            
            // Lane Guidance Indicator (Left 2 lanes highlighted)
            HStack(spacing: 3) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                Image(systemName: "arrow.up")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
                Image(systemName: "arrow.up")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.08)))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glossyGlass(cornerRadius: 18, tintOpacity: 0.22, shadowRadius: 16)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - 3. Bottom LiDAR Hardware Status Badge
    private var bottomHardwareLiDARBadge: some View {
        HStack(spacing: 8) {
            // Pulsing Green Sensor Dot
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.85, blue: 0.4).opacity(0.3))
                    .frame(width: 14, height: 14)
                
                Circle()
                    .fill(Color(red: 0.2, green: 0.85, blue: 0.4))
                    .frame(width: 7, height: 7)
            }
            
            Text("مستشعرات Apple LiDAR نشطة • محرك الرصد ثلاثي الأبعاد نشط (Apple Metal)")
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glossyGlass(cornerRadius: 24, tintOpacity: 0.25, shadowRadius: 14)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func startSimulationTimers() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if !timerActive { timer.invalidate() }
            withAnimation(.linear(duration: 0.05)) {
                radarPulse = (radarPulse + 0.04).truncatingRemainder(dividingBy: 1.0)
            }
        }
    }
}

// MARK: - SceneKit High-Performance 3D Road Scene
public struct TeslaRoadSceneRepresentable: UIViewRepresentable {
    public var laneOffset: CGFloat
    public var isBraking: Bool
    public var radarPulse: CGFloat
    
    public func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.07, alpha: 1.0)
        scnView.antialiasingMode = .multisampling4X
        scnView.preferredFramesPerSecond = 60
        scnView.autoenablesDefaultLighting = false
        
        let scene = SCNScene()
        scnView.scene = scene
        
        // 1. Camera setup (Behind and slightly above ego vehicle)
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 62
        cameraNode.position = SCNVector3(x: 0, y: 2.8, z: 4.8)
        cameraNode.eulerAngles = SCNVector3(x: -0.32, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // 2. Lighting (Atmospheric Dark Mode)
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.28, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor(white: 0.65, alpha: 1.0)
        directionalLight.position = SCNVector3(x: 5, y: 12, z: 6)
        directionalLight.eulerAngles = SCNVector3(x: -0.8, y: 0.4, z: 0)
        scene.rootNode.addChildNode(directionalLight)
        
        // 3. Road Surface (Asphalt with 3 lanes)
        let roadPlane = SCNPlane(width: 8.5, height: 80.0)
        roadPlane.firstMaterial?.diffuse.contents = UIColor(red: 0.09, green: 0.10, blue: 0.13, alpha: 1.0)
        roadPlane.firstMaterial?.roughness.contents = 0.8
        let roadNode = SCNNode(geometry: roadPlane)
        roadNode.eulerAngles.x = -.pi / 2
        roadNode.position = SCNVector3(x: 0, y: -0.01, z: -25)
        scene.rootNode.addChildNode(roadNode)
        
        // 4. Road Curbs & Lane Markings
        createLaneDividers(scene: scene)
        
        // 5. Ego Vehicle (Blue Tesla-style Sedan)
        let egoVehicleNode = createTeslaVehicleNode()
        egoVehicleNode.name = "egoVehicle"
        egoVehicleNode.position = SCNVector3(x: 0, y: 0.35, z: 0.5)
        scene.rootNode.addChildNode(egoVehicleNode)
        
        // 6. Traffic Obstacles Ahead (White Car & Semi Truck)
        let leadCar = createTrafficSedanNode(distanceText: "32m")
        leadCar.position = SCNVector3(x: -1.8, y: 0.35, z: -10)
        leadCar.name = "leadCar"
        scene.rootNode.addChildNode(leadCar)
        
        let semiTruck = createSemiTruckNode(distanceText: "48m")
        semiTruck.position = SCNVector3(x: 1.8, y: 0.7, z: -16)
        semiTruck.name = "semiTruck"
        scene.rootNode.addChildNode(semiTruck)
        
        // 7. Radar Pulse Wave Node
        let radarNode = createRadarPulseNode()
        radarNode.name = "radarWave"
        radarNode.position = SCNVector3(x: 0, y: 0.05, z: 0.0)
        scene.rootNode.addChildNode(radarNode)
        
        return scnView
    }
    
    public func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }
        
        // Smoothly position ego vehicle according to lane offset
        if let ego = scene.rootNode.childNode(withName: "egoVehicle", recursively: true) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            ego.position.x = Float(laneOffset)
            ego.eulerAngles.z = Float(-laneOffset * 0.05) // subtle roll during lane turn
            SCNTransaction.commit()
        }
        
        // Radar pulse scale animation
        if let radar = scene.rootNode.childNode(withName: "radarWave", recursively: true) {
            let scale = Float(0.5 + radarPulse * 2.8)
            radar.scale = SCNVector3(x: scale, y: 1.0, z: scale)
            radar.opacity = CGFloat(1.0 - radarPulse)
        }
    }
    
    // MARK: - Scene Construction Helpers
    private func createLaneDividers(scene: SCNScene) {
        // Continuous edge curbs
        for side in [-3.8, 3.8] {
            let curb = SCNBox(width: 0.12, height: 0.08, length: 80, chamferRadius: 0)
            curb.firstMaterial?.diffuse.contents = UIColor(white: 0.4, alpha: 1.0)
            let curbNode = SCNNode(geometry: curb)
            curbNode.position = SCNVector3(x: Float(side), y: 0.04, z: -25)
            scene.rootNode.addChildNode(curbNode)
        }
        
        // Dashed lane lines
        for xOffset in [-1.25, 1.25] {
            for zIndex in 0..<20 {
                let dash = SCNBox(width: 0.08, height: 0.01, length: 1.8, chamferRadius: 0)
                dash.firstMaterial?.diffuse.contents = UIColor(white: 0.85, alpha: 0.8)
                let dashNode = SCNNode(geometry: dash)
                dashNode.position = SCNVector3(x: Float(xOffset), y: 0.01, z: Float(-zIndex * 4 + 5))
                
                // Continuous backward motion loop
                let moveAction = SCNAction.moveBy(x: 0, y: 0, z: 4.0, duration: 0.35)
                let resetAction = SCNAction.moveBy(x: 0, y: 0, z: -4.0, duration: 0.0)
                dashNode.runAction(SCNAction.repeatForever(SCNAction.sequence([moveAction, resetAction])))
                scene.rootNode.addChildNode(dashNode)
            }
        }
    }
    
    private func createTeslaVehicleNode() -> SCNNode {
        let root = SCNNode()
        
        // Main Car Body (Metallic Electric Blue)
        let bodyGeo = SCNBox(width: 1.25, height: 0.42, length: 2.3, chamferRadius: 0.12)
        bodyGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.05, green: 0.35, blue: 0.85, alpha: 1.0)
        bodyGeo.firstMaterial?.metalness.contents = 0.75
        bodyGeo.firstMaterial?.roughness.contents = 0.25
        let bodyNode = SCNNode(geometry: bodyGeo)
        bodyNode.position = SCNVector3(0, 0, 0)
        root.addChildNode(bodyNode)
        
        // Cabin Glass Greenhouse (Dark Obsidian Glass)
        let cabinGeo = SCNBox(width: 1.05, height: 0.32, length: 1.2, chamferRadius: 0.08)
        cabinGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.08, green: 0.1, blue: 0.12, alpha: 0.95)
        cabinGeo.firstMaterial?.metalness.contents = 0.9
        cabinGeo.firstMaterial?.roughness.contents = 0.1
        let cabinNode = SCNNode(geometry: cabinGeo)
        cabinNode.position = SCNVector3(0, 0.26, -0.15)
        root.addChildNode(cabinNode)
        
        // Glowing Red Rear LED Light Bar (Signature Tesla look)
        let lightBarGeo = SCNBox(width: 1.15, height: 0.06, length: 0.05, chamferRadius: 0.02)
        lightBarGeo.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
        lightBarGeo.firstMaterial?.emission.contents = UIColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
        let lightBarNode = SCNNode(geometry: lightBarGeo)
        lightBarNode.position = SCNVector3(0, 0.05, 1.15)
        root.addChildNode(lightBarNode)
        
        // Road Contact Shadow
        let shadowPlane = SCNPlane(width: 1.4, height: 2.6)
        shadowPlane.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.6)
        let shadowNode = SCNNode(geometry: shadowPlane)
        shadowNode.eulerAngles.x = -.pi / 2
        shadowNode.position = SCNVector3(0, -0.34, 0)
        root.addChildNode(shadowNode)
        
        return root
    }
    
    private func createTrafficSedanNode(distanceText: String) -> SCNNode {
        let root = SCNNode()
        
        // Car Body (Silver White)
        let bodyGeo = SCNBox(width: 1.2, height: 0.42, length: 2.2, chamferRadius: 0.1)
        bodyGeo.firstMaterial?.diffuse.contents = UIColor(white: 0.88, alpha: 1.0)
        bodyGeo.firstMaterial?.roughness.contents = 0.4
        let bodyNode = SCNNode(geometry: bodyGeo)
        root.addChildNode(bodyNode)
        
        // Cabin
        let cabinGeo = SCNBox(width: 1.0, height: 0.3, length: 1.1, chamferRadius: 0.06)
        cabinGeo.firstMaterial?.diffuse.contents = UIColor(white: 0.15, alpha: 1.0)
        let cabinNode = SCNNode(geometry: cabinGeo)
        cabinNode.position = SCNVector3(0, 0.25, -0.1)
        root.addChildNode(cabinNode)
        
        // Rear red lights
        let lightGeo = SCNBox(width: 0.9, height: 0.05, length: 0.04, chamferRadius: 0.01)
        lightGeo.firstMaterial?.diffuse.contents = UIColor.red
        lightGeo.firstMaterial?.emission.contents = UIColor.red
        let lightNode = SCNNode(geometry: lightGeo)
        lightNode.position = SCNVector3(0, 0.05, 1.1)
        root.addChildNode(lightNode)
        
        return root
    }
    
    private func createSemiTruckNode(distanceText: String) -> SCNNode {
        let root = SCNNode()
        
        // Cargo Container Box
        let cargoGeo = SCNBox(width: 1.6, height: 1.2, length: 4.0, chamferRadius: 0.05)
        cargoGeo.firstMaterial?.diffuse.contents = UIColor(white: 0.82, alpha: 1.0)
        let cargoNode = SCNNode(geometry: cargoGeo)
        cargoNode.position = SCNVector3(0, 0.25, 0.5)
        root.addChildNode(cargoNode)
        
        // Front Cabin
        let cabGeo = SCNBox(width: 1.5, height: 0.9, length: 1.2, chamferRadius: 0.05)
        cabGeo.firstMaterial?.diffuse.contents = UIColor(white: 0.75, alpha: 1.0)
        let cabNode = SCNNode(geometry: cabGeo)
        cabNode.position = SCNVector3(0, 0.1, -2.0)
        root.addChildNode(cabNode)
        
        // Rear truck lights
        let lightsGeo = SCNBox(width: 1.4, height: 0.08, length: 0.05, chamferRadius: 0.01)
        lightsGeo.firstMaterial?.diffuse.contents = UIColor.red
        lightsGeo.firstMaterial?.emission.contents = UIColor.red
        let lightsNode = SCNNode(geometry: lightsGeo)
        lightsNode.position = SCNVector3(0, -0.3, 2.5)
        root.addChildNode(lightsNode)
        
        return root
    }
    
    private func createRadarPulseNode() -> SCNNode {
        let root = SCNNode()
        let ring = SCNTorus(ringRadius: 3.2, pipeRadius: 0.03)
        ring.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 0.7)
        ring.firstMaterial?.emission.contents = UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 0.7)
        let ringNode = SCNNode(geometry: ring)
        ringNode.scale = SCNVector3(1.2, 0.1, 0.8)
        root.addChildNode(ringNode)
        return root
    }
}
