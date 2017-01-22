//
//  ApiClient.swift
//  MultiShots
//
//  Created by Attawat on 11/14/16.
//  Copyright © 2016 Attawat. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import SwiftyJSON

class ApiClient: NSObject {
    
    static let defaults = UserDefaults.standard
    static let udid = UIDevice.current.identifierForVendor!.uuidString
    
    static func getInitialSetting(completionHanler: @escaping (SettingModel?, Error?) -> ())  {
        
        let apiUrl:String = defaults.string(forKey: "url_api")!
        
        let request = "{ \"requester_id\" : \"\(self.udid)\", \"request_type\" : \"app_initial_setting\" }"
        
        let params = ["request_command": request]
        
        Alamofire.request(apiUrl, method: .post, parameters: params)
            .responseObject { (response: DataResponse<SettingModel>) in
                
                switch response.result {
                case .success(let value):
                    self.saveSettings(setting: value)
                    completionHanler(value, nil)
                case .failure(let error):
                    completionHanler(nil, error)
                    
                }
        }
    }
    
    static func getFinalImage(userImages:[UserImageModel], completionHanler: @escaping (CardImageModel?, Error?) -> ()) -> Request  {
        
        let apiUrl:String = defaults.string(forKey: "url_api")!
        
        var obj:[[String:Any]] = []
        
        for img in userImages {
            obj.append(["sequence": img.sequence! ,"image": img.image!])
        }
     
        let json = JSON(obj)

        let request = "{ \"requester_id\" : \"\(self.udid)\", \"request_type\" : \"card_generate\", \"user_images\" : \(json) }"
        
        let params = ["request_command": request]
        
        return Alamofire.request(apiUrl, method: .post, parameters: params)
            .responseObject { (response: DataResponse<CardImageModel>) in
                
                switch response.result {
                case .success(let value):
                    completionHanler(value, nil)
                case .failure(let error):
                    completionHanler(nil, error)
                    
                }
        }
    }
    
    static func confirmImage(cardId:String, completionHanler: @escaping (String?, Error?) -> ())  {
        
        let apiUrl:String = defaults.string(forKey: "url_api")!
        
        let request = "{ \"requester_id\" : \"\(self.udid)\", \"request_type\" : \"card_confirmation\", \"card_id\" : \"\(cardId)\", \"confirm_type\" : \"1\" }"
        
        let params = ["request_command": request]
        
        Alamofire.request(apiUrl, method: .post, parameters: params)
            .responseString { (response: DataResponse<String>) in
                
                switch response.result {
                case .success(let value):
                    completionHanler(value, nil)
                case .failure(let error):
                    completionHanler(nil, error)
                    
                }
        }
    }
    
    static func saveSettings(setting:SettingModel) {
        defaults.set(setting.home_bg, forKey: "home_bg")
        defaults.set(setting.logo, forKey: "logo")
        defaults.set(setting.number_of_shots, forKey: "number_of_shots")
        defaults.set(setting.shots_countdown_time, forKey: "shots_countdown_time")
        defaults.set(setting.idle_time, forKey: "idle_time")
        defaults.set(setting.expected_user_image_width_px, forKey: "expected_user_image_width_px")
        defaults.set(setting.camera_page_bg, forKey: "camera_page_bg")
        defaults.set(setting.final_image_page_bg, forKey: "final_image_page_bg")
    }
    
    static func getSettings() -> SettingModel {
        let setting = SettingModel()
        setting.home_bg = defaults.string(forKey: "home_bg")
        setting.logo = defaults.string(forKey: "logo")
        setting.number_of_shots = defaults.string(forKey: "number_of_shots")
        setting.shots_countdown_time = defaults.string(forKey: "shots_countdown_time")
        setting.idle_time = defaults.string(forKey: "idle_time")
        setting.expected_user_image_width_px = defaults.string(forKey: "expected_user_image_width_px")
        setting.camera_page_bg = defaults.string(forKey: "camera_page_bg")
        setting.final_image_page_bg = defaults.string(forKey: "final_image_page_bg")
        return setting
    }
}
