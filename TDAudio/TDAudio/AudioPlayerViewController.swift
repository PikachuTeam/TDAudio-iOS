//
//  AudioPlayerViewController.swift
//  Audio
//
//  Created by Thanh Nguyen on 9/10/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import UIKit

class AudioPlayerViewController: BaseAudioViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imgA: UIImageView!
    @IBOutlet weak var imgB: UIImageView!
    
    @IBOutlet weak var labelDuration: UILabel!
    @IBOutlet weak var labelCurrent: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgLoading: UIImageView!
    
    
    let viewModel = AudioPlayerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        configSlider()
        imgLoading.rotate360Degrees()
        viewModel.viewDelegate = self
        
        ImageSlider.instance.start(imgA: imgA, imgB: imgB)
        
        setPlayingState(isPlaying: viewModel.getCurrentPlayingTime() > 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    
    func configSlider()  {
        slider.maximumValue = 0//Float(viewModel.getDuration())
        slider.minimumValue = 0
    }
    
    @IBAction func switchPlayAndPause(_ sender: Any) {
        viewModel.switchPlayAndPause()
    }
    
    @IBAction func seekTo(_ sender: UISlider) {
        viewModel.seekTo(value: sender.value)
    }
    
    @IBAction func next(_ sender: Any) {
        viewModel.next()
    }
    
    @IBAction func previous(_ sender: Any) {
        viewModel.previous()
    }
    
    func showUnlockAudioPopup(item: AudioModel)  {
        let alert = UIAlertController(title: "Mở khoá", message: "Xem quảng cáo để mở khoá audio này", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Huỷ", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Đồng ý", style: UIAlertActionStyle.default, handler: { action in

            super.showAds(lockedAudio: item)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didUnlockAudio(unlockAudio: AudioModel) {
        self.viewModel.audioUnlocked(item: unlockAudio)
    }
    
    func setPlayingState(isPlaying: Bool)  {
        if !isPlaying{
            imgLoading.rotate360Degrees()
            imgLoading.isHidden = false
            btnPlay.isHidden = true
        }else{
            labelDuration.text = viewModel.getDurationText()
            slider.value = viewModel.getCurrentPlayingTime()
            slider.maximumValue = viewModel.getDurationNumber()!
            
            imgLoading.layer.removeAllAnimations()
            imgLoading.isHidden = true
            btnPlay.isHidden = false
            btnPlay.setImage(R.image.pause(), for: .normal)
        }
    }
    
    deinit {
        viewModel.viewDidDisappear()
        ImageSlider.instance.stop()
    }
}

extension AudioPlayerViewController : AudioPlayerDelegate {
 
    func audioInteralUpdate(value: Float) {
        slider.isUserInteractionEnabled = true
        self.slider.value = value
        if value != 0 {
            if slider.maximumValue == 0 {
                slider.maximumValue = viewModel.getDurationNumber()!
            }
            if labelDuration.text == "00:00"{
                labelDuration.text = viewModel.getDurationText()
            }
            labelCurrent.text = viewModel.getCurrentTimeText()
        }else{
            slider.isUserInteractionEnabled = false
            labelDuration.text = "00:00"
            labelCurrent.text = "00:00"
        }
    }
    
    func audioPreparing() {
        setPlayingState(isPlaying: false)
    }
    
    func audioChangeStatePlaying(){
        setPlayingState(isPlaying: true)
    }
    
    func audioChangeStatePause(){
        btnPlay.setImage(R.image.play(), for: .normal)
    }
    
    func askingToUnlockAudio(item: AudioModel) {
        showUnlockAudioPopup(item: item)
    }
    
    func audioChanged(item: AudioModel){
        self.navigationItem.title = item.name
    }

}




