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


}
