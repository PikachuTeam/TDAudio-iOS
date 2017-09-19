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
    override  func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
        self.navigationController?.navigationBar.transparentNavigationBar()
        
        AdsManager.instance.setAdmobAdsDelegate(delegate: self)
        AdsManager.instance.prepareAdmobAds()
        
//        AdsManager.instance.setStartAppAdsDelegate(delegate: self)
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
    
    func showAds()  {
        AdsManager.instance.showAds(viewController: self)
    }
 
}

extension BaseAudioViewController : GADRewardBasedVideoAdDelegate {
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        Log.warning?.message("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        Log.warning?.message("Reward based video ad is received.") //2
        AdsManager.instance.admobFinishedLoading()
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        Log.warning?.message("Opened reward based video ad.") //1
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        Log.warning?.message("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        Log.warning?.message("Reward based video ad is closed.")
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        Log.warning?.message("Reward based video ad will leave application.")
    }
    
    private func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        Log.warning?.message("Reward based video ad failed to load: \(error)")
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
