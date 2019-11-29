//
//  ViewController.swift
//  MultiShots
//
//  Created by Attawat on 11/11/16.
//  Copyright © 2016 Attawat. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class ViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var settings: SettingModel?
    var urlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if ApiClient.defaults.string(forKey: "url_api") == nil {
            ApiClient.defaults.set("https://touchpoint.houseofdev.tech/multi_shots_on_ios_server/pages/ios_api.php", forKey: "url_api")
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(self.viewTapped))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.loadInitialSetting()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func chooseOrientation() {
        let alert = UIAlertController(title: "Choose Type", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Square", style: .default, handler: { (UIAlertAction) in
            OrientationSingleton.sharedInstance.isPortrait = true
            OrientationSingleton.sharedInstance.isSquare = true
        }))
        
        alert.addAction(UIAlertAction(title: "Portrait", style: .default, handler: { (UIAlertAction) in
            OrientationSingleton.sharedInstance.isPortrait = true
            OrientationSingleton.sharedInstance.isSquare = false
        }))
        
        alert.addAction(UIAlertAction(title: "Landscape", style: .default, handler: { (UIAlertAction) in
            OrientationSingleton.sharedInstance.isPortrait = false
            OrientationSingleton.sharedInstance.isSquare = false
        }))
    
        if let popoverController = alert.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func viewTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if OrientationSingleton.sharedInstance.isSquare {
            let controller = storyboard.instantiateViewController(withIdentifier: "cameraSquareVC") as! CameraSquareViewController
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        } else {
            let controller = storyboard.instantiateViewController(withIdentifier: "cameraVC") as! CameraViewController
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func urlApiAction(_ sender: Any) {
        let alert = UIAlertController(title: "API URL", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
            self.chooseOrientation()
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler:{ (UIAlertAction) in
            ApiClient.defaults.set(self.urlTextField.text, forKey: "url_api")
            self.loadInitialSetting()
            self.chooseOrientation()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func configurationTextField(textField: UITextField!) {

        let apiUrl:String = ApiClient.defaults.string(forKey: "url_api")!
        
        textField.text = apiUrl
        self.urlTextField = textField

    }

    func loadInitialSetting() {
        
        ApiClient.getInitialSetting() { responseObject, error in
            print("responseObject = \(responseObject); error =\(error)")
            
            if (responseObject != nil) {
                
                self.bgImageView.image = responseObject?.home_bg_decoding()
                self.logoImageView.image = responseObject?.logo_decoding()

            } else {
                
                let settings = ApiClient.getSettings()
                
                self.bgImageView.image = settings.home_bg_decoding()
                self.logoImageView.image = settings.logo_decoding()
            }
            
            return
        }
        
    }

}

