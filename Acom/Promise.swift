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
    public typealias OnResolved = (T) -> Void
    public typealias OnRejected = (NSError?) -> Void

    private var state: State = .Pending
    private var value: (T)?
    private var reason: (NSError)?
    private var resolveHandler: [(handler: () -> (), queue: dispatch_queue_t)] = []
    private var rejectHandler: [(handler: () -> (), queue: dispatch_queue_t)] = []

    // MARK: - Initialize
    public init(_ asyncFunc: (resolve: OnResolved, reject: OnRejected) -> Void) {
        asyncFunc(onResolve, onRejected)
    }

    // MARK: - Public Class Interface
    public class func resolve(result: T) -> Promise<T> {
        return Promise<T>(
            {(resolve: (result: T) -> Void, reject) -> Void in
                resolve(result: result)
            }
        )
    }

    public class func reject(reason: NSError) -> Promise {
        return Promise(
            {(resolve, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: reason)
            }
        )
    }

    public class func all(promises: [Promise]) -> Promise<[Any]> {
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

    public class func race(promises: [Promise]) -> Promise<Any> {
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
        objc_sync_enter(self)
        if self.state == .Pending {
            value = result
            state = .Fulfilled
            
            resolveHandle()
        }
        objc_sync_exit(self)
    }

    private func onRejected(reason: NSError?) -> Void {
        objc_sync_enter(self)
        if self.state == .Pending {
            self.reason = reason
            state = .Rejected
            
            rejectHandle()
        }
        objc_sync_exit(self)
    }

    private func resolveHandle() {
        for handler in resolveHandler {
            dispatch_async(handler.queue, { handler.handler() })
        }
    }

    private func rejectHandle() {
        for handler in rejectHandler {
            dispatch_async(handler.queue, { handler.handler() })
        }
    }

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
                self.resolveHandler.append(
                    handler: {
                        if let value = self.value {
                            returnVal = resolved(value)
                            resolve(returnVal!)
                        }
                    },
                    queue: dispatchQueue
                )
                self.rejectHandler.append(
                    handler: {
                        if let reason = self.reason {
                            returnReason = rejected?(reason)
                            if let returnReason = returnReason {
                                reject(returnReason)
                            } else {
                                reject(reason)
                            }
                        }
                    },
                    queue: dispatchQueue
                )
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
                                returnVal.resolveHandler.append(
                                    handler: {
                                        resolve(returnVal.value!)
                                    },
                                    queue: dispatchQueue
                                )
                                returnVal.rejectHandler.append(
                                    handler: {
                                        reject(returnVal.reason!)
                                    },
                                    queue: dispatchQueue
                                )
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
                self.resolveHandler.append(
                    handler: {
                        if let value = self.value {
                            returnVal = resolved(value)
                            if let returnVal = returnVal {
                                switch returnVal.state {
                                case .Pending:
                                    returnVal.then(
                                        { U -> Void in
                                            resolve(returnVal.value!)
                                        },
                                        rejected: { NSError -> NSError in
                                            reject(returnVal.reason!)
                                            return returnVal.reason!
                                        },
                                        dispatchQueue: dispatchQueue
                                    )
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
                    },
                    queue: dispatchQueue
                )
                self.rejectHandler.append(
                    handler: {
                        if let reason = self.reason {
                            returnReason = rejected?(reason)
                            if let returnReason = returnReason {
                                reject(returnReason)
                            } else {
                                reject(reason)
                            }
                        }
                    },
                    queue: dispatchQueue
                )
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
                self.resolveHandler.append(
                    handler: {
                        if let value = self.value {
                            resolve(value)
                        }
                    },
                    queue: dispatchQueue
                )
                self.rejectHandler.append(
                    handler: {
                        if let reason = self.reason {
                            returnReason = rejected?(reason)
                            if let returnReason = returnReason {
                                reject(returnReason)
                            } else {
                                reject(reason)
                            }
                        }
                    },
                    queue: dispatchQueue
                )
                objc_sync_exit(self)
            }
        })
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
                self.rejectHandler.append(
                    handler: {
                        if let reason = self.reason {
                            returnReason = rejected(reason)
                            if let returnReason = returnReason {
                                reject(returnReason)
                            } else {
                                reject(reason)
                            }
                        }
                    },
                    queue: dispatchQueue
                )
                objc_sync_exit(self)
            }
        })
    }

    //MARK: - Pubic Interface
    public func then<U>(resolved: ((T) -> U), rejected: ((NSError) -> NSError)?) -> Promise<U> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatchQueue)
    }

    public func then<U>(resolved: ((T) -> Promise<U>), rejected: ((NSError) -> NSError)?) -> Promise<U> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatchQueue)
    }

    public func then(resolved: (T)?, rejected: ((NSError) -> NSError)?) -> Promise<T> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatchQueue)
    }

    public func then<U>(resolved: ((T) -> U)) -> Promise<U> {
        return then(resolved, nil)
    }

    public func then<U>(resolved: ((T) -> Promise<U>)) -> Promise<U> {
        return then(resolved, nil)
    }

    public func catch(rejected: (NSError) -> NSError) -> Promise<NSError> {
        return self.catch(rejected, dispatchQueue: dispatchQueue)
    }

    //MARK: for main thread
    public func thenOn<U>(resolved: ((T) -> U), rejected: ((NSError) -> NSError)?) -> Promise<U> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatch_get_main_queue())
    }

    public func thenOn<U>(resolved: ((T) -> Promise<U>), rejected: ((NSError) -> NSError)?) -> Promise<U> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatch_get_main_queue())
    }

    public func thenOn(resolved: (T)?, rejected: ((NSError) -> NSError)?) -> Promise<T> {
        return self.then(resolved, rejected: rejected, dispatchQueue: dispatch_get_main_queue())
    }

    public func thenOn<U>(resolved: ((T) -> U)) -> Promise<U> {
        return thenOn(resolved, nil)
    }

    public func thenOn<U>(resolved: ((T) -> Promise<U>)) -> Promise<U> {
        return thenOn(resolved, nil)
    }

    public func catchOn(rejected: (NSError) -> NSError) -> Promise<NSError> {
        return self.catch(rejected, dispatchQueue: dispatch_get_main_queue())
    }
}
