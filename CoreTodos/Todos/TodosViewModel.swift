import SwiftUI
import SwiftUINavigation
import IdentifiedCollections

// MARK: - ViewModel
final class TodosViewModel: ObservableObject {
  @Published var destination: Destination?
  @Published var todos: IdentifiedArrayOf<Todo>
  @Published var backupTodos: IdentifiedArrayOf<Todo>
  @Published var selected: Set<Todo.ID>
  @Published var sort: Sort
  @Published var isEditing: Bool
  
  var navigationTitle: String {
    let status = isEditing && selected.count > 0
    return status ? "\(selected.count) Selected": "Todos"
  }
  
  init(
    destination: Destination? = nil,
    todos: IdentifiedArrayOf<Todo> = [],
    sort: Sort = .none
  ) {
    self.destination = destination
    self.todos = todos
    self.backupTodos = []
    self.selected = []
    self.sort = .none
    self.isEditing = false
    self.performSort()
  }
  
  func swipeToDeleteCompleted(_ todo: Todo) {
    _ = withAnimation {
      todos.remove(id: todo.id)
    }
  }
  
  func newTodoButtonTapped() {
    _ = withAnimation {
      todos.append(.init(id: .init(), description: "", isComplete: false))
    }
  }
  
  func move(_ indexSet: IndexSet, _ newPosition: Int) {
    withAnimation {
      todos.move(fromOffsets: indexSet, toOffset: newPosition)
    }
  }
  
  func delete(_ indexSet: IndexSet) {
    withAnimation {
      todos.remove(atOffsets: indexSet)
    }
  }
  
  func clearCompletedButtonTapped() {
    withAnimation {
      todos = todos.filter { !$0.isComplete}
    }
  }
  
  func clearAllButtonTapped() {
    withAnimation {
      todos = []
    }
  }
  
  func sortOptionTapped(_ newSort: Sort) {
    withAnimation {
      sort = newSort
      performSort()
    }
  }
  
  private func performSort() {
    switch sort {
    case .completed:
      todos = .init(uniqueElements: todos.sorted { $0.isComplete && !$1.isComplete })
      break
    case .incompleted:
      todos = .init(uniqueElements: todos.sorted { !$0.isComplete && $1.isComplete })
      break
    case .none:
      break
    }
  }
  
  func selectAllButtonTapped() {
    withAnimation {
      selected = selected.count == todos.count ? [] : .init(todos.map(\.id))
    }
  }
  
  func toggleIsCompletedButtonTapped() {
    guard selected.count > 0 && todos.count > 0 else { return }
    let isComplete = !todos[id: selected.first!]!.isComplete
    let newTodos = todos.map { todo in
      if selected.contains(todo.id) {
        var newTodo = todo
        newTodo.isComplete = isComplete
        return newTodo
      }
      return todo
    }
    withAnimation {
      todos = .init(uniqueElements: newTodos)
    }
  }
  
  func deleteSelectedButtonTapped() {
    withAnimation {
      todos = todos.filter { !selected.contains($0.id)}
    }
  }
  
  func editButtonTapped()  {
    backupTodos = todos
    withAnimation {
      isEditing = true
    }
  }
  
  func doneButtonTapped() {
    destination = .alert(.init(
      title: { TextState("Save Changes?")},
      actions: {
        ButtonState(action: .cancelChanges) {
          TextState("No")
        }
        ButtonState(action: .confirmChanges) {
          TextState("Yes")
        }
      },
      message: { TextState("Are you sure you want to save your changes?") }
    ))
  }
  
  func alertButtonTapped(_ alertAction: AlertAction?) {
    switch alertAction {
    case .confirmChanges:
      if !isEditing { break }
      withAnimation {
        backupTodos = []
        destination = nil
        isEditing = false
      }
      break
    case .none:
      break
    case .some(.cancelChanges):
      if !isEditing { break }
      withAnimation {
        todos = backupTodos
        backupTodos = []
        destination = nil
        isEditing = false
      }
      break
    }
  }
}

// MARK: - Destination
extension TodosViewModel {
  enum Destination {
    case alert(AlertState<AlertAction>)
  }
  
  enum AlertAction {
    case confirmChanges
    case cancelChanges
  }
}


// MARK: - Model
extension TodosViewModel {
  enum Sort: CaseIterable, Equatable {
    case completed
    case incompleted
    case none
    
    var string: String {
      switch self {
      case .completed: return "Completed"
      case .incompleted: return "Incompleted"
      case .none: return "None"
      }
    }
  }
}
