//
//  BaseAudioViewController.swift
//  Audio
//
//  Created by TH on 9/11/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import UIKit
import CleanroomLogger
import GoogleMobileAds

protocol BaseViewControllerInterface  {
    associatedtype ViewModel
    var viewModel : ViewModel? { get set}
}

class BaseAudioViewController  : UIViewController {
    
    fileprivate var lockedAudio : AudioModel?
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
        self.navigationController?.navigationBar.transparentNavigationBar()
        
//        AdsManager.instance.setAdmobAdsDelegate(delegate: self)
//        AdsManager.instance.setStartAppAdsDelegate(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configAdmobAds()
    }

    override  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event{
            if event.type == UIEventType.remoteControl{
                switch event.subtype {
                case .remoteControlPlay:
                    AudioManager.instance.play()
                case .remoteControlPause:
                    AudioManager.instance.pause()
                case .remoteControlNextTrack:
                    AudioManager.instance.next()
                case .remoteControlPreviousTrack:
                    AudioManager.instance.previous()
                default:
                    Log.info?.message("unconfig")
                }
            }
        }
    }
    
    func configAdmobAds()  {
        AdsManager.instance.setAdmobAdsDelegate(delegate: self)
        AdsManager.instance.prepareAdmobAds()
    }
    
    func showAds(lockedAudio: AudioModel)  {
        self.lockedAudio = lockedAudio
        AdsManager.instance.showAds(viewController: self)
    }
    
    open func didUnlockAudio(unlockAudio: AudioModel)  {
        
    }
 
}

extension BaseAudioViewController : GADRewardBasedVideoAdDelegate {
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        Log.info?.message("-------- DidReward, unlocking")
        AdsManager.instance.admobFinishedLoading()
        didUnlockAudio(unlockAudio: self.lockedAudio!)
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        Log.info?.message("Reward based video ad is received.")
        AdsManager.instance.admobFinishedLoading()
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        Log.info?.message("Opened reward based video ad.")
        AdsManager.instance.admobFinishedLoading()
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        Log.info?.message("Reward based video ad started playing.")
        AdsManager.instance.admobFinishedLoading()
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        Log.info?.message("Reward based video ad is closed.")
        AdsManager.instance.admobFinishedLoading()
        AdsManager.instance.prepareAdmobAds()
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        Log.info?.message("Reward based video ad will leave application.")
    }
    
    private func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        Log.info?.message("Reward based video ad failed to load: \(error)")
        AdsManager.instance.admobFinishedLoading()
    }
}


//extension BaseAudioViewController : STADelegateProtocol {
//    
//     func didCompleteVideo(_ ad: STAAbstractAd) {
//        print("StartApp rewarded video had been completed", terminator: "")
//    }
//    
//     @nonobjc func failedLoad(_ ad: STAAbstractAd!, withError error: Error!) {
//         print("StartApp failedLoad")
//    }
//    
//     @nonobjc func failedShow(_ ad: STAAbstractAd!, withError error: Error!) {
//        print("StartApp failedShow")
//    }
//}
