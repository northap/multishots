//
//  OrientationSingleton.swift
//  MultiShots
//
//  Created by Attawat Panich on 5/23/2560 BE.
//  Copyright © 2560 Attawat. All rights reserved.
//

import Foundation

class OrientationSingleton {
    
    static let sharedInstance : OrientationSingleton = {
        let instance = OrientationSingleton()
        return instance
    }()
    
    var isPortrait : Bool = false
    var isSquare : Bool = false

}
