//
//  DataManager.swift
//  Audio
//
//  Created by TH on 9/7/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation
import Firebase
import Parse
import SwiftyJSON
import CleanroomLogger

class DataManager {
    
    static let instance = DataManager()
    
    private let remoteConfig : RemoteConfig
    private let userDefaults : UserDefaults
    private var originalItems: [AudioModel]? = nil
    
    private lazy var items : [AudioModel] = {
        return self.originalItems!
    }()
    
    private var imageSet : [String]? = nil
    private var unlockedStatus : [String:Bool] = [:]
    
    
    private init (){
        remoteConfig = RemoteConfig.remoteConfig()
        userDefaults = UserDefaults.standard
    }
    
    func fetchData(error: @escaping Error, completion : @escaping Completion)  {
        let localData = getLocalData()
        Log.info?.message("start cheking audio version")
        checkVersion(localVersion: getLocalAudioVersion(), localData: localData) { (isSuccessful, isNewVersionAvailable, version) in
            Log.info?.message("checking version is Done \nisSuccessful = \(isSuccessful), isNewVersionAvailable = \(isNewVersionAvailable), version = \(version))")
            let isInReview = self.isInReview()
            if(isSuccessful){
                if(!isNewVersionAvailable){
                    if !isInReview {
                        completion()
                        return
                    }
                }
            }else{
                if(localData != nil){
                    completion()
                    return
                }
            }
            let tableNameRelease = isInReview ? Constants.Parse.TABLE_NAME_REVIEW : Constants.Parse.TABLE_NAME
            
            Log.info?.message("start getting data")
            let tableName = Constants.BuildConfig.DEBUG ? Constants.Parse.TABLE_NAME_DEBUG : tableNameRelease
            let query = PFQuery(className: tableName)
            query.order(byAscending: "createdAt")
            query.findObjectsInBackground(block: { (result, parseErr) in
                Log.info?.message("getting data is done\ndata size = \(String(describing: result?.count))")
                
                guard parseErr == nil else{
                    Log.error?.message("Error when getting data error = \(parseErr.debugDescription)" )
                    error(0)
                    return
                }
                if let result = result {
                    let audioModelList =  self.parseData(objects: result)
                    
                    //save data to local
                    self.setLocalData(audioModelList: audioModelList)
                    self.setLocalAudioVersion(version: version)
                    
                    completion()
                    
                }
            })
        }
    }
    
    func getAudioIndex(item: AudioModel) -> Int? {
        return items.index(of: item)
    }
    
    func getImageCount() -> Int {
        return userDefaults.integer(forKey: Constants.DataStore.KEY_IMAGE_COUNT)
    }
    
    func setImageCount(count: Int)  {
        userDefaults.set(count, forKey: Constants.DataStore.KEY_IMAGE_COUNT)
    }
    
    func getImageSet() -> [String]? {
        if(imageSet == nil){
            if !Constants.BuildConfig.DEBUG{
                let images = getImages()
                if let images = images{
                    imageSet = images.components(separatedBy: ",")
                }
            }else{
                imageSet = Constants.DataStore.IMAGES_PREVIEW_DEBUG
            }
        }
        return imageSet
    }
    
    func getData(filter: SpeakerFilter) -> [AudioModel] {
        switch filter {
        case .Male:
            items = getLocalData()!.filter({ (item) -> Bool in
                return item.speaker==1
            })
            break
        case .Female:
            items = getLocalData()!.filter({ (item) -> Bool in
                return item.speaker==0
            })
            break
        default:
            items = getLocalData()!
        }
        addAdsItemsIfNeeded(items: &items)
        
        items.forEach { (item) in
            if !item.isAdsItem{
                item.isUnlocked = isItemUnlocked(id: item.id!)
            }
        }
        AudioManager.instance.reloadAudioIndex()
        return items
    }
    
    func getItem(atIndex: Int?) -> AudioModel? {
        if let atIndex = atIndex{
            let a = atIndex % items.count
            if a >= 0 {
                return items[a]
            }
            return items[items.count - abs(a)]
        }
        return nil
    }
    
    func setAudioUnlockedStatus(unlockedStatus: [String:Bool])  {
        self.unlockedStatus = unlockedStatus
        userDefaults.set(unlockedStatus, forKey: Constants.DataStore.KEY_AUDIO_UNLOCKED_STATUS)
    }
    
    func getAudioUnlockedStatus() -> [String:Bool] {
        if(unlockedStatus.count == 0 ){
            let status = userDefaults.dictionary(forKey: Constants.DataStore.KEY_AUDIO_UNLOCKED_STATUS) as? [String : Bool]
            if let status = status{
                unlockedStatus = status
            }
            return unlockedStatus
        }
        return unlockedStatus
    }
    
    func isItemUnlocked(id: String) -> Bool {
        let status = getAudioUnlockedStatus()
        let exist = status.index(forKey: id) != nil
        if exist {
            return unlockedStatus[id]!
        }
        return false
    }
    
    func setUnlockItem(id: String, isUnlocked: Bool)  {
        var status = getAudioUnlockedStatus()
        status[id] = isUnlocked
        setAudioUnlockedStatus(unlockedStatus: status)
    }
    
