//
//  ShoppingItemTableViewCell.swift
//  iShoppingList
//
//  Created by TT on 24/05/2018.
//  Copyright © 2018 Thomas Thorsager. All rights reserved.
//

import UIKit

class ShoppingItemTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    
    @IBOutlet weak var bought: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
