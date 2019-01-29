//
//  ViewController.swift
//  La App
//
//  Created by Gerardo Granados Lopez on 1/28/19.
//  Copyright © 2019 Gerardo Granados Lopez. All rights reserved.
//

import UIKit
import Contacts
import AddressBook

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Get contacts
        let hola : UIBarButtonItem
        let store = CNContactStore()
        do {
            let contacts = try store.unifiedContacts(matching: CNContact.predicateForContacts(matchingName: "A"), keysToFetch:[CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor])
            print(contacts)
        } catch {
            print(error)
        }

    }



}

