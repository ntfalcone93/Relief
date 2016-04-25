//
//  ChatTableViewCell.swift
//  Relief
//
//  Created by Jake Hardy on 4/22/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var userMessageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}