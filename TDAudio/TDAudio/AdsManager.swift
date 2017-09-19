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
//    private var startAppRewarded: STAStartAppAd?
//    private var startAppDelegate : STADelegateProtocol?
    private var isAdmobAdsLoading = false
    
    private init(){
    }
    
    func configAds() {
        if(isAdmobAdsEnable()){
            GADMobileAds.configure(withApplicationID: Constants.BuildConfig.DEBUG ? Constants.Ads.GOOGLE_APP_ID_DEBUG : Constants.Ads.GOOGLE_APP_ID)
            //Add test devices
            let request = GADRequest()
            request.testDevices = Constants.Ads.TEST_DEVICES
        }
//        if(isStartAppAdsEnable()){
//            let sdk: STAStartAppSDK = STAStartAppSDK.sharedInstance()
//            sdk.appID = Constants.Ads.STARTAPP_APP_ID
//            sdk.accountID = Constants.Ads.STARTAPP_ACCOUNT_ID
//            
//            startAppRewarded = STAStartAppAd()
//            prepareStartAppAds()
//        }
    }
    
    func showAds(viewController: UIViewController) {
        if(isAdmobAdsEnable() && isStartAppAdsEnable()){
            if (count % 2 == 0) {
                showAdmobAds(viewController: viewController)
            } else {
//                showStartAppAds()
            }
            count += 1
        }
        else if(isAdmobAdsEnable()){
            showAdmobAds(viewController: viewController)
        }else if (isStartAppAdsEnable()){
//            showStartAppAds()
        }
    }
    
    func setAdmobAdsDelegate(delegate: GADRewardBasedVideoAdDelegate)  {
        GADRewardBasedVideoAd.sharedInstance().delegate = delegate
    }
    
//    func setStartAppAdsDelegate(delegate: STADelegateProtocol)  {
//        startAppDelegate = delegate
//    }
    
    func admobFinishedLoading()  {
        isAdmobAdsLoading = false
    }
    
    fileprivate func showAdmobAds(viewController: UIViewController){
        if GADRewardBasedVideoAd.sharedInstance().isReady {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: viewController)
        }else{
            Log.error?.message("Admob ads is not ready")
        }
        prepareAdmobAds()
    }
    
    func prepareAdmobAds()  {
        if isAdmobAdsEnable(){
            if !GADRewardBasedVideoAd.sharedInstance().isReady && !isAdmobAdsLoading{
                GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: Constants.BuildConfig.DEBUG ? Constants.Ads.GOOGLE_AD_UNIT_DEBUG : Constants.Ads.GOOGLE_AD_UNIT)
                isAdmobAdsLoading = true
                Log.warning?.message("Admob is loading")
            }else{
                Log.warning?.message("Admob is ready or still loading, no need to reload")
            }
        }
    }
    
//    fileprivate func showStartAppAds(){
//        if startAppRewarded!.isReady() {
//            startAppRewarded?.show()
//        }
//        else{
//            Log.error?.message("StartApp ads is not ready")
//        }
//        prepareStartAppAds()
//    }
//    
//    fileprivate func prepareStartAppAds()  {
//        startAppRewarded?.loadRewardedVideoAd(withDelegate: startAppDelegate)
//    }
    
    fileprivate func getAdsAvailable() -> [String] {
        if adsAvailable.isEmpty{
            let local = DataManager.instance.getAdsAvailable()
            if let local = local{
                adsAvailable = local.components(separatedBy: ",")
            }
        }
        return adsAvailable
    }
    
    fileprivate func isAdmobAdsEnable() -> Bool {
        return getAdsAvailable().index(of: Constants.Ads.GOOGLE_ADS_NAME) != nil
    }
    
    fileprivate func isStartAppAdsEnable() -> Bool {
        return getAdsAvailable().index(of: Constants.Ads.STARTAPP_ADS_NAME) != nil
    }
}

