//
//  AcomTests.swift
//  AcomTests
//
//  Created by yanamura on 2014/08/09.
//  Copyright (c) 2014 Yasuharu Yanamura. All rights reserved.
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
        let expectation = expectationWithDescription("then_test1")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        ).then(
            {(result: String) -> Void in
                testResult = result
                expectation.fulfill()
            },
            {(reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
        })
    }

    func testThenWithTwoArguments_reject_sync() {
        let expectation = expectationWithDescription("then_test2")

        var testResult: NSError?
        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
        ).then(
            {(result: String) -> Void in
            },
            {(reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }

    func testThenWithTwoArguments_resolve_async() {
        let expectation = expectationWithDescription("then_test3")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                })
            }
        ).then(
            {(result: String) -> Void in
                testResult = result
                expectation.fulfill()
            },
            {(reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
        })
    }

    func testThenWithTwoArguments_reject_async() {
        let expectation = expectationWithDescription("then_test4")
        
        var testResult: NSError?
        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
                })
            }
        ).then(
            {(result: String) -> Void in
            },
            {(reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }

    func testThenWithTwoArguments_resolve_sync_chain() {
        let expectation = expectationWithDescription("then_test5")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        ).then(
            {(result: String) -> String in
                return result + "World"
            },
            {(reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        ).then(
            {(result: String) -> Void in
                testResult = result + "!!"
                expectation.fulfill()
            },
            {(reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("HelloWorld!!", testResult, "")
        })
    }

    // MARK: - then()
    func testThen_resolve_sync() {
        let expectation = expectationWithDescription("then_test6")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        ).then(
            {(result: String) -> Void in
                testResult = result
                expectation.fulfill()
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
        })
    }

    func testThen_resolve_sync_chain() {
        let expectation = expectationWithDescription("then_test7")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        ).then(
            {(result: String) -> String in
                testResult = result + "World"
                return testResult
            }
        ).then(
            {(result: String) -> Void in
                testResult = result + "!!"
                expectation.fulfill()
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("HelloWorld!!", testResult, "")
        })
    }

    // MARK: - catch()
    func testCatch_reject_sync() {
        let expectation = expectationWithDescription("catch_test1")

        var testResult: NSError?

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
        ).catch(
            {(reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }

    func testCatch_reject_sync_chain() {
        let expectation = expectationWithDescription("catch_test2")

        var testResult: NSError?

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
        ).then(
            {(result: String) -> String in
                return result + "World"
            }
        ).catch(
            {(reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }

    // MARK: - Promise.resolve()
    func testThenWithTwoArguments_static_resolve() {
        let expectation = expectationWithDescription("resolve_test1")

        var testResult = ""

        var promise = Promise.resolve("Hello").then(
            {(result: String) -> Void in
                testResult = result
                expectation.fulfill()
            },
            {(reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
        })
    }

    // MARK: - Promise.reject()
    func testThenWithTwoArguments_static_reject() {
        let expectation = expectationWithDescription("reject_test1")

        var testResult: NSError?
        let error = NSError(domain: "test", code: 1, userInfo: nil)
        var promise = Promise<NSError>.reject(error).catch(
            {(reason: NSError) -> NSError in
                testResult = reason
                expectation.fulfill()
                return testResult!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }

    // MARK: - Promise.all()
    func testAll_resolve_immediately() {
        let expectation = expectationWithDescription("all_test1")

        var testResults:[Any]?

        var promise = Promise.all([
            Promise.resolve("1"),
            Promise.resolve("2"),
            Promise.resolve("3"),
        ]).then(
            {(result: [Any]) -> Void in
                testResults = result
                expectation.fulfill()
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            if let result = testResults![0] as? String {
                XCTAssertEqual("1", result, "")
            } else {
                XCTFail("")
            }
            if let result = testResults![1] as? String {
                XCTAssertEqual("2", result, "")
            } else {
                XCTFail("")
            }
            if let result = testResults![2] as? String {
                XCTAssertEqual("3", result, "")
            } else {
                XCTFail("")
            }
        })
    }

    // MARK: - Promise.race()
    func testRace_resolve_immediately() {
        let expectation = expectationWithDescription("race_test1")

        var testResult:Any?

        var promise = Promise.race([
            Promise.resolve("1"),
            Promise.resolve("2"),
            Promise.resolve("3"),
        ]).then(
            {(result: Any) -> Void in
                testResult = result

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    expectation.fulfill()
                })
            }
        )
        
        waitForExpectationsWithTimeout(10, handler: {error in
            if let result = testResult as? String {
                XCTAssertEqual("1", result, "")
            } else {
                XCTFail("")
            }
        })
    }


    // MARK: - thenOn(,)
    func testThenOnWithTwoArguments_resolve_sync() {
        let expectation = expectationWithDescription("thenon_test1")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
            ).thenOn(
                {(result: String) -> Void in
                    testResult = result
                    expectation.fulfill()
                },
                {(reason: NSError) -> NSError in
                    return NSError(domain: "test", code: 1, userInfo: nil)
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
        })
    }

    func testOnThenWithTwoArguments_reject_sync() {
        let expectation = expectationWithDescription("thenon_test2")

        var testResult: NSError?
        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
            ).thenOn(
                {(result: String) -> Void in
                },
                {(reason: NSError) -> NSError in
                    testResult = reason
                    expectation.fulfill()
                    return testResult!
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }

    func testThenOnWithTwoArguments_resolve_async() {
        let expectation = expectationWithDescription("thenon_test3")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                })
            }
            ).thenOn(
                {(result: String) -> Void in
                    testResult = result
                    expectation.fulfill()
                },
                {(reason: NSError) -> NSError in
                    return NSError(domain: "test", code: 1, userInfo: nil)
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
        })
    }

    func testThenOnWithTwoArguments_reject_async() {
        let expectation = expectationWithDescription("thenon_test4")

        var testResult: NSError?
        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
                })
            }
            ).thenOn(
                {(result: String) -> Void in
                },
                {(reason: NSError) -> NSError in
                    testResult = reason
                    expectation.fulfill()
                    return testResult!
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }

    func testThenOnWithTwoArguments_resolve_sync_chain() {
        let expectation = expectationWithDescription("thenon_test5")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
            ).thenOn(
                {(result: String) -> String in
                    return result + "World"
                },
                {(reason: NSError) -> NSError in
                    return NSError(domain: "test", code: 1, userInfo: nil)
                }
            ).thenOn(
                {(result: String) -> Void in
                    testResult = result + "!!"
                    expectation.fulfill()
                },
                {(reason: NSError) -> NSError in
                    return NSError(domain: "test", code: 1, userInfo: nil)
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("HelloWorld!!", testResult, "")
        })
    }

    // MARK: - thenOn()
    func testThenOn_resolve_sync() {
        let expectation = expectationWithDescription("thenon_test6")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
            ).thenOn(
                {(result: String) -> Void in
                    testResult = result
                    expectation.fulfill()
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult, "")
        })
    }

    func testThenOn_resolve_sync_chain() {
        let expectation = expectationWithDescription("thenon_test7")

        var testResult = ""

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
            ).thenOn(
                {(result: String) -> String in
                    testResult = result + "World"
                    return testResult
                }
            ).thenOn(
                {(result: String) -> Void in
                    testResult = result + "!!"
                    expectation.fulfill()
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("HelloWorld!!", testResult, "")
        })
    }

    // MARK: - catchOn()
    func testCatchOn_reject_sync() {
        let expectation = expectationWithDescription("catchon_test1")

        var testResult: NSError?

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
            ).catchOn(
                {(reason: NSError) -> NSError in
                    testResult = reason
                    expectation.fulfill()
                    return testResult!
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }

    func testCatchOn_reject_sync_chain() {
        let expectation = expectationWithDescription("catchon_test2")

        var testResult: NSError?

        var promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
            ).thenOn(
                {(result: String) -> String in
                    return result + "World"
                }
            ).catchOn(
                {(reason: NSError) -> NSError in
                    testResult = reason
                    expectation.fulfill()
                    return testResult!
                }
        )
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
        })
    }
}
