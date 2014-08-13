//
//  Promise.swift
//  Acom
//
//  Created by yanamura on 2014/08/09.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//

import Foundation

// FIXME : define into class. can't define now because of compiler bug..
enum State {
        case Pending
        case Fulfilled
        case Rejected
    }

public class Promise<T> {
    typealias OnResolved = (T) -> Void
    typealias OnRejected = (NSError?) -> Void

    // TODO: private
    var state: State = .Pending
    var value: (T)?
    var reason: (NSError)?
    // TODO: multiple handler
    var resolveHandler: (() -> ())?
    var rejectHandler: (() -> ())?
    var thenPromise: Promise?

    // MARK: - Initialize
    init(_ asyncFunc: (resolve: OnResolved, reject: OnRejected) -> Void) {
        asyncFunc(onResolve, onRejected)
    }

    // MARK: - Public Class Interface
    class func resolve(result: T) -> Promise<T> {
        return Promise<T>(
            {
                (resolve: (result: T) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: result)
            }
        )
    }

    class func reject(reason: NSError) -> Promise<T> {
        return Promise<T>(
            {
                (resolve: (result: T) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: reason)
            }
        )
    }

    class func all(promises: [Promise]) -> Promise {
        return Promise({ (resolve, reject) -> Void in
            var values = [Any]()
            var remain = promises.count
            for promise in promises {
                promise.then(
                    {
                        (result: T) -> Void in
                        remain--
                        values.append(result)
                        if remain == 0 {
                            // resolved all
                            resolve(result) //FIXME: handle value
                        }
                        return
                    }
                )
            }
        })
    }

    // TODO: class func race()

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
        if let handler = self.resolveHandler {
            dispatch_async(dispatch_get_main_queue(), { handler() })
        }
    }

    private func rejectHandle() {
        if let handler = self.rejectHandler {
            dispatch_async(dispatch_get_main_queue(), { handler() })
        }
    }

    // MARK: - Pubic Interface
    func then<U>(resolved: ((T) -> U)?, rejected: ((NSError) -> NSError)?) -> Promise<U> {
        return Promise<U>( { (resolve, reject) -> Void in
            var returnVal: (U)?
            var returnReason: (NSError)? // FIXME: return Promise...
            switch self.state {
            case .Fulfilled:
                if let value = self.value {
                    // FIXME: do try-catch (Swift has no feature...)
                    returnVal = resolved?(value)
                    resolve(returnVal!)
                }
            case .Rejected:
                if let reason = self.reason {
                    returnReason = rejected?(reason)
                    if let returnReason = returnReason {
                        reject(returnReason)
                    } else {
                        reject(reason)
                    }
                }
            case .Pending:
                self.resolveHandler = {
                    if let value = self.value {
                        returnVal = resolved?(value)
                        resolve(returnVal!)
                    }
                }
                self.rejectHandler = {
                    if let reason = self.reason {
                        returnReason = rejected?(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                }
            }
        })
    }

    func then<U>(resolved: ((T) -> U)) -> Promise<U> {
        return then(resolved, nil)
    }

    func catch(rejected: (NSError) -> NSError) -> Promise<NSError> {
        return Promise<NSError>( { (resolve, reject) -> Void in
            var returnReason: (NSError)?
            switch self.state {
            case .Fulfilled:
                break
            case .Rejected:
                if let reason = self.reason {
                    returnReason = rejected(reason)
                    reject(returnReason)
                }
            case .Pending:
                self.rejectHandler = {
                    if let reason = self.reason {
                        returnReason = rejected(reason)
                        if let returnReason = returnReason {
                            reject(returnReason)
                        } else {
                            reject(reason)
                        }
                    }
                }
            }
        })
    }
}
