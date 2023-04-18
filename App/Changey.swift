
import SwiftUI

@main
struct ChangeyApp: App {
    @StateObject private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            SceneContainerView()
                .environmentObject(viewModel)
        }
    }
}
