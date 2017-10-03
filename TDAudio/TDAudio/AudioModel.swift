//
//  AudioModel.swift
//  Audio
//
//  Created by TH on 9/8/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation

class AudioModel : NSObject, NSCoding {
    var id: String? = nil
    var name: String? = nil
    var speaker : Int = 0
    var url : String? = nil
    var image :String? = nil
    var isUnlocked : Bool = false
    
    override init() {
        
    }
    
    init(id: String, name: String, speaker : Int, url : String, image : String) {
        self.id = id
        self.name = name
        self.speaker = speaker
        self.url = url
        self.image = image
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let speaker = aDecoder.decodeInteger(forKey: "speaker")
        let url = aDecoder.decodeObject(forKey: "url") as! String
        let image = aDecoder.decodeObject(forKey: "image") as! String
        self.init(id: id, name: name, speaker: speaker, url: url, image : image)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(speaker, forKey: "speaker")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(image, forKey: "image")
    }
    
    func hasUnlocked() -> Bool {
        if !AdsManager.instance.isAdmobRewardEnable(){
            return true
        }
        return isUnlocked
    }
}

