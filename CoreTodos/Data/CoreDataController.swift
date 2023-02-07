import Foundation
import CoreData
import IdentifiedCollections

final class CoreDataController: ObservableObject {
  let container: NSPersistentContainer
  @Published var todos: IdentifiedArrayOf<CoreTodo> {
    didSet {
      print(todos)
    }
  }
  
  init() {
    container = NSPersistentContainer(name: "CoreTodo")
    container.loadPersistentStores { description, error in
      if let error {
        fatalError("ERROR LOADING CORE DATA: \(error)")
      }
      else {
        print("Successfully loaded Core Data")
      }
    }
    todos = []
  }
  
  func undoCommited() {
    container.viewContext.undo()
    save()
  }
  func redoCommited() {
    container.viewContext.redo()
    save()
  }
  
  func deleteAll() {
    let request = NSFetchRequest<CoreTodo>(entityName: "CoreTodo")
    guard let response = try? container.viewContext.fetch(request)
    else { return }
    response.forEach { container.viewContext.delete($0) }
    save()
  }
  
  func fetch() -> [Todo]? {
//    deleteAll()
    let request = NSFetchRequest<CoreTodo>(entityName: "CoreTodo")
    guard let response = try? container.viewContext.fetch(request)
    else { return nil }
    return response.compactMap { coreTodo in
      guard let id = coreTodo.id,
            let description = coreTodo.body
      else { return nil }
      return Todo(
        id: .init(id),
        description: description,
        isComplete: coreTodo.isComplete
      )
    }
  }
  
  func add(_ todo: Todo) {
    let newCoreTodo = CoreTodo(context: container.viewContext)
    newCoreTodo.id = todo.id.rawValue
    newCoreTodo.isComplete = todo.isComplete
    newCoreTodo.body = todo.description
    save()
  }
  
  func remove(_ todo: Todo) {
    guard let coreTodo = todos[id: todo.id.rawValue]
    else {
      print("CORE DATA FAILED TO REMOVE: \(todo)")
      return
    }
    container.viewContext.delete(coreTodo)
    save()
  }
  
  func update(_ todo: Todo) {
    todos[id: todo.id.rawValue]?.isComplete = todo.isComplete
    todos[id: todo.id.rawValue]?.body = todo.description
    save()
  }
  
  func update(_ todos: IdentifiedArrayOf<Todo>) {
    deleteAll()
    self.todos = .init(uniqueElements: todos.elements.map { todo in
      let newCoreTodo = CoreTodo(context: container.viewContext)
      newCoreTodo.id = todo.id.rawValue
      newCoreTodo.isComplete = todo.isComplete
      newCoreTodo.body = todo.description
      return newCoreTodo
    })
    save()
  }
  
  
  private func save() {
    if !container.viewContext.hasChanges  { return }
    do {
      try container.viewContext.save()
      self.todos = .init(uniqueElements: [])
    } catch let error as NSError  {
      print("CORE DATA FAILED TO SAVE: \(error)")
    }
    do {
      let request = NSFetchRequest<CoreTodo>(entityName: "CoreTodo")
      let response = try container.viewContext.fetch(request)
      self.todos = .init(uniqueElements: response)
    } catch let error as NSError  {
      print("CORE DATA FAILED TO SAVE: \(error)")
    }
  }
}
