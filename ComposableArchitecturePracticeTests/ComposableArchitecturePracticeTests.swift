//
//  ComposableArchitecturePracticeTests.swift
//  ComposableArchitecturePracticeTests
//
//  Created by Aikawa Kenta on 2020/07/01.
//  Copyright © 2020 Aikawa Kenta. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import ComposableArchitecturePractice

class ComposableArchitecturePracticeTests: XCTestCase {
    func testAddTodo() {
      let store = TestStore(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(
            uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }
        )
      )

      store.assert(
        .send(.addButtonTapped) {
            $0.todos = [
                Todo(
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!,
                    description: "",
                    isComplete: false
                )
            ]
        }
      )
    }

    func testCompletingTodo() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    ),
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        description: "Eggs",
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                uuid: { fatalError("umimplemented") }
            )
        )
        
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos = [
                    Todo(
                      id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                      description: "Eggs",
                      isComplete: false
                    ),
                    Todo(
                      id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                      description: "Milk",
                      isComplete: true
                    )
                ]
            }
        )
    }
}
