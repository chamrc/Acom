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
    
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    func testPromiseCallResolveAsSyncAndCallThenSync() {
        var expectation = expectationWithDescription("Promise Test")
        
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
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual("Hello", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
        })
    }
    
    func testPromiseCallRejectAsSyncAndCallThenSync() {
        var expectation = expectationWithDescription("Promise Test")
        
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
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
            
            // Debug
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), promise.reason!, "")
            XCTAssertEqual(State.Rejected, promise.state, "")
            XCTAssertEqual(State.Rejected, promise2.state, "")
        })
    }
    
    func testPromiseCallResolveAsAsyncAndCallThenSync() {
        var expectation = expectationWithDescription("Promise Test")
        
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
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual("Hello", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
        })
    }
    
    func testPromiseCallRejectAsAsyncAndCallThenSync() {
        var expectation = expectationWithDescription("Promise Test")
        
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
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), testResult!, "")
            
            // Debug
            XCTAssertEqual(NSError(domain: "test", code: 1, userInfo: nil), promise.reason!, "")
            XCTAssertEqual(State.Rejected, promise.state, "")
            XCTAssertEqual(State.Rejected, promise2.state, "")
        })
    }
    
    func testPromiseCallResolveAsSyncAndCallThenThenChain() {
        var expectation = expectationWithDescription("Promise Test")
        
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
                testResult = result
                expectation.fulfill()
            },
            {
                (reason: NSError) -> NSError in
                return NSError(domain: "test", code: 1, userInfo: nil)
            }
        )
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual("HelloWorld", testResult, "")
            // Debug
            XCTAssertEqual("Hello", promise.value!, "")
            XCTAssertEqual("HelloWorld", promise2.value!, "")
            XCTAssertEqual(State.Fulfilled, promise.state, "")
            XCTAssertEqual(State.Fulfilled, promise2.state, "")
        })
    }
    
}
