import SwiftUI

@main
struct AlqamiNativeApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogHomeView()
                .preferredColorScheme(.dark)
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
