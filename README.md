# _Acom_

_Acom is a Swift Promise library for iOS Based on Promises/A+ Spec and JavaScript ES6 Promises Interface._

## Interfaces

- Promise callbacks
  - then(...,  ...)
  - then(...)
  - catch(...)
- shorthands
  - resolve()
  - reject()
- Multiple Promises
  - all([ , , ])
  - race([ , , ])
- Promise callbacks running on main thread
  - thenOn(..., ...)
  - thenOn(...)
  - catchOn(...)

_Thenable is not supported_

_'thenOn' and 'catchOn' run on main thread. The others run on Acom Thread._

## Example

### chain
```
Promise(
  {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
    // do somthing async task

    // when async task finished
    if succeed {
        resolve(result: "Hello")
    } else {
        reject(reason: NSError(domain: "hoge", code: 400, userInfo: nil))
    }
}).then({ (value: String) -> Void in
    if value == "Hello" {
        self.isSuccess = true
    } else {
        self.isSuccess = false
    }
}).catchOn({ (reason: NSError) -> NSError in
    UIAlertView(
        title: reason.localizedDescription,
        message: reason.localizedRecoverySuggestion,
        delegate: nil,
        cancelButtonTitle: nil
    ).show()
    return reason;
})
```

### exit then as error
_if need to exit then method as error, use return Promise Object_
```
Promise(
  {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
    // do somthing async task

    // when async task finished
    if succeed {
        resolve(result: "Hello")
    } else {
        reject(reason: NSError(domain: "error1", code: 400, userInfo: nil))
    }
}).then({ (value: String) -> Promise<Any> in
    if value == "Hello1" {
        return Promise.resolve(1)
    } else {
        return Promise.reject(NSError(domain: "error2", code: 400, userInfo: nil))
    }
}).then({ (value: Any) -> Void in
    if value is Int {
        self.isSuccess = true
    } else {
        self.isSuccess = false
    }
}).catchOn({ (reason: NSError) -> NSError in
    UIAlertView(
        title: reason.localizedDescription,
        message: reason.localizedRecoverySuggestion,
        delegate: nil,
        cancelButtonTitle: nil
        ).show()
    return reason;
})
```

## How to use

_How do I run the project's automated tests?_
To use Acom to your iOS applications, follow these 4 easy steps:

1. Clone the Acom repository
2. Add Acom.xcodeproj to your test target
3. Link Acom.framework
4. import Acom when use Promise

## License
MIT
