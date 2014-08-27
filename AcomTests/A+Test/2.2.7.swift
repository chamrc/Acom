//
//  2.2.7.swift
//  Acom
//
//  Created by yanamura on 2014/08/27.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//


import UIKit
import XCTest

class Tests2_2_7: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
        2.2.7: `then` must return a promise: `promise2 = promise1.then(onFulfilled, onRejected)`
    */
    func test2_2_7_is_a_promise() {
        let promise1 = Promise({(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
        })

        let promise2 = promise1.then(
            {(result: String) -> Void in
            }
        )

        XCTAssertNotNil(promise2, "")
    }

    /*
        2.2.7.1: If either `onFulfilled` or `onRejected` returns a value `x`, run the Promise Resolution Procedure `[[Resolve]](promise2, x)`
     */
    /*
        "see separate 3.3 tests"
    */

    /*
        2.2.7.2: If either `onFulfilled` or `onRejected` throws an exception `e`, `promise2` must be rejected with `e` as the reason.
    */
    /*
        // TODO: can't throw exception...
     */

    /*
        2.2.7.3: If `onFulfilled` is not a function and `promise1` is fulfilled, `promise2` must be fulfilled with the same value.
    */
    /*
        No need to test
    */

    /*
        2.2.7.4: If `onRejected` is not a function and `promise1` is rejected, `promise2` must be rejected with the same reason.
    */
    /*
        No need to test
    */
}
