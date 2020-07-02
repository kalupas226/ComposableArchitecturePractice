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
}
