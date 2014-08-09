//
//  Promise.swift
//  Acom
//
//  Created by yanamura on 2014/08/09.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//

import Foundation

enum State {
        case Pending
        case Fulfilled
        case Rejected
    }

class Promise<T> {
    var state: State = .Pending
    var deferred: ((T) -> Void)?
    var value: (T)?
    
    init (asyncFunc: (resolve: (T) -> Void, reject: (NSError) -> Void) -> Void) {
        asyncFunc(onResolve, onRejected)
    }
    
    func onResolve (result: T) -> Void {
        value = result
        state = .Fulfilled
        
        if let deferred = self.deferred {
            handle(deferred)
        }
    }
    
    func onRejected (reason: NSError) -> Void {
        
    }
    
    func then (resolve: (T) -> Void) {
        handle(resolve)
    }
    
    func catch (reason: (NSError) -> Void) {
        
    }
    
    func handle (resolve: (T) -> Void) {
        if state == .Pending {
            deferred = resolve
            return
        } else {
            if let value = self.value {
                resolve(value)
            }
        }
    }
}