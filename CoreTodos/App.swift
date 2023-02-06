import SwiftUI

struct AppView: View {
  @ObservedObject var todosVM: TodosViewModel
  var body: some View {
    NavigationStack {
      TodosView(vm: todosVM)
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(todosVM: .init(
      todos: .init(uniqueElements: mockTodos),
      sort: .none
    ))
  }
}
