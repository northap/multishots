//
//  SettingModel.swift
//  MultiShots
//
//  Created by Attawat on 11/14/16.
//  Copyright © 2016 Attawat. All rights reserved.
//

import ObjectMapper

class SettingModel: NSObject, Mappable {
    
    var home_bg_image_type: String?
    var home_bg: String?
    var logo_image_type: String?
    var logo: String?
    var shots_countdown_time: String?
    var number_of_shots: String?
    var idle_time: String?
    var expected_user_image_width_px: String?
    var camera_page_image_type: String?
    var camera_page_bg: String?
    var final_image_page_image_type: String?
    var final_image_page_bg: String?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        home_bg_image_type <- map["home_bg_image_type"]
        home_bg <- map["home_bg"]
        logo_image_type <- map["logo_image_type"]
        logo <- map["logo"]
        shots_countdown_time <- map["shots_countdown_time"]
        number_of_shots <- map["number_of_shots"]
        idle_time <- map["idle_time"]
        expected_user_image_width_px <- map["expected_user_image_width_px"]
        camera_page_bg <- map["camera_page_bg"]
        final_image_page_bg <- map["final_image_page_bg"]
    }
    
    func home_bg_decoding() -> UIImage {
        let decodedData = Data(base64Encoded: self.home_bg!, options:NSData.Base64DecodingOptions(rawValue: 0))
        return UIImage(data: decodedData!)!
    }
    
    func logo_decoding() -> UIImage {
        let decodedData = Data(base64Encoded: self.logo!, options:NSData.Base64DecodingOptions(rawValue: 0))
        return UIImage(data: decodedData!)!
    }
    
    func camera_page_bg_decoding() -> UIImage {
        let decodedData = Data(base64Encoded: self.camera_page_bg!, options:NSData.Base64DecodingOptions(rawValue: 0))
        return UIImage(data: decodedData!)!
    }
    
    func final_image_page_bg_decoding() -> UIImage {
        let decodedData = Data(base64Encoded: self.final_image_page_bg!, options:NSData.Base64DecodingOptions(rawValue: 0))
        return UIImage(data: decodedData!)!
    }
}
