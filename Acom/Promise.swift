//
//  Promise.swift
//  Acom
//
//  Created by yanamura on 2014/08/09.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//

import Foundation

class Promise<T> {
    var deferred: ((T) -> Void)?
    
    init (asyncFunc: (resolve: (T) -> Void, reject: (NSError) -> Void) -> Void) {
        asyncFunc(onResolve, onRejected)
    }
    
    func onResolve (result: T) -> Void {
        dispatch_async(
            dispatch_get_main_queue(),
            {
                self.deferred!(result)
            }
        )
    }
    
    func onRejected (reason: NSError) -> Void {
        
    }
    
    func then (resolve: (T) -> Void) {
        deferred = resolve
    }
    
    func catch (reason: (NSError) -> Void) {
        
    }
}