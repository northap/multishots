//
//  UserImageModel.swift
//  MultiShots
//
//  Created by Attawat on 11/14/16.
//  Copyright © 2016 Attawat. All rights reserved.
//

import UIKit

class UserImageModel: NSObject {

    var sequence: Int?
    var image: String?
    
    init?(sequence: Int, image: String) {
        self.sequence = sequence
        self.image = image
    }
}
