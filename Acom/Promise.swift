//
//  Promise.swift
//  Acom
//
//  Created by yanamura on 2014/08/09.
//  Copyright (c) 2014 Yasuharu Yanamura. All rights reserved.
//

import Foundation

// FIXME : can't nest in generic type
enum State {
    case Pending
    case Fulfilled
    case Rejected
}

let dispatchQueue = dispatch_queue_create("AcomThread", DISPATCH_QUEUE_SERIAL)

public class Promise<T> {
    typealias OnResolved = (T) -> Void
    typealias OnRejected = (NSError?) -> Void

    private var state: State = .Pending
    private var value: (T)?
    private var reason: (NSError)?
    private var resolveHandler: [(() -> ())] = []
    private var rejectHandler: [(() -> ())] = []

    // MARK: - Initialize
    init(_ asyncFunc: (resolve: OnResolved, reject: OnRejected) -> Void) {
        asyncFunc(onResolve, onRejected)
    }

    // MARK: - Public Class Interface
    class func resolve(result: T) -> Promise<T> {
        return Promise<T>(
            {(resolve: (result: T) -> Void, reject) -> Void in
                resolve(result: result)
            }
        )
    }

    class func reject(reason: NSError) -> Promise<NSError> {
        return Promise<NSError>(
            {(resolve, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: reason)
            }
        )
    }

    class func all(promises: [Promise]) -> Promise<[Any]> {
        return Promise<[Any]>({ (resolve, reject) -> Void in
            var values = [Any]()
            var remain = promises.count
            for promise in promises {
                promise.then(
                    {(result: T) -> Void in
                        objc_sync_enter(self)
                        remain--
                        values.append(result)
                        if remain == 0 {
                            resolve(values)
                        }
                        objc_sync_exit(self)
                        return
                    }
                )
            }
        })
    }

    class func race(promises: [Promise]) -> Promise<Any> {
        return Promise<Any>({ (resolve, reject) -> Void in
            for promise in promises {
                promise.then({(result: T) -> Void in
                    resolve(result)
                })
            }
        })
    }

    // MARK: - Private Methods
    private func onResolve(result: T) -> Void {
        if self.state == .Pending {
            value = result
            state = .Fulfilled
            
            resolveHandle()
        }
    }

    private func onRejected(reason: NSError?) -> Void {
        if self.state == .Pending {
            self.reason = reason
            state = .Rejected
            
            rejectHandle()
        }
    }

    private func resolveHandle() {
        objc_sync_enter(self)
        for handler in resolveHandler {
            dispatch_async(dispatchQueue, { handler() })
        }
        objc_sync_exit(self)
    }

    private func rejectHandle() {
        objc_sync_enter(self)
        for handler in rejectHandler {
            dispatch_async(dispatchQueue, { handler() })
        }
        objc_sync_exit(self)
    }

