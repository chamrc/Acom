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
    private var handler: (() -> ())?
    
    init (_ asyncFunc: (resolve: OnResolved, reject: OnRejected) -> Void) {
        asyncFunc(onResolve, onRejected)
    }
    
    private func onResolve (result: T) -> Void {
        value = result
        state = .Fulfilled

        handle()
    }
    
    private func onRejected (reason: NSError) -> Void {
        self.reason = reason
        state = .Rejected
        
        handle()
    }
    
    private func handle() {
        if let handler = self.handler {
            dispatch_async(dispatch_get_main_queue(), { handler() })
        }
    }
    
    func then<U> (resolved: (T) -> U) -> Promise<U> {
        return Promise<U>( { (resolve, reject) -> Void in
            var returnVal: (U)?
            if self.state == .Fulfilled {
                if let value = self.value {
                    returnVal = resolved(value)
                    resolve(returnVal!)
                }
            } else {
                self.handler = {
                    if let value = self.value {
                        returnVal = resolved(value)
                        resolve(returnVal!)
                    }
                }
            }
        })
    }
    
    func catch (rejected: (NSError) -> Void) -> Promise<T> {
        return Promise<T>( { (resolve, reject) -> Void in
            if self.state == .Rejected {
                if let reason = self.reason {
                    rejected(reason)
                }
            } else {
                self.handler = {
                    if let reason = self.reason {
                        rejected(reason)
                    }
                }
            }
        })
    }
    
}