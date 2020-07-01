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

enum AppAction {
    case todoCheckboxTapped(index: Int)
    case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {

}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .todoCheckboxTapped(index: let index):
        state.todos[index].isComplete.toggle()
        return .none

    case .todoTextFieldChanged(index: let index, text: let text):
        state.todos[index].description = text
        return .none
    }
}

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
                        HStack {
                            Button(action: {
                                viewStore.send(.todoCheckboxTapped(index: index))
                            }) {
                                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(todo.isComplete ? .gray: nil)
                            
                            TextField(
                                "Untitled todo",
                                text: viewStore.binding(
                                    get: { $0.todos[index].description },
                                    send: { .todoTextFieldChanged(index: index, text: $0) }
                                )
                            )
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