    func getAdsAvailable() -> String? {
        return userDefaults.string(forKey: Constants.DataStore.KEY_ADS_AVAILABLE)
    }
    
    
    fileprivate func checkVersion(localVersion : Int, localData : [AudioModel]?, _ completion: @escaping (_ isSuccessful : Bool ,_ isNewVersionAvailable: Bool, _ version: Int) -> Void)  {
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings!
        //remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        remoteConfig.fetch(withExpirationDuration: 0) { (status, error) in
            if status == .success {
                self.remoteConfig.activateFetched()
                //ads
                let adsAvailable = self.remoteConfig[Constants.FireBase.KEY_ADS_AVAILABLE].stringValue!
                self.setAds(adsAvailable: adsAvailable)
                
                //images
                let images = self.remoteConfig[Constants.FireBase.KEY_IMAGES].stringValue
                self.setImages(images: images)
                
                //review version
                let reviewVersion = self.remoteConfig[Constants.FireBase.KEY_REVIEW_VERSION].stringValue!
                self.setReviewVersion(reviewVerion: reviewVersion)
                
                //audio
                let remoteVersion = self.remoteConfig[Constants.FireBase.KEY_AUDIO_VERSION].numberValue as? Int
                if let remoteVersion = remoteVersion {
                    //new audio version available
                    if(localVersion < remoteVersion || localData == nil){
                        completion(true, true, remoteVersion)
                        return
                    }
                }
                completion(true, false, localVersion)
            } else {
                Log.error?.message("Firebase config not fetched, error = \(error!.localizedDescription)")
                
                completion(false, false, localVersion)
            }
        }
    }
    
    fileprivate func setReviewVersion (reviewVerion: String){
        userDefaults.set(reviewVerion, forKey: Constants.DataStore.KEY_REVIEW_VERSION)
    }
    
    fileprivate func isInReview() -> Bool {
        let reviewVersion = userDefaults.string(forKey: Constants.DataStore.KEY_REVIEW_VERSION)
        if let reviewVersion = reviewVersion{
            let arrVersions = reviewVersion.components(separatedBy: ",")
            let localBuildVersion =  "\(Bundle.main.buildVersionNumber!)"
            return arrVersions.index(of: localBuildVersion) != nil
        }
        return false
    }
    
    fileprivate func setAds(adsAvailable: String){
        userDefaults.set(adsAvailable, forKey: Constants.DataStore.KEY_ADS_AVAILABLE)
    }
    
    fileprivate func setImages(images: String?){
        userDefaults.set(images, forKey: Constants.DataStore.KEY_IMAGES)
    }
    
    fileprivate func getImages() -> String?{
        return userDefaults.string(forKey: Constants.DataStore.KEY_IMAGES)
    }
    
    fileprivate func getLocalAudioVersion() -> Int{
        return userDefaults.integer(forKey: Constants.DataStore.KEY_AUDIO_VERSION)
    }
    
    fileprivate func setLocalAudioVersion(version: Int){
        userDefaults.set(version, forKey: Constants.DataStore.KEY_AUDIO_VERSION)
    }
    
    fileprivate func getLocalData() ->[AudioModel]? {
        if originalItems == nil {
            let data =  userDefaults.data(forKey: Constants.DataStore.KEY_AUDIO_DATA)
            if let data = data {
                let decodeData : [AudioModel]? =  NSKeyedUnarchiver.unarchiveObject(with: data) as? [AudioModel]
                originalItems = decodeData
            }
        }
        return originalItems
    }
    
    fileprivate func setLocalData(audioModelList: [AudioModel]){
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: audioModelList)
        userDefaults.set(encodedData, forKey: Constants.DataStore.KEY_AUDIO_DATA)
    }
    
    fileprivate func parseData(objects : [PFObject]) -> [AudioModel]{
        var audioModelList = [AudioModel]()
        var unlockedStatus =  getAudioUnlockedStatus()
        objects.forEach { (object) in
            let audioModel : AudioModel = {
                let model = AudioModel()
                model.id = object.objectId
                model.name = object["name"] as? String
                model.speaker = object["speaker"] as! Int
                model.url = object["audio"] as? String
                model.url = model.url?.replace(target: "www.dropbox.com", withString: "dl.dropboxusercontent.com").replace(target: "dl=0", withString: "dl=1")
                model.image = object["image"] as? String
                model.image = model.image?.replace(target: "www.dropbox.com", withString: "dl.dropboxusercontent.com").replace(target: "dl=0", withString: "dl=1")
                let unlocked = object["unlocked"] as! Bool
                let exist = unlockedStatus.index(forKey: model.id!) != nil
                if exist {
                    let localUnlocked = unlockedStatus[model.id!]
                    if (!localUnlocked!) {
                        unlockedStatus[model.id!] = unlocked
                    }
                }else{
                    unlockedStatus[model.id!] = unlocked
                }
                return model
            }()
            audioModelList.append(audioModel)
        }
        setAudioUnlockedStatus(unlockedStatus: unlockedStatus)
        return audioModelList
    }
    
    fileprivate func addAdsItemsIfNeeded( items : inout [AudioModel]){
        if AdsManager.instance.isAdmobBannerEnable(){
            var includeAdsData : [AudioModel] = []
            if !items.isEmpty{
                includeAdsData.append(items[0])
            }
            let steps = Constants.BuildConfig.DEBUG ? Constants.Application.ADS_STEPS_DEBUG : Constants.Application.ADS_STEPS
            for index in 1 ..< items.count {
                includeAdsData.append(items[index])
                if index % steps == 0 {
                    let adsItem = AudioModel()
                    adsItem.isAdsItem = true
                    includeAdsData.append(adsItem)
                }
            }
            items = includeAdsData
        }
    }
}
