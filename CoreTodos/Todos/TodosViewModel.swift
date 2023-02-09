import SwiftUI
import SwiftUINavigation
import IdentifiedCollections
import Combine
import Tagged

// TODO: selection cant go away
// TODO: undo while editing can crash
// TODO: order is not preserved...

// MARK: - ViewModel
final class TodosViewModel: ObservableObject {
  @Published var cdc: CoreDataManager
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
    cdc: CoreDataManager = .shared,
    destination: Destination? = nil,
    todos: IdentifiedArrayOf<Todo>? = nil,
    sort: Sort = .none
  ) {
    self.cdc = cdc
    self.destination = destination
    self.todos = {
      let storedTodos = cdc.fetch()
      return .init(uniqueElements: storedTodos != nil ? storedTodos! : [])
    }()
    self.backupTodos = []
    self.selected = []
    self.sort = .none
    self.isEditing = false
    self.performSort()
  }
  
  // MARK:  - Undos...but when i relaunch i did not get undo..how?
  func undoButtonTapped()  {
    cdc.undo()
    todos = {
      let storedTodos = cdc.fetch()
      return .init(uniqueElements: storedTodos ?? [])
    }()
  }
  
  func redoButtonTapped() {
    cdc.redo()
    todos = {
      let storedTodos = cdc.fetch()
      return .init(uniqueElements: storedTodos ?? [])
    }()
  }
  
  func todoCheckBoxTapped(_ todoID: Todo.ID) {
    todos[id: todoID]!.isComplete.toggle()
    CoreDataManager.shared.update(todos[id: todoID]!)
  }
  
  func todoDescriptionChanged(_ todoID: Todo.ID, _ newDescription: String) {
    todos[id: todoID]!.description = newDescription
    CoreDataManager.shared.update(todos[id: todoID]!)
  }
  
  func swipeToDeleteCompleted(_ todo: Todo) {
    _ = withAnimation {
      todos.remove(id: todo.id)
    }
    CoreDataManager.shared.remove(todo)
  }
  
  func newTodoButtonTapped() {
    let newTodo = Todo(id: .init(), description: "", isComplete: false)
    _ = withAnimation {
      todos.append(newTodo)
    }
    CoreDataManager.shared.add(newTodo)
  }
  
  func move(_ indexSet: IndexSet, _ newPosition: Int) {
    withAnimation {
      todos.move(fromOffsets: indexSet, toOffset: newPosition)
    }
    // TODO: // Does this affect CoreData?
  }
  
  func clearCompletedButtonTapped() {
    let newTodos = todos.filter { !$0.isComplete}
    withAnimation {
      todos = newTodos
    }
    CoreDataManager.shared.update(newTodos.elements)
  }
  
  func clearAllButtonTapped() {
    withAnimation {
      todos = []
    }
    CoreDataManager.shared.update([])
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
  
  func editingToggleSelectedIsCompletedButtonTapped() {
    if !isEditing { return }
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
  
  func editingDeleteSelectedButtonTapped() {
    if !isEditing { return }
    let newTodos = todos.filter { !selected.contains($0.id)}
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
      CoreDataManager.shared.update(todos.elements)
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
      CoreDataManager.shared.update(backupTodos.elements)
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

// MARK: - TodosViewModel.Destination
extension TodosViewModel {
  enum Destination {
    case alert(AlertState<AlertAction>)
  }
}

// MARK: - TodosViewModel.AlertAction
extension TodosViewModel {
  enum AlertAction {
    case confirmChanges
    case cancelChanges
  }
}

// MARK: - TodosViewModel.Sort
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
