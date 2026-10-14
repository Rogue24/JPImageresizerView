//
//  NotificationCenter+Extension.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/9.
//

import Foundation

extension NotificationCenter: JPCompatible {}
extension JP where Base: NotificationCenter {
    // MARK: - Remove
    static func removeObserver(_ observer: Any,
                               name: NSNotification.Name? = nil,
                               object: Any? = nil) {
        guard let aName = name else {
            Base.default.removeObserver(observer)
            return
        }
        
        Base.default.removeObserver(observer,
                                    name: aName,
                                    object: object)
    }
    
    static func removeObserver(_ observer: Any,
                               name: String? = nil,
                               object: Any? = nil) {
        guard let aName = name else {
            Base.default.removeObserver(observer)
            return
        }
        
        Base.default.removeObserver(observer,
                                    name: Notification.Name(aName),
                                    object: object)
    }
    
    static func removeObserver(_ observer: Any,
                               key: Notification.Name.Key? = nil,
                               object: Any? = nil) {
        guard let key else {
            Base.default.removeObserver(observer)
            return
        }
        
        Base.default.removeObserver(observer,
                                    name: key.name,
                                    object: object)
    }
    
    // MARK: - Add
    static func addObserver(_ observer: Any,
                            selector aSelector: Selector,
                            name aName: NSNotification.Name,
                            object anObject: Any? = nil) {
        Base.default.addObserver(observer,
                                 selector: aSelector,
                                 name: aName,
                                 object: anObject)
    }
    
    static func addObserver(_ observer: Any,
                            selector aSelector: Selector,
                            name aName: String,
                            object anObject: Any? = nil) {
        Base.default.addObserver(observer,
                                 selector: aSelector,
                                 name: Notification.Name(aName),
                                 object: anObject)
    }
    
    static func addObserver(_ observer: Any,
                            selector aSelector: Selector,
                            key: Notification.Name.Key,
                            object anObject: Any? = nil) {
        Base.default.addObserver(observer,
                                 selector: aSelector,
                                 name: key.name,
                                 object: anObject)
    }
    
    static func addObserver(forName name: NSNotification.Name,
                            object obj: Any? = nil,
                            queue: OperationQueue? = nil,
                            using block: @escaping (Notification) -> Void) {
        Base.default.addObserver(forName: name,
                                 object: obj,
                                 queue: queue,
                                 using: block)
    }
    
    static func addObserver(forName name: String,
                            object obj: Any? = nil,
                            queue: OperationQueue? = nil,
                            using block: @escaping (Notification) -> Void) {
        Base.default.addObserver(forName: Notification.Name(name),
                                 object: obj,
                                 queue: queue,
                                 using: block)
    }
    
    static func addObserver(forKey key: Notification.Name.Key,
                            object obj: Any? = nil,
                            queue: OperationQueue? = nil,
                            using block: @escaping (Notification) -> Void) {
        Base.default.addObserver(forName: key.name,
                                 object: obj,
                                 queue: queue,
                                 using: block)
    }
    
    // MARK: - Post
    static func post(name aName: NSNotification.Name,
                     object anObject: Any? = nil,
                     userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        Base.default.post(name: aName,
                          object: anObject,
                          userInfo: aUserInfo)
    }
    
    static func post(name aName: String,
                     object anObject: Any? = nil,
                     userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        Base.default.post(name: Notification.Name(aName),
                          object: anObject,
                          userInfo: aUserInfo)
    }
    
    static func post(key: Notification.Name.Key,
                     object anObject: Any? = nil,
                     userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        Base.default.post(name: key.name,
                          object: anObject,
                          userInfo: aUserInfo)
    }
}
