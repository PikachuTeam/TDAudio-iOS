//
//  AdsManager.swift
//  Audio
//
//  Created by TH on 9/19/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation
import GoogleMobileAds
import CleanroomLogger

class AdsManager {
    static let instance = AdsManager()
    private var adsAvailable : [String] = []
    private var count = 0
    private var isAdmobRewardAvailable :Bool? = nil
    private var isAdmobBannerAvailable :Bool? = nil
    
    private var isAdmobAdsLoading = false
    
    private init(){
    }
    
    func configAds() {
        if(isAdmobRewardEnable()){
            GADMobileAds.configure(withApplicationID: Constants.BuildConfig.DEBUG ? Constants.Ads.GOOGLE_APP_ID_DEBUG : Constants.Ads.GOOGLE_APP_ID)
        }
    }
    
    func showAdsReward(viewController: UIViewController) {
        if(isAdmobRewardEnable()){
            if GADRewardBasedVideoAd.sharedInstance().isReady {
                Log.warning?.message("++++ Showing admob")
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: viewController)
            }else{
                Log.error?.message("Admob ads is not ready")
                prepareAdmobAds()
            }
        }
    }
    
    func showBannerAds(adsBanner: GADBannerView, viewController : UIViewController)  {
        adsBanner.adUnitID = Constants.BuildConfig.DEBUG ? Constants.Ads.GOOGLE_AD_BANNER_UNIT_DEBUG : Constants.Ads.GOOGLE_AD_BANNER_UNIT
        adsBanner.rootViewController = viewController
        let request = GADRequest()
        request.testDevices = Constants.Ads.TEST_DEVICES
        adsBanner.load(request)
    }
    
    func setAdmobAdsDelegate(delegate: GADRewardBasedVideoAdDelegate)  {
        GADRewardBasedVideoAd.sharedInstance().delegate = delegate
    }
    

    func admobFinishedLoading()  {
        isAdmobAdsLoading = false
    }

    
    func prepareAdmobAds()  {
        if isAdmobRewardEnable(){
            if !GADRewardBasedVideoAd.sharedInstance().isReady && !isAdmobAdsLoading{
                //Add test devices
                let request = GADRequest()
                request.testDevices = Constants.Ads.TEST_DEVICES
                let adUnit = Constants.BuildConfig.DEBUG ? Constants.Ads.GOOGLE_AD_REWARD_UNIT_DEBUG : Constants.Ads.GOOGLE_AD_REWARD_UNIT
                GADRewardBasedVideoAd.sharedInstance().load(request, withAdUnitID: adUnit)
                isAdmobAdsLoading = true
                Log.warning?.message("Preparing Admob")
            }else{
                Log.warning?.message("Admob is ready or still loading, no need to reload")
            }
        }
    }
    
    fileprivate func getAdsAvailable() -> [String] {
        if adsAvailable.isEmpty{
            let local = DataManager.instance.getAdsAvailable()
            if let local = local{
                adsAvailable = local.components(separatedBy: ",")
            }
        }
        return adsAvailable
    }
    
     func isAdmobRewardEnable() -> Bool {
        if isAdmobRewardAvailable == nil{
            isAdmobRewardAvailable = getAdsAvailable().index(of: Constants.Ads.GOOGLE_ADS_REWARD_NAME) != nil
        }
        return isAdmobRewardAvailable!
    }
    
     func isAdmobBannerEnable() ->Bool{
        if isAdmobBannerAvailable == nil{
            isAdmobBannerAvailable = getAdsAvailable().index(of: Constants.Ads.GOOGLE_ADS_BANNER_NAME) != nil
        }
        return isAdmobBannerAvailable!
    }
    
}

