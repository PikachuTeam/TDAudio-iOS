//
//  DymanicType.swift
//  Audio
//
//  Created by TH on 9/15/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation

class DynamicType<T> {
    typealias EventListener =  (T) -> Void
    private var listeners : [String: EventListener] = [:]
    
    var value: T?{
        didSet{
            listeners.forEach { (key, listener) in
                if let value = value{
                    listener(value)
                }
            }
        }
    }
    
    func bind(identifier: String, listener: @escaping EventListener)  {
        listeners[identifier] = listener
    }
    
    func unBind(identifier: String)  {
        listeners.removeValue(forKey: identifier)
    }

}




