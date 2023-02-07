import Foundation
import Tagged
import XCTestDynamicOverlay

// MARK: - ViewModel
final class TodoViewModel: ObservableObject {
  @Published var todo: Todo
  
  var checkboxToggled: (_ todoID: Todo.ID) -> Void = unimplemented("TodoViewModel.checkboxToggled")
  var descriptionChanged: (_ todoID: Todo.ID, _ newDescription: String) -> Void = unimplemented("TodoViewModel.checkboxToggled")
  
  init(
    todo: Todo,
    checkboxToggled: @escaping (_ todoID: Todo.ID) -> Void,
    descriptionChanged: @escaping (_ todoID: Todo.ID, _ newDescription: String) -> Void
  ) {
    self.todo = todo
    self.checkboxToggled = checkboxToggled
    self.descriptionChanged = descriptionChanged
  }
}

// MARK: - Model
struct Todo: Identifiable, Codable {
  typealias ID = Tagged<Self, UUID>
  
  let id: ID
  var description: String
  var isComplete: Bool
}
