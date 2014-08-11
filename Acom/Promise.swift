//
//  Promise.swift
//  Acom
//
//  Created by yanamura on 2014/08/09.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//

import Foundation

// TODO : define into class. can't define now because of compiler bug..
enum State {
        case Pending
        case Fulfilled
        case Rejected
    }

public class Promise<T,F> {
    typealias OnResolved = (T) -> Void
    typealias OnRejected = (F) -> Void
    
    private var state: State = .Pending
    private var value: (T)?
    private var reason: (F)?
    // TODO: multiple handler
    private var handler: (() -> ())?
    
    init(_ asyncFunc: (resolve: OnResolved, reject: OnRejected) -> Void) {
        asyncFunc(onResolve, onRejected)
    }

    class func resolve(result: T) -> Promise<T,NSError> {
        return Promise<T,NSError>(
            {
                (resolve: (result: T) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: result)
            }
        )
    }
    
    class func reject(reason: F) -> Promise<AnyObject,F> {
        return Promise<AnyObject,F>(
            {
                (resolve: (result: AnyObject) -> Void, reject: (reason: F) -> Void) -> Void in
                    reject(reason: reason)
            }
        )
    }
    
    private func onResolve(result: T) -> Void {
        if self.state == .Pending {
            value = result
            state = .Fulfilled

            handle()
        }
    }
    
    private func onRejected(reason: F) -> Void {
        if self.state == .Pending {
            self.reason = reason
            state = .Rejected
        
            handle()
        }
    }
    
    private func handle() {
        if let handler = self.handler {
            dispatch_async(dispatch_get_main_queue(), { handler() })
        }
    }
    
    func then<U>(resolved: (T) -> U) -> Promise<U,NSError> {
        return Promise<U,NSError>( { (resolve, reject) -> Void in
            var returnVal: (U)?
            switch self.state {
            case .Fulfilled:
                if let value = self.value {
                    returnVal = resolved(value)
                    resolve(returnVal!)
                }
            case .Rejected:
                reject(NSError(domain: "", code: 404, userInfo: nil))
            case .Pending:
                self.handler = {
                    if let value = self.value {
                        returnVal = resolved(value)
                        resolve(returnVal!)
                    }
                }
            }
        })
    }
    
    // TODO : func then<U> (resolved: (T) -> U, rejected: (NSError) -> Void) -> Promise<U>
    
    func catch(rejected: (F) -> Void) -> Promise<T,F> {
        return Promise<T,F>( { (resolve, reject) -> Void in
            switch self.state {
            case .Rejected:
                if let reason = self.reason {
                    rejected(reason)
                }
            case .Fulfilled:
                if let value = self.value {
                    resolve(value)
                }
            case .Pending:
                self.handler = {
                    if let reason = self.reason {
                        rejected(reason)
                    }
                }
            }
        })
    }
    
}