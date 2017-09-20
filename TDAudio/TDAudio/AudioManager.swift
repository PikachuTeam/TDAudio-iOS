//
//  AudioManager.swift
//  Audio
//
//  Created by Thanh Nguyen on 9/10/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation
import CleanroomLogger
import AVFoundation
import MediaPlayer

class AudioManager :NSObject{
    
    static let instance = AudioManager()
    private var player: AVPlayer? = nil
    private var playerItem : AVPlayerItem? = nil
    private var observer : Any? = nil
    private var periodicTimeHandler: ((Double) -> Void)?
    private var audioIndex : Int? = nil
    private var currentAudioItem : AudioModel? = nil
    private var isStartPlaying = false
    
    private var audioEvent = DynamicType<AudioEvent>()
    typealias AudioEventListener =  (AudioEvent) -> Void
    
    private override init(){
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            Log.error?.message("error: \(error.localizedDescription)")
        }
    }
    
    func prepare(audioIndex: Int)  {
        self.audioIndex = audioIndex
        self.currentAudioItem = getAudioItem()
        
        isStartPlaying = false
        unRegisterAudioInteralUpdate(removeHandler: false)
        
        if observer != nil {
            player?.removeTimeObserver(observer!)
            observer = nil
        }
        
        playerItem = AVPlayerItem(url: URL(string: (currentAudioItem!.url)!)!)
        player =  AVPlayer(playerItem: playerItem)
        
        registerAudioInteralUpdate(periodicTimeHandler: periodicTimeHandler)
        
        //detect when audio ends playing
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle : (currentAudioItem!.name)!,
            MPMediaItemPropertyArtist : "TĐ Audio",
            MPMediaItemPropertyPlaybackDuration: Float(CMTimeGetSeconds(playerItem!.duration)),
            MPNowPlayingInfoPropertyPlaybackRate: "1.0"
        ]
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        
        Log.info?.message("prepare playing \(String(describing: currentAudioItem?.name))")
        
        
        observer =  player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main, using: {_ in
            if !self.isStartPlaying && self.player!.currentTime().seconds > 0{
                self.isStartPlaying = true
                self.audioEvent.value = AudioEvent.Playing
            }
            if let handler = self.periodicTimeHandler {
                handler(self.player!.currentTime().seconds)
            }
        })
    }
    
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        Log.info?.message("audio ends playing")
    }
    
    func play() {
        if let player = player{
            if(currentAudioItem?.isUnlocked)! {
                player.play()
                if !isStartPlaying{
                    Log.info?.message("preparing \(String(describing: currentAudioItem?.name))")
                    audioEvent.value = AudioEvent.Preparing
                }else{
                    Log.info?.message("start playing \(String(describing: currentAudioItem?.name))")
                    audioEvent.value = AudioEvent.Playing
                }
            }else{
                Log.error?.message("Item is locked")
                 audioEvent.value = AudioEvent.PlayLock
            }
        }
    }
    
    private func getAudioItem() -> AudioModel?{
        return DataManager.instance.getItem(atIndex: audioIndex)
    }
    
    
    func reloadAudioIndex()  {
        if let currentAudioItem = currentAudioItem{
            audioIndex = DataManager.instance.getAudioIndex(item: currentAudioItem)
        }
    }
    
    func getCurrentAudioItem() -> AudioModel? {
        return currentAudioItem
    }
    
    func getAudioIndex() -> Int {
        return audioIndex!
    }
    
    func next()  {
        if audioIndex != nil{
            audioIndex! += 1
            prepare(audioIndex: audioIndex!)
            play()
            audioEvent.value = AudioEvent.Next
        }
    }
    
    func previous() {
        if audioIndex != nil{
            audioIndex! -= 1
            prepare(audioIndex: audioIndex!)
            play()
            audioEvent.value = AudioEvent.Previous
        }
    }
    
    func pause()  {
        if let player = player{
            player.pause()
            audioEvent.value = AudioEvent.Pause
        }
    }
    
    func switchPlayAndPause()  {
        if player != nil{
            if isPlaying(){
                pause()
            }else{
                play()
            }
        }
    }
    
    func isPlaying() -> Bool {
        if let player = player {
            return player.rate != 0 && player.error == nil
        }
        return false
    }
    
    func seekTo(time : CMTime)  {
        if let player = player {
            player.seek(to: time)
            if !isPlaying(){
                play()
            }
        }
    }
    
    func startOver()  {
        let seconds : Int64 = Int64(0)
        let targetTime : CMTime = CMTimeMake(seconds, 1)
        seekTo(time: targetTime)
    }
    
    func getDuration() -> CMTime? {
        if let player = player{
            return player.currentItem?.duration
        }
        return nil
    }
    
    func getCurrent() -> CMTime? {
        if let player = player{
            return player.currentItem?.currentTime()
        }
        return nil
    }
    
    func getAudioName() -> String? {
        if let item = currentAudioItem {
            return item.name
        }
        return nil
    }
    
    func getCurrentPlayingTime() -> Double {
        if let player = player{
            return player.currentTime().seconds
        }
        return 0
    }
    
    func registerAudioInteralUpdate(periodicTimeHandler: ((Double) -> Void)?)  {
        if(periodicTimeHandler != nil){
            self.periodicTimeHandler = periodicTimeHandler
       
        }
    }
    
    func unRegisterAudioInteralUpdate(removeHandler : Bool = true) {
        if periodicTimeHandler != nil{
            periodicTimeHandler!(0)
        }
        
        if(removeHandler){
            periodicTimeHandler = nil
        }
    }
    
    func registerAudioEventChangeListener(identifier: String, handle: @escaping AudioEventListener)  {
        audioEvent.bind(identifier: identifier, listener: handle)
    }
    
    func unregisterAudioEventChange(identifier: String) {
        audioEvent.unBind(identifier: identifier)
    }
    
    
    func isEndPlaying() -> Bool {
        var duration = Float(0)
        if (player?.currentItem) != nil {
            duration = Float(CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!))
        }
        return Float((self.player?.currentTime().seconds)!) == duration
    }
}
