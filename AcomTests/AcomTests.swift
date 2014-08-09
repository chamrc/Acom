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
    
    func testExample() {
        var expectation = expectationWithDescription("Promise Test")
        
        var testResult = ""
        
        var promise = doReturnString()
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

    func doReturnString() -> Promise<String> {
        return Promise<String>(
            {
                (resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                    resolve(result: "42")
            }
        )
    }
    
}
