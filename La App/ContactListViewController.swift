//
//  ContactListViewController.swift
//  La App
//
//  Created by Gerardo Granados Lopez on 1/29/19.
//  Copyright © 2019 Gerardo Granados Lopez. All rights reserved.
//

import UIKit
import Contacts
import FirebaseFirestore
import MessageUI

class ContactListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var contacts = [Contact]()
    var users = [Contact]()
    var names = [String]()
    var sortedNames : [[String]] = []
    var registeredNumbers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contactos"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "contact")
        navigationController?.navigationBar.prefersLargeTitles = true
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.barStyle = .blackTranslucent
        search.searchBar.placeholder = "Buscar nombre o teléfono"
        self.navigationItem.searchController = search
        getContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                self.splitContacts()
            } else {
                print("Access denied..")
            }
        }
        
    }
    
    func compare (registeredNumbers: [String]) {
        for number in registeredNumbers {
            for i in contacts {
                let asNumber = i.phoneNumber?.replacingOccurrences(of: " 1 ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+52", with: "").replacingOccurrences(of: "(55)", with: "").replacingOccurrences(of: " ", with: "")
                if asNumber == number {
                    users.append(Contact.init(fullName: i.fullName!, phoneNumber: i.phoneNumber!))
                }
            }
            tableView.reloadData()
        }
    }
    
    func getCollection(){
        let db = Firestore.firestore()
        // [START get_collection]
        db.collection("contacts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print(document.data()["phoneNumber"] as! String)
                    self.registeredNumbers.append(document.data()["phoneNumber"] as! String)
                }
                print("Hola numeros: \(self.registeredNumbers.count)")
                if self.registeredNumbers.count > 0 {
                    self.compare(registeredNumbers: self.registeredNumbers)
                }
            }
        }
        // [END get_collection]
    }
    
    func splitContacts() {
        let unicodeScalarA = UnicodeScalar("a")!
        sortedNames = names.reduce([[String]]()) { (output, value) -> [[String]] in
            var output = output
            if output.count < 26 {
                output = (1..<27).map{ _ in return []}
            }
            if let first = value.first {
                let prefix = String(describing: first).lowercased()
                let prefixIndex = Int(UnicodeScalar(prefix)!.value - unicodeScalarA.value)
                var array = output[prefixIndex]
                array.append(value)
                output[prefixIndex] = array.sorted()
            }
            return output
        }
        sortedNames = sortedNames.filter { $0.count > 0}
        if !UserDefaults.standard.bool(forKey: app_register){
            Utils.register(vc: self)
            tableView.reloadData()
        }
        getCollection()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactDetail" {
            let viewController: ContactDetailViewController = segue.destination as! ContactDetailViewController
            viewController.contact = users[(sender as! IndexPath).item]
        }
    }
}

extension ContactListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //TODO
    }
}

extension ContactListViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
}

extension ContactListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "contactDetail", sender: indexPath)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
            let number = Utils.getNumber(name: cell.lblName.text!, contacts: self.contacts)
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Hey descarga LaApp"
                controller.recipients = [number]
                print(number)
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if users.count > 0 {
                return 32
            } else {
                return 0.0
            }
            
        } else {
            return 32
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedNames.count+1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users.count
        } else {
            return sortedNames[section-1].count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! ContactTableViewCell
            if sortedNames.count > 1 {
                cell.lblName.text = users[indexPath.item].fullName
                cell.lblPhone.text = users[indexPath.item].phoneNumber
                cell.lblInitial.text = String((users[indexPath.item].fullName?.first)!).uppercased()
            }
            cell.lblPhone.isHidden = false
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! ContactTableViewCell
            if sortedNames.count > 1 {
                cell.lblName.text = sortedNames[indexPath.section-1][indexPath.item]
                cell.lblInitial.text = String((sortedNames[indexPath.section-1][indexPath.item].first)!).uppercased()
            }
            cell.lblPhone.isHidden = true
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if users.count > 0 {
                let label = UILabel.init()
                label.text = "Usuarios de LaApp"
                label.backgroundColor = UIColor.lightGray
                return label
            } else {
                return UIView.init()
            }
        } else {
            let label = UILabel.init()
            if sortedNames.count > 1 {
                label.text = String(sortedNames[section-1][0].first!).uppercased()
            }
            label.backgroundColor = UIColor.lightGray
            return label
        }
    }
    
}
