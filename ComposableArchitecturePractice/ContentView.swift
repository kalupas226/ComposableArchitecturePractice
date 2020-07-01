//
//  ContentView.swift
//  ComposableArchitecturePractice
//
//  Created by Aikawa Kenta on 2020/07/01.
//  Copyright © 2020 Aikawa Kenta. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct Todo: Equatable, Identifiable {
    let id: UUID
    var description = ""
    var isComplete = false
}

struct AppState: Equatable {
    var todos: [Todo] = []
}

//enum AppAction {
//    case todoCheckboxTapped(index: Int)
//    case todoTextFieldChanged(index: Int, text: String)
//}

enum AppAction {
    case todo(index: Int, action: TodoAction)
}

struct AppEnvironment {

}

enum TodoAction {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment {}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, _ in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

//let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
//    switch action {
//    case .todoCheckboxTapped(index: let index):
//        state.todos[index].isComplete.toggle()
//        return .none
//
//    case .todoTextFieldChanged(index: let index, text: let text):
//        state.todos[index].description = text
//        return .none
//    }
//}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = todoReducer.forEach(
    state: \AppState.todos,
    action: /AppAction.todo(index:action:),
    environment: { _ in TodoEnvironment() }
)

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEachStore(
                        self.store.scope(
                            state: { $0.todos },
                            action: { AppAction.todo(index: $0, action: $1) }
                        )
                    ) { todoStore in
                        WithViewStore(todoStore) { todoViewStore in
                            HStack {
                                Button(action: {
                                    todoViewStore.send(.checkboxTapped)
                                }) {
                                    Image(systemName: todoViewStore.isComplete ? "checkmark.square" : "square")
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                TextField(
                                    "Untitled todo",
                                    text: todoViewStore.binding(
                                        get: { $0.description },
                                        send: { .textFieldChanged($0) }
                                    )
                                )
                            }
                            .foregroundColor(todoViewStore.isComplete ? .gray: nil)
                        }
                    }
                }
            }
        .navigationBarTitle("Todos")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: AppState(
                    todos: [
                        Todo(
                            id: UUID(),
                            description: "Milk",
                            isComplete: false
                        ),
                        Todo(
                            id: UUID(),
                            description: "Eggs",
                            isComplete: false
                        ),
                        Todo(
                            id: UUID(),
                            description: "Hand Soup",
                            isComplete: true
                        )
                    ]
                ),
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
    }
}
