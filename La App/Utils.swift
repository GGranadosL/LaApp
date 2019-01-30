//
//  Utils.swift
//  La App
//
//  Created by Gerardo Granados Lopez on 1/29/19.
//  Copyright © 2019 Gerardo Granados Lopez. All rights reserved.
//

import UIKit

let cell_id: String = "contact"

class Utils: NSObject {
    
    static func containsOnlyLetters(input: String) -> Bool {
        for chr in input.characters {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
}

class Contact: NSObject {
    var fullName: String? = nil
    var phoneNumber: String? = nil
    
    init(fullName: String, phoneNumber: String) {
        self.fullName = fullName
        self.phoneNumber = phoneNumber
    }
}




