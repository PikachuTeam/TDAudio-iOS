//
//  ImageSliderControler.swift
//  Audio
//
//  Created by TH on 9/12/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation
import UIKit

class ImageSlider{
    static let instance = ImageSlider()
    private weak var imgA : UIImageView? = nil
    private weak var imgB : UIImageView? = nil
    
    
    private var count = 0
    private var timer : Timer? = nil
    
    private init(){}
    
    
    func start(imgA : UIImageView, imgB : UIImageView)  {
        count = DataManager.instance.getImageCount()
        
        self.imgA = imgA
        self.imgB = imgB
        
        nextImage()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(Constants.Application.IMAGE_SLIDER_INTERVAL), target: self, selector: #selector(self.fadeInFadeOut), userInfo: nil, repeats: true)
    }
    
    func stop()  {
        DataManager.instance.setImageCount(count: count)
        timer?.invalidate()
    }
    
    private func nextImage()  {
        if let imgA = imgA{
            if(imgA.alpha==1){
                let url = getNextUlr()
                if let url = url{
                    let placeHolder = Constants.BuildConfig.DEBUG ? nil : R.image.background()
                    self.imgB?.sd_setImage(with: URL(string: url), placeholderImage: placeHolder,  completed: nil)
                }
            }
        }
        
        if let imgB = imgB{
            if(imgB.alpha==1){
                let url = getNextUlr()
                if let url = url{
                    let placeHolder = Constants.BuildConfig.DEBUG ? nil : R.image.background()
                    self.imgA?.sd_setImage(with: URL(string: url), placeholderImage: placeHolder,  completed: nil)
                }
            }
        }
    }
    
    @objc private func fadeInFadeOut()  {
        if self.imgA != nil && self.imgB != nil{
            let completion : (Bool) -> Void = { (result) in
                self.nextImage()
            }
            if self.imgA?.alpha==0{
                self.imgA?.fadeIn()
                self.imgB?.fadeOut(completion: completion)
            }
            else if self.imgB?.alpha == 0{
                self.imgB?.fadeIn()
                self.imgA?.fadeOut(completion: completion)
            }else{
                self.imgA?.fadeIn()
                self.imgB?.fadeOut(completion: completion)
            }
        }
    }
    
    private func getNextUlr() -> String? {
        let images = DataManager.instance.getImageSet()
        if let images = images{
            if(count == images.count-1){
                count = 0
                return (images[images.count-1])
            }
            count += 1
            return (images[count-1])
        }
        return nil
    }
}
