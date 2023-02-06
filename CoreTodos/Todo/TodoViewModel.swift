import Foundation
import Tagged

// MARK: - ViewModel
final class TodoViewModel: ObservableObject {
  @Published var todo: Todo
  
  init(todo: Todo) {
    self.todo = todo
  }
  
  func checkboxToggled() {
    todo.isComplete.toggle()
  }
  
  func descriptionChanged(_ newDescription: String) {
    
  }
}

// MARK: - Model
struct Todo: Identifiable, Codable {
  typealias ID = Tagged<Self, UUID>
  
  let id: ID
  var description: String
  var isComplete: Bool
}
