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

enum AppAction: Equatable {
    case addButtonTapped
    case todo(index: Int, action: TodoAction)
    case todoDelayCompleted
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
}

enum TodoAction: Equatable {
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

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none

        case .todo(index: _, action: .checkboxTapped):
            struct CancelDelayId: Hashable {}
            
            return Effect(value: .todoDelayCompleted)
                .debounce(id: CancelDelayId(), for: 1, scheduler: environment.mainQueue)
//                .delay(for: 1, scheduler: DispatchQueue.main)
//                .eraseToEffect()
//                .cancellable(id: CancelDelayId(), cancelInFlight: true)

        case .todoDelayCompleted:
            state.todos = state.todos
                .enumerated()
                .sorted(by: { lhs, rhs in
                    (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
                })
                .map(\.element)
            return .none
        default:
            return .none
        }
    }
)

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button(action: {
                    viewStore.send(.checkboxTapped)
                }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField(
                    "Untitled todo",
                    text: viewStore.binding(
                        get: \.description,
                        send: TodoAction.textFieldChanged
                    )
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray: nil)
        }
    }
}

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEachStore(
                        self.store.scope(state: \.todos, action: AppAction.todo(index:action:)),
                        content: TodoView.init(store:)
                    )
                }
                .navigationBarItems(trailing: Button("Add") {
                    viewStore.send(.addButtonTapped)
                })
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
                environment: AppEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    uuid: UUID.init
                )
            )
        )
    }
}
