import SwiftUI
import SwiftUINavigation

// MARK: - View
struct TodosView: View {
  @ObservedObject var vm: TodosViewModel

  var body: some View {
    NavigationStack {
      List(selection: vm.isEditing ? $vm.selected : .constant([])) {
        ForEach(vm.todos) { todo in
          HStack {
            Button {
              vm.todoCheckBoxTapped(todo.id)
            } label: {
              Image(systemName: todo.isComplete ? "checkmark.square" : "square")
            }
            .buttonStyle(.plain)
            TextField("Untitled Todo", text: .init(
              get: { todo.description },
              set: { vm.todoDescriptionChanged(todo.id, $0) }
            ))
          }
          .foregroundColor(todo.isComplete ? .gray : nil)
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              vm.swipeToDeleteCompleted(todo)
            } label: {
              Label("Delete", systemImage: "trash")
            }.tint(.red)
          }
          .deleteDisabled(true)
          .disabled(vm.isEditing)
          .tag(todo.id)
        }
        .onMove(perform: vm.move)
//        .onDelete(perform: vm.delete)
      }
      .environment(\.editMode, .constant(vm.isEditing ? .active : .inactive))
      .toolbar { toolbar() }
      .navigationTitle(vm.navigationTitle)
      .alert(
        unwrapping: $vm.destination,
        case: /TodosViewModel.Destination.alert,
        action: vm.alertButtonTapped
      )
    }
  }
}

// MARK: - Previews
struct TodosView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      TodosView(vm : .init(cdc: .init(), todos: .init(uniqueElements: mockTodos)))
    }
  }
}
