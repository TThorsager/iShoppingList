//
//  ViewController.swift
//  iShoppingList
//
//  Created by TT on 22/05/2018.
//  Copyright © 2018 Thomas Thorsager. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

// actual viewcontroller
class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {  
    
    @IBOutlet weak var shoppingListTableView: UITableView! {
        didSet{
            shoppingListTableView.dataSource = self
            shoppingListTableView.delegate = self
        }
    }
    
    var ref: DatabaseReference?
    var shoppingListItems = [ShoppingListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference().child("shoppingListItems")
        
        // add locally
        ref?.observe(.childAdded, with: { (snapshot) in
            //converts value to string
            if let actualValue = snapshot.value as? [String: Any]{
                if let itemName = actualValue["itemName"] as? String, let bought = actualValue["bought"] as? Bool {
                    if let aItem = ShoppingListItem(id: snapshot.key, itemName: itemName, bought: bought){
                        self.shoppingListItems.append(aItem)
                        
                        let indexPath = IndexPath(row: self.shoppingListItems.count-1, section: 0)
                        self.shoppingListTableView.insertRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        })
        
        // update bought locally
        ref?.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            if let values = snapshot.value as? [String: Any], let bought = values["bought"] as? Bool {
                for (k, v) in (self.shoppingListItems.enumerated()) {
                    if v.id == key {
                        self.shoppingListItems[k].bought = bought
                        break
                    }
                }
                self.shoppingListTableView.reloadData()
            }
        })
        
        // delete locally
        ref?.observe(.childRemoved, with: { (snapshot) in
            var i : Int?
            let key = snapshot.key
            
            for (k, v) in (self.shoppingListItems.enumerated()) {
                if v.id == key {
                    i = k
                    break
                }
            }
            if let i = i {
                let indexPath = IndexPath(row: i, section: 0)
                self.shoppingListItems.remove(at: i)
                self.shoppingListTableView.deleteRows(at: [indexPath], with: .automatic)
                self.shoppingListTableView.reloadData()
            }
        })
        

        //MARK: - Database connection test
//        let connectedRef = Database.database().reference(withPath: ".info/connected")
//        connectedRef.observe(.value, with: { snapshot in
//            if snapshot.value as? Bool ?? false {
//                print("Connected")
//            } else {
//                print("Not connected")
//            }
//        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: TableView DataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingListItems.count
    }

    // define cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // first get the data to display from the shoppingListItems array
        let shoppingItem = shoppingListItems[indexPath.row]
        // then request a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ShoppingItemTableViewCell
        // set the looks of the table row
        cell?.itemNameLabel.textColor = shoppingItem.bought == true ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell?.itemNameLabel.text = shoppingItem.itemName
        cell?.bought.text = shoppingItem.bought == true ?  "✓" : ""
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // delete in swipe gesture
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // alert pop up before deleting
            let alertController = UIAlertController(title: "You want to delete:", message: "\(self.shoppingListItems[indexPath.row].itemName)", preferredStyle: .alert)
            //cancel button in alert
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (action: UIAlertAction) in print("Cancel tapped")
                completionHandler(false)
            }
            alertController.addAction(cancelAction)
            // delete button in alert
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
                (action: UIAlertAction) in self.ref?.child(self.shoppingListItems[indexPath.row].id).removeValue()
                print("Delted: itemName: \(self.shoppingListItems[indexPath.row].itemName), id: \(self.shoppingListItems[indexPath.row].id)")
            }
            alertController.addAction(deleteAction)
            
            self.present(alertController, animated: true, completion: nil)

        }
        // set the background color for the let delete
        delete.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        // creates the swipegesture
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    
    //Gets rid of the default right swipe action
    func tableView( _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        // bought/not bought in swipe gesture
        let boughtTitle = shoppingListItems[indexPath.row].bought ? "Not bought" : "Bought"
        let bought = UIContextualAction(style: .normal, title: boughtTitle){(action, view, nil) in
            if (self.shoppingListItems[indexPath.row].bought == false) {
                self.ref?.child(self.shoppingListItems[indexPath.row].id).child("bought").setValue(true)
            } else {
                self.ref?.child(self.shoppingListItems[indexPath.row].id).child("bought").setValue(false)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        bought.backgroundColor = shoppingListItems[indexPath.row].bought ? #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1) : #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        let config = UISwipeActionsConfiguration(actions: [bought])
        return config
    }
    
    @IBAction func rewindSegueToShoppingListViewController(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! UINavigationController
        let addDest = dest.viewControllers.first as! AddToShoppingListViewController
        addDest.segueArray = shoppingListItems
    }

}

