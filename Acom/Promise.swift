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
    var value: (T)?
    var fc: (() -> ())?
    
    init (asyncFunc: (resolve: (T) -> Void, reject: (NSError) -> Void) -> Void) {
        asyncFunc(onResolve, onRejected)
    }
    
    func onResolve (result: T) -> Void {
        value = result
        state = .Fulfilled

        if let fc = self.fc {
            fc()
        }
    }
    
    func onRejected (reason: NSError) -> Void {
        
    }
    
    func then<U> (resolved: (T) -> U) -> Promise<U> {
        return Promise<U>(asyncFunc: { (resolve, reject) -> Void in
            var retval: (U)?
            if self.state == .Fulfilled {
                if let value = self.value {
                    retval = resolved(value)
                    resolve(retval!)
                }
            } else {
                self.fc = {
                    if let value = self.value {
                        retval = resolved(value)
                        resolve(retval!)
                    }
                }
            }
        })
    }
    
    func catch (reason: (NSError) -> Void) {
        
    }
    
}