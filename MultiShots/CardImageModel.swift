//
//  CardImageModel.swift
//  MultiShots
//
//  Created by Attawat on 11/15/16.
//  Copyright © 2016 Attawat. All rights reserved.
//

import ObjectMapper

class CardImageModel: NSObject, Mappable {

    var card_image_type: String?
    var card_image: String?
    var card_id: String?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        card_image_type <- map["card_image_type"]
        card_image <- map["card_image"]
        card_id <- map["card_id"]
    }
    
    func card_image_decoding() -> UIImage {
        let decodedData = Data(base64Encoded: self.card_image!, options:NSData.Base64DecodingOptions(rawValue: 0))
        return UIImage(data: decodedData!)!
    }
}
