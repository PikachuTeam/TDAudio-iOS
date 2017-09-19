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

protocol ListAudioDelegate: BaseViewDelegate {
    func itemsDidChange()
    func didSelectItem(item : AudioModel)
    func audioChangeStatePlay()
    func audioChangeStatePause()
    func audioChangeStateNext()
    func audioChangeStatePrevious()
    func askingToUnlockAudio(index: Int, item : AudioModel)
}

protocol ListAudioViewModelInterface : BaseViewModelInterface{
    var itemsCount : Int {get}
    func itemAtIndex(index : Int) -> AudioModel?
    func didSelectItemAtIndex(index: Int)
    func didChangeSpeakerFilter(male: Bool, female: Bool)
    func switchPlayAndPause()
    func next()
    func previous()
    func getCurrentAudioItem() -> AudioModel?
    func isPlayingAudio() -> Bool
    func viewWillDisappear()
    func viewWillAppear()
    func unlockedNewAudio(index: Int)
}

class ListAudioViewModel : ListAudioViewModelInterface{
    typealias ViewDelegate = ListAudioDelegate
    
    weak var viewDelegate: ViewDelegate?{
        didSet{
            self.didChangeSpeakerFilter(male: true, female: true)
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
    
    func itemAtIndex(index: Int) -> AudioModel? {
        if let items = items {
            return items[index]
        }
        return nil
    }
    
    func didSelectItemAtIndex(index: Int) {
        let item = itemAtIndex(index: index)!
        if(item.isUnlocked){
            if getCurrentAudioItem() != item {
                AudioManager.instance.prepare(audioIndex: index)
                AudioManager.instance.play()
            }else {
                if AudioManager.instance.isEndPlaying(){
                    AudioManager.instance.startOver()
                }
                if(!AudioManager.instance.isPlaying()){
                    AudioManager.instance.play()
                }
            }
            viewDelegate?.didSelectItem(item: item)
        }else{
            viewDelegate?.askingToUnlockAudio(index: index, item: item)
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
            case .Play:
                self.viewDelegate?.audioChangeStatePlay()
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
        AudioManager.instance.unregisterAudioEventChange(identifier: "ListAudioViewModel.AudioEvent")
    }
    
    func unlockedNewAudio(index: Int) {
        let item = itemAtIndex(index: index)!
        DataManager.instance.setUnlockItem(id: item.id!, isUnlocked: true)
        didSelectItemAtIndex(index: index)
    }
    
}
