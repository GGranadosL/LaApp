//
//  ContactDetailViewController.swift
//  La App
//
//  Created by Gerardo Granados Lopez on 1/30/19.
//  Copyright © 2019 Gerardo Granados Lopez. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    @IBOutlet weak var lblPhoneNumber: UILabel!
    var contact : Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Set data in title and phone label
        navigationItem.title = contact?.fullName
        lblPhoneNumber.text = contact?.phoneNumber
    }
    
}
