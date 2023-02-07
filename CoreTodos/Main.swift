import SwiftUI

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {
          AppView(todosVM: .init(cdc: .init()))
        }
    }
}
