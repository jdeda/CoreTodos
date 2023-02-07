import SwiftUI

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {
          TodosView(vm: .init(cdc: .init()))
        }
    }
}
