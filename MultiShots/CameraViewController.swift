//
//  CameraViewController.swift
//  MultiShots
//
//  Created by Attawat on 11/11/16.
//  Copyright © 2016 Attawat. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class CameraViewController: UIViewController, XMCCameraDelegate {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var cameraStill: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    
    var preview: AVCaptureVideoPreviewLayer?
    var camera: XMCCamera?
    var timer: Timer!
    var waitTimer: Timer!
    var responseTimer: Timer!
    var countUpdated: Int!
    var roundUpdated: Int!
    let countDownTime = Int(ApiClient.getSettings().shots_countdown_time!)!
    let roundTime = Int(ApiClient.getSettings().number_of_shots!)!
    let idleTime = Int(ApiClient.getSettings().idle_time!)!
    let expectedImageWidth = Double(ApiClient.getSettings().expected_user_image_width_px!)!
    let cameraBg = ApiClient.getSettings().camera_page_bg_decoding()
    let finalImageBg = ApiClient.getSettings().final_image_page_bg_decoding()
    var storeImages: [UIImage] = []
    var isShots: Bool = false
    var userImages: [UserImageModel] = []
    var cardId: String?
    var requestFinalImage: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusButtonStart()

        self.countUpdated = self.countDownTime
        self.roundUpdated = 0
        
        self.bgImageView.image = self.cameraBg
        
        self.waitTimer = Timer.scheduledTimer(timeInterval: Double(idleTime), target: self, selector: #selector(self.updateWaitTimer), userInfo: nil, repeats: false)

        self.initializeCamera()
        self.establishVideoPreviewArea()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.preview?.frame = self.cameraPreview.bounds
        self.cameraPreview.layer.addSublayer(self.preview!)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateWaitTimer() {

        if self.isShots == false {
            self.waitTimer.invalidate()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateTimer() {
        
        
        self.countLabel.text = (self.countUpdated == 0) ? "" : "\(self.countUpdated!)"
        
        if self.countUpdated == 0 {
            self.countUpdated = self.countDownTime + 1
            UIView.animate(withDuration: 5.0, animations: {
                self.cameraStill.alpha = 0.0;
            }, completion: { (finished:Bool) in
        
            self.camera?.captureStillImage({ (image) -> Void in
                if image != nil {
                    
                    let metaRect : CGRect = (self.preview?.metadataOutputRectOfInterest(for: self.cameraPreview!.bounds))!
                    
                    let originalSize = CGSize(width: (image?.size.height)!, height: (image?.size.width)!)
                    
                    let cropRect : CGRect = CGRect( x: metaRect.origin.x * originalSize.width,
                                                    y: metaRect.origin.y * originalSize.height,
                                                    width: metaRect.size.width * originalSize.width,
                                                    height: metaRect.size.height * originalSize.height).integral
                    
                    let finalImage : UIImage =
                        UIImage(cgImage: image!.cgImage!.cropping(to: cropRect)!,
                                scale:1, 
                                orientation: image!.imageOrientation )
                    
                    self.cameraStill.image = finalImage;
                    
                    UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
                    
                    self.storeImages.append(finalImage)
                
                    UIView.animate(withDuration: 0.225, animations: { () -> Void in
                        self.cameraStill.alpha = 1.0;
                        self.cameraPreview.alpha = 0.0;
                        
                    })
                    
                    self.roundUpdated = self.roundUpdated + 1
                    
                    if self.roundUpdated == self.roundTime {
                        self.timer.invalidate()
                        self.timer = nil
                        
                        for index in 1...self.storeImages.count {
                            
                            let newImage = self.imageWithImage(sourceImage: self.storeImages[index - 1], scaledToWidth: CGFloat(self.expectedImageWidth))
                            
                            let plainData: Data = UIImageJPEGRepresentation(newImage, 1.0)!
                            let base64String = plainData.base64EncodedString()
                            
                            self.userImages.append(UserImageModel(sequence: index, image: base64String)!)

                            let imageSize = plainData.count
                            print("size of image in KB: ", Double(imageSize) / 1024.0)
                        }
                        
                        self.uploadImages(userImages: self.userImages)

                    }
                
                } else {
                
                }
            
            
            })
                
            })
            } else {
                UIView.animate(withDuration: 0.225, animations: { () -> Void in
                    self.cameraStill.alpha = 0.0;
                    self.cameraPreview.alpha = 1.0;
                })
            }
        
        self.countUpdated = self.countUpdated - 1
 
    }

    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func uploadImages(userImages:[UserImageModel]) {
        
        self.responseTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.updateResponseTimer), userInfo: nil, repeats: false)
        
        self.requestFinalImage = ApiClient.getFinalImage(userImages: userImages) { responseObject, error in
            print("responseObject = \(responseObject); error =\(error)")
            
            if (error == nil) {
                
                self.responseTimer.invalidate()
                self.responseTimer = nil
                
                self.bgImageView.image = self.finalImageBg
                
                self.cameraStill.image = responseObject?.card_image_decoding()
                
                CustomPhotoAlbum.sharedInstance.saveImage(image: self.cameraStill.image!)
                
                self.cardId = responseObject?.card_id
                
                self.cameraStill.alpha = 1.0
                self.cameraPreview.alpha = 0.0

                self.setStatusButtonComplete()
                
            } else {
                

            }
            
            return
        }
        
    }
    
    func updateResponseTimer() {
        self.requestFinalImage?.cancel()
        self.retakeAction(Any.self)
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let showImagesVC : ShowImagesViewController = storyboard.instantiateViewController(withIdentifier: "showImages") as! ShowImagesViewController
        let navVC = UINavigationController(rootViewController: showImagesVC)
        showImagesVC.storeImages = self.storeImages
        self.present(navVC, animated: true, completion: nil)
    }
    
    func initializeCamera() {
        self.camera = XMCCamera(sender: self)
    }
    
    func establishVideoPreviewArea() {
        self.preview = AVCaptureVideoPreviewLayer(session: self.camera?.session)
        self.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    @IBAction func retakeAction(_ sender: Any) {
        setStatusButtonStart();
        
        self.cameraPreview.alpha = 1.0
        self.cameraStill.alpha = 0.0
        
        self.countLabel.text = ""
    }
    
    @IBAction func shotsAction(_ sender: Any) {
        
        if self.shotButton.imageView?.image != UIImage(named: "cancel") {
        
            self.storeImages.removeAll()
            self.userImages.removeAll()
            self.countUpdated = self.countDownTime - 1
            self.roundUpdated = 0
            self.cameraPreview.alpha = 1.0
            self.cameraStill.alpha = 0.0
            self.isShots = true
            self.waitTimer.invalidate()

            self.setStatusButtonWorking()
            
            self.countLabel.text = "\(self.countDownTime)"
        
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            }
        } else {
            setStatusButtonStart();
            
            self.countLabel.text = ""
            
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.camera?.stopCamera()
        self.waitTimer.invalidate()
        if self.timer != nil {
            self.timer.invalidate()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        
        ApiClient.confirmImage(cardId: self.cardId!) { responseObject, error in
            print("responseObject = \(responseObject); error =\(error)")
            
            self.camera?.stopCamera()
            self.waitTimer.invalidate()
            if self.timer != nil {
                self.timer.invalidate()
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func setStatusButtonStart() {
        self.retakeButton.isHidden = true
        self.confirmButton.isHidden = true
        self.closeButton.isHidden = false
        self.shotButton.isHidden = false
        
        self.shotButton.setImage(UIImage(named: "shot"), for: .normal)
    }
    
    func setStatusButtonWorking() {
        self.shotButton.isHidden = false
        self.retakeButton.isHidden = true
        self.confirmButton.isHidden = true
        self.closeButton.isHidden = false
        
        self.shotButton.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    func setStatusButtonComplete() {
        self.confirmButton.isHidden = false
        self.closeButton.isHidden = true
        self.retakeButton.isHidden = false
        self.shotButton.isHidden = true
    }
    
    
    // MARK: Camera Delegate
    
    func cameraSessionConfigurationDidComplete() {
        self.camera?.startCamera()
    }
    
    func cameraSessionDidBegin() {
        UIView.animate(withDuration: 0.225, animations: { () -> Void in
            self.cameraPreview.alpha = 1.0
        })
    }
    
    func cameraSessionDidStop() {
        UIView.animate(withDuration: 0.225, animations: { () -> Void in
            self.cameraPreview.alpha = 0.0
        })
    }


}