    // MARK: - Pubic Interface
    private func then<U>(resolved: ((T) -> U), rejected: ((NSError) -> NSError)?, dispatchQueue: dispatch_queue_t) -> Promise<U> {
        return Promise<U>( { (resolve, reject) -> Void in
            var returnVal: (U)?
            var returnReason: (NSError)? // FIXME: return Promise...
            switch self.state {
            case .Fulfilled:
                dispatch_async(dispatchQueue, {
                    if let value = self.value {
                        // FIXME: do try-catch (Swift has no feature...)
                        returnVal = resolved(value)
                        if let returnVal = returnVal {
                            if let promise = returnVal as? Promise {
                                assert(false, "should not return Promise")
                            } else {
                                resolve(returnVal)
                            }
                        }
                    }
                })
            case .Rejected:
                dispatch_async(dispatchQueue, {
                    if let reason = self.reason {
                        returnReason = rejected?(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                })
            case .Pending:
                objc_sync_enter(self)
                self.resolveHandler.append({
                    if let value = self.value {
                        returnVal = resolved(value)
                        resolve(returnVal!)
                    }
                })
                self.rejectHandler.append({
                    if let reason = self.reason {
                        returnReason = rejected?(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                })
                objc_sync_exit(self)
            }
        })
    }

    // return Promise as onResolveHandler
    private func then<U>(resolved: ((T) -> Promise<U>), rejected: ((NSError) -> NSError)?, dispatchQueue: dispatch_queue_t) -> Promise<U> {
        return Promise<U>( { (resolve, reject) -> Void in
            var returnVal: (Promise<U>)?
            var returnReason: (NSError)? // FIXME: return Promise...
            switch self.state {
            case .Fulfilled:
                dispatch_async(dispatchQueue, {
                    if let value = self.value {
                        // FIXME: do try-catch (Swift has no feature...)
                        returnVal = resolved(value)
                        if let returnVal = returnVal {
                            switch returnVal.state {
                            case .Pending:
                                returnVal.resolveHandler.append({
                                    resolve(returnVal.value!)
                                })
                                returnVal.rejectHandler.append({
                                    reject(returnVal.reason!)
                                })
                                break
                            case .Fulfilled:
                                resolve(returnVal.value!)
                                break
                            case .Rejected:
                                reject(returnVal.reason!)
                                break
                            }
                        }
                    }
                })
            case .Rejected:
                dispatch_async(dispatchQueue, {
                    if let reason = self.reason {
                        returnReason = rejected?(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                })
            case .Pending:
                objc_sync_enter(self)
                self.resolveHandler.append({
                    if let value = self.value {
                        returnVal = resolved(value)
                        if let returnVal = returnVal {
                            switch returnVal.state {
                            case .Pending:
                                break
                            case .Fulfilled:
                                resolve(returnVal.value!)
                                break
                            case .Rejected:
                                reject(returnVal.reason!)
                                break
                            }
                        }
                    }
                })
                self.rejectHandler.append({
                    if let reason = self.reason {
                        returnReason = rejected?(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                })
                objc_sync_exit(self)
            }
        })
    }

    // use for resolved is nil. Because the type to pass to resolve method is different when resolved is nil or not nil.
    private func then(resolved: (T)?, rejected: ((NSError) -> NSError)?, dispatchQueue: dispatch_queue_t) -> Promise<T> {
        assert(resolved == nil)
        return Promise<T>( { (resolve, reject) -> Void in
            var returnReason: (NSError)? // FIXME: return Promise...
            switch self.state {
            case .Fulfilled:
                dispatch_async(dispatchQueue, {
                    if let value = self.value {
                        // FIXME: do try-catch (Swift has no feature...)
                        resolve(value)
                    }
                })
            case .Rejected:
                dispatch_async(dispatchQueue, {
                    if let reason = self.reason {
                        returnReason = rejected?(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                })
            case .Pending:
                objc_sync_enter(self)
                self.resolveHandler.append({
                    if let value = self.value {
                        resolve(value)
                    }
                })
                self.rejectHandler.append({
                    if let reason = self.reason {
                        returnReason = rejected?(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                })
                objc_sync_exit(self)
            }
        })
    }

    func then<U>(resolved: ((T) -> U), rejected: ((NSError) -> NSError)?) -> Promise<U> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatchQueue)
    }

    func then<U>(resolved: ((T) -> Promise<U>), rejected: ((NSError) -> NSError)?) -> Promise<U> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatchQueue)
    }

    func then(resolved: (T)?, rejected: ((NSError) -> NSError)?) -> Promise<T> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatchQueue)
    }

    func then<U>(resolved: ((T) -> U)) -> Promise<U> {
        return then(resolved, nil)
    }

    func then<U>(resolved: ((T) -> Promise<U>)) -> Promise<U> {
        return then(resolved, nil)
    }

    private func catch(rejected: (NSError) -> NSError, dispatchQueue: dispatch_queue_t) -> Promise<NSError> {
        return Promise<NSError>( { (resolve, reject) -> Void in
            var returnReason: (NSError)?
            switch self.state {
            case .Fulfilled:
                break
            case .Rejected:
                dispatch_async(dispatchQueue, {
                    if let reason = self.reason {
                        returnReason = rejected(reason)
                        reject(returnReason)
                    }
                })
            case .Pending:
                objc_sync_enter(self)
                self.rejectHandler.append({
                    if let reason = self.reason {
                        returnReason = rejected(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                })
                objc_sync_exit(self)
            }
        })
    }

    func catch(rejected: (NSError) -> NSError) -> Promise<NSError> {
        return self.catch(rejected, dispatchQueue: dispatchQueue)
    }
}
