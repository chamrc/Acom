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

public class Promise<T> {
    typealias OnResolved = (T) -> Void
    typealias OnRejected = (NSError) -> Void
    
    private var state: State = .Pending
    private var value: (T)?
    private var reason: (NSError)?
    // TODO: multiple handler
    private var handler: (() -> ())?
    
    init (_ asyncFunc: (resolve: OnResolved, reject: OnRejected) -> Void) {
        asyncFunc(onResolve, onRejected)
    }
    
    private func onResolve (result: T) -> Void {
        if self.state == .Pending {
            value = result
            state = .Fulfilled

            handle()
        }
    }
    
    private func onRejected (reason: NSError) -> Void {
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
    
    func then<U> (resolved: (T) -> U) -> Promise<U> {
        return Promise<U>( { (resolve, reject) -> Void in
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
    
    func catch (rejected: (NSError) -> Void) -> Promise<T> {
        return Promise<T>( { (resolve, reject) -> Void in
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