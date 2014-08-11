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
        
        var promise = Promise<String>(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                    resolve(result: "42")
            }
        )
        promise.then(
            {
                (result: String) -> Void in
                    testResult = result
                    expectation.fulfill()
            }
        )
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
                XCTAssertEqual("42", testResult, "")
        })
    }

    func testPromiseCallResolveAsSyncAndCallThenAsync() {
        var expectation = expectationWithDescription("Promise Test")
        
        var testResult = ""
        
        var promise = Promise<String>(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "42")
            }
        )
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue(), {
            promise.then(
                {
                    (result: String) -> Void in
                    testResult = result
                    expectation.fulfill()
                }
            )
            return
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual("42", testResult, "")
        })
    }

    func testPromiseCallResolveAsAsync() {
        var expectation = expectationWithDescription("Promise Test")
        
        var testResult = ""
        
        var promise = Promise<String>(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue(), {
                        resolve(result: "42")
                    }
                )
            }
        )
        promise.then(
            {
                (result: String) -> Void in
                testResult = result
                expectation.fulfill()
            }
        )
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual("42", testResult, "")
        })
    }

    func testPromiseCallThen2times() {
        var expectation = expectationWithDescription("Promise Test")
        
        var testResult = ""
        
        var promise = Promise<String>(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue(), {
                    resolve(result: "42")
                })
            }
        )
        promise.then(
            {
                (result: String) -> String in
                testResult = result
                return result
            }
        ).then(
            {
                (result: String) -> Void in
                testResult = result + "Hoge"
                expectation.fulfill()
            }
        )
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual("42Hoge", testResult, "")
        })
    }

    func testPromiseCallThenWithPromise() {
        var expectation = expectationWithDescription("Promise Test")
        
        var testResult = ""
        
        var promise = Promise<String>(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue(), {
                    resolve(result: "42")
                })
            }
        )
        promise.then(
            {
                (result: String) -> Promise<String> in
                return Promise(
                    {
                        (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue(), {
                            resolve(result: result + "Hello")
                        })
                    }
                )
            }
        ).then(
            {
                (result: Promise) -> Void in
                result.then(
                    {
                        (result: String) -> Void in
                        testResult = result
                        expectation.fulfill()
                    }
                )
                return
            }
        )
        
        waitForExpectationsWithTimeout(15, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual("42Hello", testResult, "")
        })
    }
    
    //// reject
    func testPromiseReject() {
        var expectation = expectationWithDescription("Promise Test")
        
        var testReason: NSError? = nil
        
        var promise = Promise<String>(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue(), {
                    let error = NSError(domain: "test", code: 404, userInfo: nil)
                    reject(reason: error)
                })
            }
        )
        promise.catch({
            (reason: NSError) -> Void in
                testReason = reason
                expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            var expectError = NSError(domain: "test", code: 404, userInfo: nil)
            XCTAssertEqual(testReason!, expectError, "")
        })
    }
    
    // Promise.resolve
    func testPromiseCallResolve() {
        var expectation = expectationWithDescription("Promise Test")
        
        var testResult = ""
        
        Promise.resolve("42").then(
            {
                (result: String) -> Void in
                testResult = result
                expectation.fulfill()
            }
        )
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            XCTAssertEqual("42", testResult, "")
        })
    }

    // Promise.reject
    func testPromiseCallReject() {
        var expectation = expectationWithDescription("Promise Test")
        
        var testReason: NSError? = nil
        
        var error = NSError(domain: "test", code: 404, userInfo: nil)
        Promise<NSError>.reject(error).catch({
            (reason: NSError) -> Void in
            testReason = reason
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error: NSError!) -> Void in
            var expectError = NSError(domain: "test", code: 404, userInfo: nil)
            XCTAssertEqual(testReason!, expectError, "")
        })
    }

}
