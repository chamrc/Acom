//
//  2.2.6.swift
//  Acom
//
//  Created by yanamura on 2014/08/18.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//


import UIKit
import XCTest

class Tests2_2_6: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
        2.2.6: `then` may be called multiple times on the same promise.
    */
    /*
        2.2.6.1: If/when `promise` is fulfilled, all respective `onFulfilled` callbacks must execute in the order of their originating calls to `then`.
    */
    func test2_2_6_1_multiple_boring_fulfillment_handlers() {
        let expectation = expectationWithDescription("test2_2_6_1")

        var testResult1: String?
        var testResult2: String?
        var testResult3: String?

        let promise = Promise.resolve("Hello")

        promise.then(
            {(result: String) -> Void in
                testResult1 = result
            }
        )
        promise.then(
            {(result: String) -> Void in
                testResult2 = result
            }
        )
        promise.then(
            {(result: String) -> Void in
                testResult3 = result
            }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(testResult1!, "Hello", "")
            XCTAssertEqual(testResult2!, "Hello", "")
            XCTAssertEqual(testResult3!, "Hello", "")
        })
    }

    /*
    can' throw exception
    func test2_2_6_1_multiple_fulfillment_handlers_one_of_which_throws() {

    }
    */

    func test2_2_6_1_results_in_multiple_branching_chains_with_their_own_fulfillment_values() {
        let expectation = expectationWithDescription("test2_2_6_2")

        var testResult1: String?
        var testResult2: String?
        var testResult3: String?

        let promise = Promise.resolve("Hello")

        promise.then(
            {(result: String) -> String in
                return result + "1"
            }
        ).then(
            {(result: String) -> Void in
                testResult1 = result
            }
        )
        promise.then(
            {(result: String) -> String in
                return result + "2"
            }
        ).then(
            {(result: String) -> Void in
                testResult2 = result
            }
        )
        promise.then(
            {(result: String) -> String in
                return result + "3"
            }
        ).then(
            {(result: String) -> Void in
                testResult3 = result
            }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(testResult1!, "Hello1", "")
            XCTAssertEqual(testResult2!, "Hello2", "")
            XCTAssertEqual(testResult3!, "Hello3", "")
        })
    }

    func test2_2_6_1_onFulfilled_handlers_are_called_in_the_original_order() {
        let expectation = expectationWithDescription("test2_2_6_3")

        var testResults = [String]()

        let promise = Promise.resolve("Hello")

        promise.then(
            {(result: String) -> Void in
                testResults.append(result + "1")
            }
        )
        promise.then(
            {(result: String) -> Void in
                testResults.append(result + "2")
            }
        )
        promise.then(
            {(result: String) -> Void in
                testResults.append(result + "3")
            }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(testResults[0], "Hello1", "")
            XCTAssertEqual(testResults[1], "Hello2", "")
            XCTAssertEqual(testResults[2], "Hello3", "")
        })
    }

    func test2_2_6_1_even_when_one_handler_is_added_inside_another_handler() {
        let expectation = expectationWithDescription("test2_2_6_4")

        var testResults = [String]()

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                })
            }
        )

        promise.then(
            {(result: String) -> Void in
                testResults.append(result + "1")
                promise.then(
                    {(result: String) -> Void in
                        testResults.append(result + "3")
                    }
                )
            }
        )

        promise.then(
            {(result: String) -> Void in
                testResults.append(result + "2")
            }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(testResults[0], "Hello1", "")
            XCTAssertEqual(testResults[1], "Hello2", "")
            XCTAssertEqual(testResults[2], "Hello3", "")
        })
    }
}