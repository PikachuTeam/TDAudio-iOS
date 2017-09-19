//
//  SplashViewModel.swift
//  Audio
//
//  Created by TH on 9/7/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol SplashDelegate : BaseViewDelegate{
    func didFinishFetchingData()
    func errorWhileFetchingData(error: Int)
}

protocol SplashViewModelInterface : BaseViewModelInterface{
    func fetchData()
}


class SplashViewModel: NSObject, SplashViewModelInterface {
    typealias ViewDelegate = SplashDelegate
    
    var viewDelegate: ViewDelegate?
    
    func fetchData() {
        let start = Date().millisecondsSince1970
        DataManager.instance.fetchData(error: {
            (err) in
            self.viewDelegate?.errorWhileFetchingData(error: err)
        }) { //completed downloading data
            let finish = Date().millisecondsSince1970
            let duration = finish - start
            
            if (duration >= Constants.Application.SPLASH_SCREEN_DURATION_MIN){
                self.finishedFetchingData()
            }else{
                self.perform(#selector(self.finishedFetchingData), with: nil, afterDelay: TimeInterval((Constants.Application.SPLASH_SCREEN_DURATION_MIN - duration) / 1000))
            }
        }
    }
    
    @objc func finishedFetchingData()  {
        self.viewDelegate?.didFinishFetchingData()
        AdsManager.instance.configAds()
    }
    


}
