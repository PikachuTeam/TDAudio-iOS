//
//  AudioPlayerViewModel.swift
//  Audio
//
//  Created by Thanh Nguyen on 9/10/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation
import UIKit
import CleanroomLogger
import MediaPlayer

protocol AudioPlayerDelegate : BaseViewDelegate{
    func audioInteralUpdate(value: Float)
    func audioPreparing()
    func audioChangeStatePlaying()
    func audioChangeStatePause()
    func askingToUnlockAudio(item: AudioModel)
    func audioChanged(item: AudioModel)
}

protocol AudioPlayerInterface : BaseViewModelInterface{
    func switchPlayAndPause()
    func seekTo(value : Float)
    func next()
    func previous()
    func getDurationText() -> String?
    func getDurationNumber() -> Float?
    func getCurrentTimeText() -> String?
    func viewWillDisappear()
    func viewWillAppear()
    func viewDidDisappear()
    func audioUnlocked(item: AudioModel)
    func getCurrentPlayingTime() -> Float
   
}

class AudioPlayerViewModel : AudioPlayerInterface{
    typealias ViewDelegate = AudioPlayerDelegate
    
    weak var viewDelegate: ViewDelegate?{
        didSet{
            AudioManager.instance.registerAudioInteralUpdate { (time) in
                self.viewDelegate?.audioInteralUpdate(value: Float(time))
            }
            self.viewDelegate?.audioChanged(item: AudioManager.instance.getCurrentAudioItem()!)
        }
    }
    
    func switchPlayAndPause() {
        AudioManager.instance.switchPlayAndPause()
    }
    
    func seekTo(value : Float) {
        let seconds : Int64 = Int64(value)
        let targetTime : CMTime = CMTimeMake(seconds, 1)
        AudioManager.instance.seekTo(time: targetTime)
    }
    
    func next(){
        AudioManager.instance.next()
    }
    
    func previous(){
        AudioManager.instance.previous()
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

    
    func viewWillDisappear(){
      
    }
    
    func viewWillAppear(){
        AudioManager.instance.registerAudioEventChangeListener(identifier: "AudioPlayerViewModel.AudioEvent") { (audioEvent) in
            switch audioEvent {
            case .Preparing:
                self.viewDelegate?.audioPreparing()
            case .Playing:
                self.viewDelegate?.audioChangeStatePlaying()
            case .Pause:
                self.viewDelegate?.audioChangeStatePause()
            case .PlayLock:
                self.viewDelegate?.askingToUnlockAudio(item: AudioManager.instance.getCurrentAudioItem()!)
            case .Next:
                self.viewDelegate?.audioChanged(item: AudioManager.instance.getCurrentAudioItem()!)
            case.Previous:
                self.viewDelegate?.audioChanged(item: AudioManager.instance.getCurrentAudioItem()!)
            }
        }
    }
    
    func viewDidDisappear() {
        AudioManager.instance.unRegisterAudioInteralUpdate()
        AudioManager.instance.unregisterAudioEventChange(identifier: "AudioPlayerViewModel.AudioEvent")
    }
    
    func audioUnlocked(item: AudioModel) {
        Log.info?.message("unlocked audio: \(String(describing: item.name))")
        item.isUnlocked = true
        DataManager.instance.setUnlockItem(id: item.id!, isUnlocked: true)
        AudioManager.instance.play()
    }
    
    func getCurrentPlayingTime() -> Float{
        return Float(AudioManager.instance.getCurrentPlayingTime())
    }
}


