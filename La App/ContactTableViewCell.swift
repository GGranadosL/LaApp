//
//  ContactTableViewCell.swift
//  La App
//
//  Created by Gerardo Granados Lopez on 1/30/19.
//  Copyright © 2019 Gerardo Granados Lopez. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblInitial: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
