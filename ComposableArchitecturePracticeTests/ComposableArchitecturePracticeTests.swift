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
    func testCompletingTodo() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        description: "Milk",
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment()
        )
        
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            }
        )
    }
}
