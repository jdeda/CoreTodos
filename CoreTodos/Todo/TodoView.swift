import SwiftUI

// MARK: - View
struct TodoView: View {
  @ObservedObject var vm: TodoViewModel
  
  var body: some View {
    HStack {
      Button {
        vm.checkboxToggled(vm.todo.id)
      } label: {
        Image(systemName: vm.todo.isComplete ? "checkmark.square" : "square")
      }
      .buttonStyle(.plain)
      TextField("Untitled Todo", text: .init(
        get: { vm.todo.description },
        set: { vm.descriptionChanged(vm.todo.id, $0) }
      ))
    }
    .foregroundColor(vm.todo.isComplete ? .gray : nil)
  }
}

// MARK: - Previews
struct TodoView_Previews: PreviewProvider {
  static var previews: some View {
    TodoView(vm: .init(
      todo: .init(id: .init(), description: "Do homework", isComplete: false),
      checkboxToggled: { _ in },
      descriptionChanged: { _, _ in }
    ))
  }
}
