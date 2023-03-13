import SwiftUI
import SwiftUI

extension TodosView  {
  
  // MARK: - Toolbar
  @ToolbarContentBuilder
  func toolbar() -> some ToolbarContent {
    if vm.isEditing {
      editingToolbar()
    }
    else {
      nonEditingToolbar()
    }
  }
  
  // MARK: - Editing Toolbar
  @ToolbarContentBuilder
  func editingToolbar() -> some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      Button {
        vm.selectAllButtonTapped()
      } label: {
        Text(vm.selected.count == vm.todos.count ? "Deselect All" : "Select All")
      }
    }
    
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button {
        vm.doneButtonTapped()
      } label: {
        Text("Done")
      }
    }
    
    ToolbarItemGroup(placement: .bottomBar) {
      Button {
        vm.editingToggleSelectedIsCompletedButtonTapped()
      } label: {
        Image(systemName: vm.selected.count == vm.todos.count ? "checkmark.square" : "square")
      }
      .disabled(vm.selected.count == 0)
      Spacer()
      Text("\(vm.todos.count) todos")
        .foregroundColor(vm.selected.count == 0 ? .secondary : .primary)
      Spacer()
      Button {
        vm.editingDeleteSelectedButtonTapped()
      } label: {
        Image(systemName: "trash")
      }
      .disabled(vm.selected.count == 0)
    }
  }
  
  // MARK: - Non-Editing Toolbar
  @ToolbarContentBuilder
  func nonEditingToolbar() -> some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      HStack(spacing: 0) {
        Button {
          vm.undoButtonTapped()
        } label: {
          Image(systemName: "arrow.uturn.backward")
        }
        .disabled(!vm.cdc.canUndo)
        Button {
          vm.redoButtonTapped()
        } label: {
          Image(systemName: "arrow.uturn.forward")
        }
        .disabled(!vm.cdc.canRedo)
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Menu {
        Button {
          vm.editButtonTapped()
        } label: {
          Text("Select")
        }
        Button {
          vm.clearCompletedButtonTapped()
        } label: {
          Text("Clear completed")
        }
        Button {
          vm.clearAllButtonTapped()
        } label: {
          Text("Clear all")
        }
        Menu {
//          Picker("Sort", selection: .init(
//            get: { vm.sort},
//            set: { vm.sortOptionTapped($0)}
//          )) {
            ForEach(TodosViewModel.Sort.allCases, id: \.self) { sort in
              Button  {
                vm.sortOptionTapped(sort)
              } label: {
                Text(sort.string)
              }
//            }
          }
        } label: {
          Text("Sort")
        }
      } label: {
        Image(systemName: "ellipsis.circle")
      }
    }
    ToolbarItemGroup(placement: .bottomBar) {
      Spacer()
      Text("\(vm.todos.count) todos")
      Spacer()
      Button {
        vm.newTodoButtonTapped()
      } label:  {
        Image(systemName: "plus")
      }
    }
  }
}
