//
//  Utils.swift
//  La App
//
//  Created by Gerardo Granados Lopez on 1/29/19.
//  Copyright © 2019 Gerardo Granados Lopez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

// Strings constants
let cell_id: String = "contact"
let app_register: String = "isRegistered"

class Utils: NSObject {
    
    /**
     Check if the numbers and names has numbers or letter.
     
     Use when fill arrays
     
     - Parameters:
     - input: String
     
     - Returns: A boolean value
     */
    static func containsOnlyLetters(input: String) -> Bool {
        for chr in input {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    static func isRegistered(status: Bool) {
        UserDefaults.standard.set(status, forKey: app_register)
    }
    
    /**
     shows a uilaert with textfield that validate and create a user of La App
     
     - Parameters:
     - vc: view controller that shows alert
     
     - Returns: Void
     */
    static func register(vc: UIViewController){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "LaApp", message: "Introduce tu número celular a 10 dígitos: ", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Ej. 5531404162"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField!.text))")
            self.validateNumberDB(number: (textField?.text)!, vc: vc)
        }))
        
        // 4. Present the alert.
        vc.present(alert, animated: true, completion: nil)
    }
    
    /**
     find a duplicate in database if not registered then create a user
     
     - Parameters:
     - number: user number
     - vc: view controller that shows feedback
     
     - Returns: Void
     */
    static func validateNumberDB(number: String, vc: UIViewController) {
        let db = Firestore.firestore().collection("contacts")
        DispatchQueue.main.async {
            db.whereField("phoneNumber", isEqualTo: number).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot?.isEmpty ?? false {
                        print("Phone number not registered")
                        DispatchQueue.main.async {
                            self.createDocument(number: number, vc: vc)
                        }
                    }
                    else {
                        print("Phone number already registered")
                        self.isRegistered(status: true)
                    }
                }
            }
        }
    }
    
    /**
     Create a document in firestore
     
     - Parameters:
     - number: user number
     - vc: view controller that shows feedback
     
     - Returns: Void
     */
    static func createDocument(number:String, vc: UIViewController) {
        let db = Firestore.firestore().collection("contacts")
        print("Entrando a firestore")
        let docData: [String: Any] = [
            "phoneNumber": number
        ]
        DispatchQueue.main.async {
            db.addDocument(data: docData) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    let alert = UIAlertController(title: "¡Yeah!", message: "Registro completo", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.isRegistered(status: true)
                        vc.reloadInputViews()
                        
                    }
                    alert.addAction(okAction)
                    vc.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    /**
     Take a name and get his number.
     Calling this method to send message
     
     - Parameters:
     - name: compare name
     - contacts: all contacts
     
     - Returns: A number
     */
    static func getNumber(name: String, contacts: [Contact]) -> String {
        var number = ""
        for contact in contacts {
            if contact.fullName == name {
                number = contact.phoneNumber!
            }
        }
        return number
    }
}

/// A basic model of contacts
class Contact: NSObject {
    var fullName: String? = nil
    var phoneNumber: String? = nil
    
    /**
     Initializes a new contact with the two specifications.
     
     - Parameters:
     - fullName: full name of contact
     - phoneNumber: number of contact
     
     - Returns: A contact
     */
    init(fullName: String, phoneNumber: String) {
        self.fullName = fullName
        self.phoneNumber = phoneNumber
    }
    
    override init() {
    }
}
