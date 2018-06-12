//
//  ShoppingItem.swift
//  iShoppingList
//
//  Created by TT 04 on 24/05/2018.
//  Copyright © 2018 Thomas Thorsager. All rights reserved.
//

import UIKit

// structure
class ShoppingListItem: NSObject {
    var id: String
    var itemName: String
    var bought: Bool
    
    init?(id: String, itemName: String, bought: Bool) {
        self.id = id
        self.itemName = itemName
        self.bought = bought
    }
}
