import SwiftUI

@main
struct HarmoniaApp: App {
    @StateObject private var environment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment)
                .preferredColorScheme(.dark)
                .task {
                    await environment.startCamera()
                }
        }
    }
}
