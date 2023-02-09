import XCTest
@testable import CoreTodos

// MARK: - Unfourtnanetly, as it stands, we are really sharing the same data used live. Might be worth
// considering implementing a live, preview, and test versions.

final class TodosViewModelTests: XCTestCase {
  
  override func setUpWithError() throws { }
  override func tearDownWithError() throws { }
  
  func testNewTodoButtonTapped() {
    CoreDataManager.shared.resetAll()
    
    // Check initial state.
    let vm = TodosViewModel()
    XCTAssertEqual(vm.cdc.fetch(), [], "TodosViewModel's CoreDataManger should have no data stored!")
    XCTAssertEqual(vm.todos.count, 0, "TodosViewModel should have no todos!")
    
    // Check adding a new todo.
    vm.newTodoButtonTapped()
    XCTAssertEqual(vm.todos.count, 1, "TodosViewModel should now have one todo!")
    XCTAssertEqual(vm.cdc.fetch(), vm.todos.elements, "TodosViewModel's todos' and CoreDataManger data should be the same!")
    
    // Check adding several more new todos.
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    XCTAssertEqual(vm.todos.count, 4, "TodosViewModel should now more todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
  }
  
  func testSwipeToDeleteTodo() {
    CoreDataManager.shared.resetAll()
    
    // Check initial state.
    let vm = TodosViewModel()
    XCTAssertEqual(vm.cdc.fetch(), [], "TodosViewModel's CoreDataManger should have no data stored!")
    XCTAssertEqual(vm.todos.count, 0, "TodosViewModel should have no todos!")
    
    // Check adding a new todo.
    vm.newTodoButtonTapped()
    XCTAssertEqual(vm.todos.count, 1, "TodosViewModel should now have one todo!")
    XCTAssertEqual(vm.cdc.fetch(), vm.todos.elements, "TodosViewModel's todos' and CoreDataManger data should be the same!")
    
    // Check removing it.
    vm.swipeToDeleteCompleted(vm.todos.first!)
    XCTAssertEqual(vm.todos.count, 0, "TodosViewModel should now no todos!")
    XCTAssertEqual(vm.cdc.fetch(), vm.todos.elements, "neither TodosViewModel's todos' or the  CoreDataManger should have data!")
    
    
    // Check adding several more new todos.
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel should now more todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
    
    // Try removing them one by one, and check.
    vm.swipeToDeleteCompleted(vm.todos.first!)
    XCTAssertEqual(vm.todos.count, 2, "TodosViewModel should have 2 todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
    
    vm.swipeToDeleteCompleted(vm.todos.first!)
    XCTAssertEqual(vm.todos.count, 1, "TodosViewModel should have 1 todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
    
    vm.swipeToDeleteCompleted(vm.todos.first!)
    XCTAssertEqual(vm.todos.count, 0, "TodosViewModel should have 0 todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
  }
  
  func testEditTodoDescription() {
    CoreDataManager.shared.resetAll()
    
    let vm = TodosViewModel()
    XCTAssertEqual(vm.todos.count, 0, "TodosViewModel should have no todos!")
    vm.newTodoButtonTapped()
    XCTAssertEqual(vm.todos.count, 1, "TodosViewModel should now have one todo!")
    vm.todoDescriptionChanged(vm.todos.first!.id, "Foo")
    XCTAssertEqual(vm.todos.count, 1, "TodosViewModel should still have have one todo!")
    XCTAssertEqual(vm.todos.first!.description, "Foo", "The todo should now have \"Foo\" as its description")
  }
  
  func testEditTodoCheckbox() {
    CoreDataManager.shared.resetAll()
    
    let vm = TodosViewModel()
    XCTAssertEqual(vm.todos.count, 0, "TodosViewModel should have no todos!")
    vm.newTodoButtonTapped()
    XCTAssertEqual(vm.todos.count, 1, "TodosViewModel should now have one todo!")
    vm.todoCheckBoxTapped(vm.todos.first!.id)
    XCTAssertEqual(vm.todos.count, 1, "TodosViewModel should still have have one todo!")
    XCTAssertEqual(vm.todos.first!.isComplete, true, "The todo should now have \"true\" as its isComplete property")
  }
  
  func testEditSelectedTodosCheckboxes() {
    CoreDataManager.shared.resetAll()
    
    let vm = TodosViewModel()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.editButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel should have more todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
    
    // Select all and toggle their isComplete property.
    let oldTodos = vm.todos
    vm.selectAllButtonTapped()
    vm.editingToggleSelectedIsCompletedButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel still have the same number of todos!")
    XCTAssertEqual(vm.todos.map(\.isComplete), (0..<vm.todos.count).map { _ in true }, "TodosViewModel todos .isComplete should all be true!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      oldTodos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "CoreData's todos shouldn't have changed!"
    )
    XCTAssertNotEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should have changed, but not CoreDataManger's, so we can revert everything in one undo if we decide to accept our changes"
    )
    
    // Do it again:
    vm.editingToggleSelectedIsCompletedButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel still have the same number of todos!")
    XCTAssertEqual(vm.todos.map(\.isComplete), (0..<vm.todos.count).map { _ in false }, "TodosViewModel todos .isComplete should all be false!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      oldTodos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "CoreData's todos shouldn't have changed!"
    )
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel and CoreDataManger should have same todos now despite CoreDataManager never updated"
    )
    
    // And again:
    vm.editingToggleSelectedIsCompletedButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel still have the same number of todos!")
    XCTAssertEqual(vm.todos.map(\.isComplete), (0..<vm.todos.count).map { _ in true }, "TodosViewModel todos .isComplete should all be true!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      oldTodos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "CoreData's todos shouldn't have changed!"
    )
    XCTAssertNotEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should have changed, but not CoreDataManger's, so we can revert everything in one undo if we decide to accept our changes"
    )
    
    // Cancel changes, so they should all be false again
    vm.doneButtonTapped()
    vm.alertButtonTapped(.cancelChanges)
    vm.editingToggleSelectedIsCompletedButtonTapped()
    XCTAssertEqual(vm.isEditing, false, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel still have the same number of todos!")
    XCTAssertEqual(
      oldTodos.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should be as they were before editing"
    )
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
  }
  
  func testDeleteSelectedTodos() {
    CoreDataManager.shared.resetAll()
    
    let vm = TodosViewModel()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.editButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel should have more todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
    
    // Select all and delete all.
    let oldTodos = vm.todos
    vm.selectAllButtonTapped()
    vm.editingDeleteSelectedButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos, [], "TodosViewModel should have no todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      oldTodos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "CoreData's todos shouldn't have changed!"
    )
    XCTAssertNotEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should have changed, but not CoreDataManger's, so we can revert everything in one undo if we decide to accept our changes"
    )
    
    // Cancel changes, so we never deleted all of them.
    vm.doneButtonTapped()
    vm.alertButtonTapped(.cancelChanges)
    XCTAssertEqual(vm.isEditing, false, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel still have the same number of todos!")
    XCTAssertEqual(
      oldTodos.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should be as they were before editing"
    )
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
  }
  
  func testDeleteSelectedConfirm() {
    CoreDataManager.shared.resetAll()
    
    let vm = TodosViewModel()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.editButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel should have more todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
    
    // Select all and delete all.
    let oldTodos = vm.todos
    vm.selectAllButtonTapped()
    vm.editingDeleteSelectedButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos, [], "TodosViewModel should have no todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      oldTodos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "CoreData's todos shouldn't have changed!"
    )
    XCTAssertNotEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should have changed, but not CoreDataManger's, so we can revert everything in one undo if we decide to accept our changes"
    )
    
