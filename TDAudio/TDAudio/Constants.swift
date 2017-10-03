//
//  Constants.swift
//  Audio
//
//  Created by Thanh Nguyen on 9/6/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation
import GoogleMobileAds


typealias Completion = () -> Void
typealias Error = (Int) -> Void

struct Constants {
    
    struct BuildConfig {
        static let DEBUG = true
    }
    
    struct Application {
        static let SPLASH_SCREEN_DURATION_MIN : Double = 2000 //in milisecond
        static let IMAGE_SLIDER_INTERVAL = 15 //in second
        static let ADS_STEPS = 6
        static let ADS_STEPS_DEBUG = 2
        static let OPEN_SLIDE_SHOW = false
        
    }
   
    struct DataStore {
        static let KEY_AUDIO_VERSION = "audio_version"
        static let KEY_AUDIO_DATA = "audio_data"
        static let KEY_IMAGES = "images"
        static let KEY_IMAGE_COUNT = "image_count"
        static let KEY_AUDIO_UNLOCKED_STATUS = "audio_unlocked_status"
        static let KEY_ADS_AVAILABLE = "ads_available"
        static let IMAGES_PREVIEW_DEBUG = ["https://i.pinimg.com/736x/e1/5c/66/e15c662cad4690cfa86b38b9faa1edae--lion-of-judah-the-lion-king.jpg","https://s-media-cache-ak0.pinimg.com/originals/5d/60/74/5d6074ab580cca3d2524ce9fb10e53b1.jpg","http://4.bp.blogspot.com/-NOWfKyRjV_s/UusotZ0tRcI/AAAAAAAAI8k/OKTipZfsOHU/s1600/ec1f120eaa6af63dd5b028622db1c66d.jpg", "https://images.fineartamerica.com/images-medium-large-5/portrait-of-a-lion-lucie-bilodeau.jpg"]
    }
    
    struct FireBase {
        static let KEY_AUDIO_VERSION = "AUDIO_VERSION"
        static let KEY_IMAGES = "IMAGES"
        static let KEY_ADS_AVAILABLE = "ADS_AVAILABLE"
    }
    
    struct Parse {
        static let APP_ID = "mNIJZfRW8XCcWkq18BES661I0Km0pURzWBFQ4iLr"
        static let CLIENT_KEY = "Nl6kf77lJyc7bx6UchhPAiMCPR6dnAbePRK1tepH"
        static let SERVER = "https://parseapi.back4app.com"
        static let TABLE_NAME = "tbl_tdaudio"
        static let TABLE_NAME_DEBUG = "tbl_audio"
    }
    
    struct Ads {
        //google admob
        static let GOOGLE_ADS_REWARD_NAME = "admob_reward"
        static let GOOGLE_ADS_BANNER_NAME = "admob_banner"
            //release
        static let GOOGLE_APP_ID = "ca-app-pub-3786715234447481~1167122263"
        static let GOOGLE_AD_REWARD_UNIT = "ca-app-pub-3786715234447481/9512516143"
        static let GOOGLE_AD_BANNER_UNIT = "ca-app-pub-3786715234447481/1621495367"
        
            //debug
        static let GOOGLE_APP_ID_DEBUG = "ca-app-pub-3940256099942544~1458002511"
        static let GOOGLE_AD_REWARD_UNIT_DEBUG = "ca-app-pub-3940256099942544/1712485313"
        static let GOOGLE_AD_BANNER_UNIT_DEBUG = "ca-app-pub-3940256099942544/6300978111"
        
        static let TEST_DEVICES : [Any] = [kGADSimulatorID, "9ad00eb3ddc4606bd5ddc0855aaf0801", "68028e84cc4d4bec1c7bf802e06e10c7"]
        
        //startapp
        static let STARTAPP_ADS_NAME = "startapp"
        static let STARTAPP_ACCOUNT_ID = "180073597"
        static let STARTAPP_APP_ID = "208237699"
    }
}

enum SpeakerFilter{
    case All
    case Male
    case Female
}

enum AudioEvent{
    case Preparing
    case Playing
    case Pause
    case Next
    case Previous
    case PlayLock
}



