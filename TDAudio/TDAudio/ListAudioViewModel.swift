//
//  MainViewModel.swift
//  Audio
//
//  Created by TH on 9/8/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation
import MediaPlayer
import CleanroomLogger
import MediaPlayer

protocol ListAudioDelegate: BaseViewDelegate {
    func itemsDidChange()
    func didSelectItem(item : AudioModel)
    func audioPreparing()
    func audioChangeStatePlaying()
    func audioChangeStatePause()
    func audioChangeStateNext()
    func audioChangeStatePrevious()
    func askingToUnlockAudio(index: Int, item : AudioModel)
    func audioInteralUpdate(value: Float)
}

protocol ListAudioViewModelInterface : BaseViewModelInterface{
    var itemsCount : Int {get}
    func itemAtIndex(index : Int) -> AudioModel?
    func indexOf(item: AudioModel) -> Int?
    func didSelectItemAtIndex(index: Int)
    func didChangeSpeakerFilter(male: Bool, female: Bool)
    func switchPlayAndPause()
    func next()
    func previous()
    func getCurrentAudioItem() -> AudioModel?
    func isPlayingAudio() -> Bool
    func viewWillDisappear()
    func viewWillAppear()
    func unlockedNewAudio(unlockedItem : AudioModel)
    func getCurrentPlayingTime() -> Float
    func getDurationText() -> String?
    func getDurationNumber() -> Float?
    func getCurrentTimeText() -> String?
    func destroy()
    func seekTo(value : Float)
}

class ListAudioViewModel : ListAudioViewModelInterface{
    typealias ViewDelegate = ListAudioDelegate
    
    weak var viewDelegate: ViewDelegate?{
        didSet{
            self.didChangeSpeakerFilter(male: true, female: true)
            AudioManager.instance.registerAudioInteralUpdate { (time) in
                self.viewDelegate?.audioInteralUpdate(value: Float(time))
            }
        }
    }
    
    fileprivate var items: [AudioModel]? {
        didSet{
            viewDelegate?.itemsDidChange()
        }
    }
    
    var itemsCount: Int{
        if let items = items{
            return items.count
        }
        return 0
    }
    
    func indexOf(item: AudioModel) -> Int?{
        return items?.index(of: item)
    }
    
    func itemAtIndex(index: Int) -> AudioModel? {
        if let items = items {
            return items[index]
        }
        return nil
    }
    
    
    
    func didSelectItemAtIndex(index: Int) {
        let item = itemAtIndex(index: index)!
        if(item.hasUnlocked()){
            if getCurrentAudioItem() != item {
                AudioManager.instance.prepare(audioIndex: index)
                AudioManager.instance.play()
            }else {
                continuePlayingOrStartOver()
            }
            viewDelegate?.didSelectItem(item: item)
        }else{
            AudioManager.instance.pause()
            viewDelegate?.askingToUnlockAudio(index: index, item: item)
        }
    }
    
    func continuePlayingOrStartOver()  {
        if AudioManager.instance.isEndPlaying(){
            AudioManager.instance.startOver()
        }
        if(!AudioManager.instance.isPlaying()){
            AudioManager.instance.play()
        }
    }
    
    func didChangeSpeakerFilter(male: Bool, female: Bool) {
        var filter : SpeakerFilter?
        if(male && female){
            filter = .All
        }else if(male){
            filter = .Male
        }else if(female){
            filter = .Female
        }else{
            filter = .All
        }
        items = DataManager.instance.getData(filter: filter!)
    }
    
    
    func switchPlayAndPause() {
        AudioManager.instance.switchPlayAndPause()
    }
    
    func next(){
        AudioManager.instance.next()
    }
    
    func previous(){
        AudioManager.instance.previous()
    }
    
    func getCurrentAudioItem() -> AudioModel? {
        return AudioManager.instance.getCurrentAudioItem()
    }
    
    func isPlayingAudio() -> Bool{
        return AudioManager.instance.isPlaying()
    }
    
    func viewWillAppear(){
        AudioManager.instance.registerAudioEventChangeListener(identifier: "ListAudioViewModel.AudioEvent") { (audioEvent) in
            switch audioEvent {
            case .Preparing:
                self.viewDelegate?.audioPreparing()
            case .Playing:
                self.viewDelegate?.audioChangeStatePlaying()
            case .Pause:
                self.viewDelegate?.audioChangeStatePause()
            case .Next:
                self.viewDelegate?.audioChangeStateNext()
            case .Previous:
                self.viewDelegate?.audioChangeStatePrevious()
            case .PlayLock:
                self.viewDelegate?.askingToUnlockAudio(index: AudioManager.instance.getAudioIndex(), item: self.getCurrentAudioItem()!)
            }
        }
    }
    
    func viewWillDisappear(){
        
    }
    
    func unlockedNewAudio(unlockedItem : AudioModel){
        Log.info?.message("unlocked audio: \(String(describing: unlockedItem.name))")
        unlockedItem.isUnlocked = true
        DataManager.instance.setUnlockItem(id: unlockedItem.id!, isUnlocked: true)
        didSelectItemAtIndex(index: indexOf(item: unlockedItem)!)
    }
    
    func getCurrentPlayingTime() -> Float{
      return  Float(AudioManager.instance.getCurrentPlayingTime())
    }
    
    func getDurationText() -> String?{
        let duration = AudioManager.instance.getDuration()
        if let duration = duration{
            return duration.durationText
        }
        return nil
    }
    func getDurationNumber() -> Float?{
        let duration = AudioManager.instance.getDuration()
        if let duration = duration{
            return Float(CMTimeGetSeconds(duration))
        }
        return nil
    }
    
    func getCurrentTimeText() -> String?{
        let current = AudioManager.instance.getCurrent()
        if let current = current{
            return current.durationText
        }
        return nil
    }
    
    func destroy() {
        AudioManager.instance.unregisterAudioEventChange(identifier: "ListAudioViewModel.AudioEvent")
        AudioManager.instance.unRegisterAudioInteralUpdate()
    }
    
    func seekTo(value : Float){
        let seconds : Int64 = Int64(value)
        let targetTime : CMTime = CMTimeMake(seconds, 1)
        AudioManager.instance.seekTo(time: targetTime)
    }

}
