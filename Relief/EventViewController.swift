//
//  EventViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var memberCountLabel: UILabel!
    @IBOutlet var collectionPointTextField: UITextField!
    @IBOutlet var needsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
