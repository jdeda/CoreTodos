import XCTest
@testable import CoreTodos

// MARK: - Unfourtnanetly, as it stands, we are really sharing the same data used live. Might be worth
// considering implementing a live, preview, and test versions.

final class CoreDataMangerTests: XCTestCase {
  
  override func setUpWithError() throws { }
  override func tearDownWithError() throws { }

  /// Adds a todo to be stored and checks if it was persisted.
  func testCoreDataMangerAdd() throws {
    CoreDataManager.shared.resetAll()

    let manager = CoreDataManager.init()
    XCTAssertEqual(manager.fetch()!, [], "No core data should be stored!")
    let newTodo = Todo(id: .init(), description: "Foo", isComplete: false)
    manager.add(newTodo)
    XCTAssertEqual(manager.fetch()!, [newTodo], "Should have stored and retrieved the exact Todo just added!")
  }

  /// Adds a todo to be stored and checks if it was persisted, then removes and checks if it was persisted, then attempts to remove a
  /// todo that does not exist in the container, and checks if results are still the same
  func testCoreDataMangerRemove() throws {
    CoreDataManager.shared.resetAll()

    let manager = CoreDataManager.init()
    XCTAssertEqual(manager.fetch()!, [], "No core data should be stored!")
    let newTodo = Todo(id: .init(), description: "Foo", isComplete: false)
    manager.add(newTodo)
    XCTAssertEqual(manager.fetch()!, [newTodo], "Should have stored and retrieved the exact Todo just added!")
    manager.remove(newTodo)
    XCTAssertEqual(manager.fetch()!, [], "No core data should be stored!")
    manager.remove(.init(id: .init(), description: "Foobar", isComplete: true))
    XCTAssertEqual(manager.fetch()!, [], "No core data should be stored!")
  }

  /// Tries to update a todo that doesnt exist, which shouldn't do anything, then add one, check that, then update and check it.
  func testCoreDataMangerUpdate() throws {
    CoreDataManager.shared.resetAll()

    let manager = CoreDataManager.init()
    manager.resetAll()
    XCTAssertEqual(manager.fetch()!, [], "No core data should be stored!")
    let newTodo = Todo(id: .init(), description: "Foo", isComplete: false)
    manager.update(newTodo)
    XCTAssertEqual(manager.fetch()!, [], "No core data should be stored!")
    manager.add(newTodo)
    XCTAssertEqual(manager.fetch()!, [newTodo], "Should have stored and retrieved the exact Todo just added!")
    let updatedTodo = Todo(id: newTodo.id, description: "Foobar", isComplete: true)
    manager.update(updatedTodo)
    XCTAssertEqual(manager.fetch()!, [updatedTodo], "Should have updated the exising todo!")
  }
}
