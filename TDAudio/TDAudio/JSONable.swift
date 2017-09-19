//
//  JSONable.swift
//  Audio
//
//  Created by TH on 9/8/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation

protocol JSONAble {}

extension JSONAble {
    func toDict() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                if(child.value is JSONAble){
                    dict[key] = (child.value as! JSONAble).toDict()
                }else{
                    dict[key] = child.value
                }
            }
            
            
        }
        return dict
    }
}
