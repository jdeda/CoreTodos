import SwiftUI
import SwiftUINavigation

// MARK: - View
struct TodosView: View {
  @ObservedObject var vm: TodosViewModel
  
  var body: some View {
    List(selection: $vm.selected) {
      ForEach(vm.todos) { todo in
        TodoView(vm: .init(
          todo: todo,
          checkboxToggled: vm.todoCheckBoxTapped,
          descriptionChanged: vm.todoDescriptionChanged
        ))
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
      .onDelete(perform: vm.delete)
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

// MARK: - Previews
struct TodosView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      TodosView(vm : .init(cdc: .init(), todos: .init(uniqueElements: mockTodos)))
    }
  }
}
