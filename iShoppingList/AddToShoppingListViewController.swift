//
//  AddToShoppingListViewController.swift
//  iShoppingList
//
//  Created by TT on 22/05/2018.
//  Copyright © 2018 Thomas Thorsager. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddToShoppingListViewController: UIViewController, UITextFieldDelegate {
    
    //var segueItemObject: NSObject
    var segueArray: [ShoppingListItem] = []
    
    @IBOutlet weak var addShoppingItemField: UITextField! {
        didSet {
            addShoppingItemField.delegate = self
        }
    }
    
    
    var ref: DatabaseReference?
    let uuid = NSUUID().uuidString
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    
    func checkForDuplicate(x: String?) -> Bool {
        for ShoppingListItem in segueArray {
            if ShoppingListItem.itemName == x {
                return true
            }
        }
        return false
    }
    
    // check if item is already on your list
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let button = sender as! UIBarButtonItem
        if button.tag == 1 {
            if addShoppingItemField.text != "" {
                        if !checkForDuplicate(x: addShoppingItemField.text) {
                                return true
                        } else {
                            print("You got this item on your list")
                            
                            let alertController = UIAlertController(title: "The item is already on list", message: addShoppingItemField.text, preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
                            alertController.addAction(okAction)
                            present(alertController, animated: true, completion: nil)
                            return false
                        }
            } else {
                let alertController = UIAlertController(title: "You did not write any text", message: addShoppingItemField.text, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                
                
            return false
        }
        } else {
                return true
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // either the Cancel or the Save button was tapped
        let button = sender as! UIBarButtonItem
        //the save button was tapped
        if button.tag == 1 {
            // check if it aldready exists in the database by itemName
            ref = Database.database().reference().child("shoppingListItems")
            ref?.child(uuid).setValue(["itemName" : addShoppingItemField.text as Any, "bought" : false])
        }
    }
}
