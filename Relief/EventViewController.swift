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
    var event: Event?
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateWithEvent(self.event)
    }
    
    func updateWithEvent(event: Event?) {
        if let event = event {
            self.titleLabel.text = event.title
            self.memberCountLabel.text = "\(event.members.count) Members"
            self.collectionPointTextField.text = event.collectionPoint
            self.needsLabel.text = "\(event.needs.count) Needs"
        }
    }
    
}

extension EventViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let event = self.event {
            return event.needs.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("needCell", forIndexPath: indexPath)
        if let event = self.event {
            let need = event.needs[indexPath.row]
            cell.textLabel?.text = need
        }
        return cell
    }
}