    // Confirm changes, so we persist.
    vm.doneButtonTapped()
    vm.alertButtonTapped(.confirmChanges)
    XCTAssertEqual(vm.isEditing, false, "TodosViewModel should be not be editing!")
    XCTAssertEqual(vm.todos, [], "TodosViewModel should no todos!")
    XCTAssertNotEqual(
      oldTodos.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should be as they were before editing"
    )
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
    
//    // Undo. Should bring us back to the oldTodos.
//    vm.undoButtonTapped()
//    XCTAssertEqual(
//      oldTodos.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
//      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
//      "TodosViewModel's todos' should be as they were before editing!"
//    )
//    XCTAssertEqual(
//      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
//      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
//      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
//    )
//    
//    
//    // Redo.
  }
  
  func testDeleteSelectedCancel() {
    CoreDataManager.shared.resetAll()
    
    let vm = TodosViewModel()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.newTodoButtonTapped()
    vm.editButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel should have more todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
    
    // Select all and delete all.
    let oldTodos = vm.todos
    vm.selectAllButtonTapped()
    vm.editingDeleteSelectedButtonTapped()
    XCTAssertEqual(vm.isEditing, true, "TodosViewModel should be editing!")
    XCTAssertEqual(vm.todos, [], "TodosViewModel should have no todos!")
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      oldTodos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "CoreData's todos shouldn't have changed!"
    )
    XCTAssertNotEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should have changed, but not CoreDataManger's, so we can revert everything in one undo if we decide to accept our changes"
    )
  
    // Cancel changes, so we never deleted all of them.
    vm.doneButtonTapped()
    vm.alertButtonTapped(.cancelChanges)
    XCTAssertEqual(vm.isEditing, false, "TodosViewModel should not be editing!")
    XCTAssertEqual(vm.todos.count, 3, "TodosViewModel still have the same number of todos!")
    XCTAssertEqual(
      oldTodos.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' should be as they were before editing"
    )
    XCTAssertEqual(
      vm.cdc.fetch()?.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      vm.todos.elements.sorted(by: { $0.id.rawValue.uuidString > $1.id.rawValue.uuidString}),
      "TodosViewModel's todos' and CoreDataManger data should contain the same data regardless of order!"
    )
  }
}
