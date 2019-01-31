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
    
    fileprivate var contacts = [Contact]()
    fileprivate var sortedContacts : [[Contact]] = []
    fileprivate var filteredContacts : [[Contact]] = []
    fileprivate var filterring = false
    
    private let refreshControl = UIRefreshControl()
    
    var users = [Contact]()
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
        navigationItem.hidesSearchBarWhenScrolling = false
        search.dimsBackgroundDuringPresentation = false
        self.navigationItem.searchController = search
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
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
        sortedContacts = contacts.reduce([[Contact]]()) { (output, value) -> [[Contact]] in
            var output = output
            if output.count < 26 {
                output = (1..<27).map{ _ in return []}
            }
            if let first = value.fullName?.first {
                let prefix = String(describing: first).lowercased()
                let prefixIndex = Int(UnicodeScalar(prefix)!.value - unicodeScalarA.value)
                var array = output[prefixIndex]
                array.append(value)
                output[prefixIndex] = array.sorted(by: {  $0.fullName! > $1.fullName! })
            }
            return output
        }
        sortedContacts = sortedContacts.filter { $0.count > 0}
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

extension ContactListViewController: UISearchResultsUpdating, UISearchBarDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            let num = Int(text)
            if num != nil {
                self.filteredContacts = sortedContacts.filter { (dataArray:[Contact]) -> Bool in
                    return dataArray.filter({ (contact) -> Bool in
                        return (dataArray.first?.phoneNumber?.lowercased().contains(text.lowercased()))!
                    }).count > 0
                }
            }
            else {
                self.filteredContacts = sortedContacts.filter { (dataArray:[Contact]) -> Bool in
                    return dataArray.filter({ (contact) -> Bool in
                        return (dataArray.first?.fullName?.lowercased().contains(text.lowercased()))!
                    }).count > 0
                }
            }
            self.filterring = true
            
        } else {
            self.filterring = false
            self.filteredContacts = [[Contact]]()
        }
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            //            self.filteredContacts = self.sortedContacts.filter {
            //                $0[0].fullName!.lowercased().range(of: text.lowercased()) != nil
            //                    || $0[1].fullName!.lowercased().range(of: text.lowercased()) != nil
            //            }
            let num = Int(text)
            if num != nil {
                self.filteredContacts = sortedContacts.filter { (dataArray:[Contact]) -> Bool in
                    return dataArray.filter({ (contact) -> Bool in
                        return (dataArray.first?.phoneNumber?.lowercased().contains(text.lowercased()))!
                    }).count > 0
                }
            }
            else {
                self.filteredContacts = sortedContacts.filter { (dataArray:[Contact]) -> Bool in
                    return dataArray.filter({ (contact) -> Bool in
                        return (dataArray.first?.fullName?.lowercased().contains(text.lowercased()))!
                    }).count > 0
                }
            }
            self.filterring = true
            
        } else {
            self.filterring = false
            self.filteredContacts = [[Contact]]()
        }
        self.tableView.reloadData()
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
                //controller.recipients = [sortedContacts[indexPath.section-1][indexPath.item].fullName!]
                controller.recipients = [number]
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
        return self.filterring ? filteredContacts.count+1 : sortedContacts.count+1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users.count
        } else {
            return self.filterring ? filteredContacts[section-1].count : sortedContacts[section-1].count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! ContactTableViewCell
            if sortedContacts.count > 1 {
                cell.lblName.text = users[indexPath.item].fullName
                cell.lblPhone.text = users[indexPath.item].phoneNumber
                cell.lblInitial.text = String((users[indexPath.item].fullName?.first)!).uppercased()
            }
            cell.lblPhone.isHidden = false
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! ContactTableViewCell
            if self.filterring {
                
                if filteredContacts.count > 1 {
                    cell.lblName.text = filteredContacts[indexPath.section-1][indexPath.item].fullName
                    cell.lblInitial.text = String((filteredContacts[indexPath.section-1][indexPath.item].fullName!.first)!).uppercased()
                }
            } else {
                if sortedContacts.count > 1 {
                    cell.lblName.text = sortedContacts[indexPath.section-1][indexPath.item].fullName
                    cell.lblInitial.text = String((sortedContacts[indexPath.section-1][indexPath.item].fullName!.first)!).uppercased()
                }
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
            if self.filterring {
                if filteredContacts.count > 1 {
                    label.text = String(filteredContacts[section-1][0].fullName!.first!).uppercased()
                }
            } else {
                if sortedContacts.count > 1 {
                    label.text = String(sortedContacts[section-1][0].fullName!.first!).uppercased()
                }
            }
            label.backgroundColor = UIColor.lightGray
            return label
        }
    }
    
}
