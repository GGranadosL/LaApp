//
//  ContactListViewController.swift
//  La App
//
//  Created by Gerardo Granados Lopez on 1/29/19.
//  Copyright © 2019 Gerardo Granados Lopez. All rights reserved.
//

import UIKit
import Contacts

class ContactListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var contacts = [Contact]()
    var names = [String]()
    var sortedNames : [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contactos"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "contact")
        navigationController?.navigationBar.prefersLargeTitles = true
        getContacts()
        splitContacts()
        tableView.reloadData()
    }
    
    
    
    private func getContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access:", err)
                return
            }
            
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        if Utils.containsOnlyLetters(input: contact.givenName) && contact.givenName != "" {
                            self.contacts.append(Contact.init(fullName: ("\(contact.givenName) \(contact.familyName)"), phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? ""))
                            self.names.append("\(contact.givenName) \(contact.familyName)")
                        }
                    })
                } catch let err {
                    print("Failed to get contacts: ", err)
                }
                print(self.contacts.count)
            } else {
                print("Access denied..")
            }
        }
        
    }
    
    
    func splitContacts() {
        let unicodeScalarA = UnicodeScalar("a")!
        
        sortedNames = names.reduce([[String]]()) { (output, value) -> [[String]] in
            var output = output
            
            if output.count < 26 {
                output = (1..<27).map{ _ in return []}
            }
            
            if let first = value.characters.first {
                let prefix = String(describing: first).lowercased()
                let prefixIndex = Int(UnicodeScalar(prefix)!.value - unicodeScalarA.value)
                var array = output[prefixIndex]
                array.append(value)
                output[prefixIndex] = array.sorted()
            }
            return output
        }
        sortedNames = sortedNames.filter { $0.count > 0}
    }
    
    
    
    
}

extension ContactListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedNames[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! ContactTableViewCell
        if sortedNames.count > 1 {
            cell.lblName.text = sortedNames[indexPath.section][indexPath.item]
        }
        cell.lblPhone.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init()
        if sortedNames.count > 1 {
            label.text = String(sortedNames[section][0].first!).uppercased()
        }
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
}
