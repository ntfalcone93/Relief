//
//  EventViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit

enum MemberStatus {
    case Member
    case NonMember
}

class EventViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var joinButton: UIBarButtonItem!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var memberCountLabel: UILabel!
    @IBOutlet var collectionPointLabel: UILabel!
    @IBOutlet var needsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    var event: Event?
    var memberMode = MemberStatus.Member
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func joinButtonTapped(sender: UIBarButtonItem) {
        guard let event = event else { return }
        switchOnMember(event)
        
    }
    @IBAction func feedButtonTapped(sender: UIButton) {
        
    }
    
    func switchOnMember(event: Event) {
        switch memberMode {
        case .Member:
            self.joinButton.title = "Join"
            EventController.sharedInstance.leaveEvent(event, completion: { (success) in
                if !success {
                    // Make Alert
                    self.joinButton.title = "Leave"
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.memberMode = .NonMember
                })
            })
            
            
        case .NonMember:
            self.joinButton.title = "Leave"
            EventController.sharedInstance.joinEvent(event, completion: { (success) in
                if !success {
                    // Make Alert
                    self.joinButton.title = "Join"
                    return
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.memberMode = .Member
                })
            })
        }
    }
    
    
    @IBAction func addNeedButtonTapped(sender: UIButton) {
        // Present an alert
        let alertController = UIAlertController(title: "Add a Need", message: "Enter your need and a specified quantity.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Need"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            if let needText = alertController.textFields?[0].text {
                EventController.sharedInstance.addNeedToEvent(self.event!, need: needText, completion: { (success) in
                    if success {
                        self.needsLabel.text = "\(self.event!.needs.count) Needs"
                        self.tableView.reloadData()
                    } else {
                        return
                    }
                })
            }
        }
        let cancelAcion = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAcion)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.updateWithEvent(self.event)
    }
    
    func updateWithEvent(event: Event?) {
        if let event = event {
            self.titleLabel.text = event.title
            self.typeLabel.text = event.type
            self.memberCountLabel.text = "\(event.members.count) Members"
            self.collectionPointLabel.text = event.collectionPoint
            self.needsLabel.text = "\(event.needs.count) Needs"
            guard let identifier = UserController.sharedInstance.currentUser.identifier else { return }
            if event.members.contains(identifier) {
                memberMode = .Member
                joinButton.title = "Leave"
            } else {
                memberMode = .NonMember
                joinButton.title = "Join"
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toFeed" {
            guard let destinationView = segue.destinationViewController as? FeedViewController else { return }
            destinationView.event = event
            
            
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










