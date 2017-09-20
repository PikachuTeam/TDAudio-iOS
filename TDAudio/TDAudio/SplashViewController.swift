//
//  SplashViewController.swift
//  Audio
//
//  Created by TH on 9/7/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var lblName1: UILabel!
    @IBOutlet weak var lblName2: UILabel!
    @IBOutlet weak var lblName3: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgLoading: UIImageView!
    
    let viewModel = SplashViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        viewModel.viewDelegate = self
        viewModel.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showErrorPopup()  {
        let alert = UIAlertController(title: ":(", message: "Có lỗi xảy ra, vui lòng kiểm tra kết nối mạng và thử lại", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Thử lại", style: UIAlertActionStyle.default, handler: { action in
            self.viewModel.fetchData()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func configView() {
        if !Constants.BuildConfig.DEBUG{
            lblName1.text = "Thiên Địa"
            lblName2.text = "Audio"
            lblName3.text = "16+"
            imgBackground.image = R.image.background()
        }
        imgLoading.rotate360Degrees()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        imgLoading.layer.removeAllAnimations()
    }
    
}

extension SplashViewController : SplashDelegate{
    
    func didFinishFetchingData(){
         performSegue(withIdentifier: "showListAudioScreen", sender: self)
    }
    
    func errorWhileFetchingData(error: Int){
        showErrorPopup()
    }

}
