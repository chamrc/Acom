//
//  AcomTests.swift
//  AcomTests
//
//  Created by yanamura on 2014/08/09.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//

import UIKit
import XCTest

class PromiseTests: XCTestCase {

    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {

        super.tearDown()
    }

    // MARK: - then(,)
    func testThenWithTwoArguments_resolve_sync() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult = ""

        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        var promise2 = promise.then(
            {
                (result: String) -> Void in
                testResult = result
                expectation.fulfill()
            },
            {
                (reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
        })
    }

    func testThenWithTwoArguments_reject_sync() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: NSError?
        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                    reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
        )
        var promise2 = promise.then(
            {
                (result: String) -> Void in
            },
            {
                (reason: NSError) -> NSError in
                    testResult = reason
                    expectation.fulfill()
                    return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
            
            // Debug
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), promise.reason!, "")
            XCTAssertEqual(State.Rejected, promise.state, "")
            XCTAssertEqual(State.Rejected, promise2.state, "")
        })
    }

    func testThenWithTwoArguments_resolve_async() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult = ""

        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                })
            }
        )
        var promise2 = promise.then(
            {
                (result: String) -> Void in
                testResult = result
                expectation.fulfill()
            },
            {
                (reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
        })
    }

    func testThenWithTwoArguments_reject_async() {
        let expectation = expectationWithDescription("Promise Test")
        
        var testResult: NSError?
        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue(), {
                    reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
                })
            }
        )
        var promise2 = promise.then(
            {
                (result: String) -> Void in
            },
            {
                (reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")

            // Debug
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), promise.reason!, "")
            XCTAssertEqual(State.Rejected, promise.state, "")
            XCTAssertEqual(State.Rejected, promise2.state, "")
        })
    }

    func testThenWithTwoArguments_resolve_sync_chain() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult = ""

        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        var promise2 = promise.then(
            {
                (result: String) -> String in
                return result + "World"
            },
            {
                (reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )
        var promise3 = promise2.then(
            {
                (result: String) -> Void in
                testResult = result + "!!"
                expectation.fulfill()
            },
            {
                (reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("HelloWorld!!", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual("HelloWorld", promise2.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
        })
    }

    // MARK: - then()
    func testThen_resolve_sync() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult = ""

        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        var promise2 = promise.then(
            {
                (result: String) -> Void in
                testResult = result
                expectation.fulfill()
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
        })
    }

    func testThen_resolve_sync_chain() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult = ""

        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        var promise2 = promise.then(
            {
                (result: String) -> String in
                testResult = result + "World"
                return testResult
            }
        )
        var promise3 = promise2.then(
            {
                (result: String) -> Void in
                testResult = result + "!!"
                expectation.fulfill()
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("HelloWorld!!", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
            XCTAssertEqual(State.Fulfilled, promise3.state, "")
        })
    }

    // MARK: - catch()
    func testCatch_reject_sync() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: NSError?

        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
        )
        var promise2 = promise.catch(
            {
                (reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
            // Debug
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), promise.reason!, "")
            XCTAssertEqual(State.Rejected, promise.state, "")
            XCTAssertEqual(State.Rejected, promise2.state, "")
        })
    }

    func testCatch_reject_sync_chain() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: NSError?

        var promise = Promise(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
        )
        var promise2 = promise.then(
            {
                (result: String) -> String in
                return result + "World"
            }
        )
        var promise3 = promise2.catch(
            {
                (reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
            // Debug
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), promise.reason!, "")
            XCTAssertEqual(State.Rejected, promise.state, "")
            XCTAssertEqual(State.Rejected, promise2.state, "")
        })
    }

    // MARK: - Promise.resolve()
    func testThenWithTwoArguments_static_resolve() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult = ""

        var promise = Promise.resolve("Hello")
        var promise2 = promise.then(
            {
                (result: String) -> Void in
                testResult = result
                expectation.fulfill()
            },
            {
                (reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
        })
    }

    // MARK: - Promise.reject()
    func testThenWithTwoArguments_static_reject() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: NSError?
        var error = NSError(domain: "test", code: 1, userInfo: nil)
        var promise = Promise<NSError>.reject(error)
        var promise2 = promise.catch(
            {
                (reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")

            // Debug
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), promise.reason!, "")
            XCTAssertEqual(State.Rejected, promise.state, "")
            XCTAssertEqual(State.Rejected, promise2.state, "")
        })
    }

}
