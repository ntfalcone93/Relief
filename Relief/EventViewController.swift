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
    @IBOutlet var feedButton: UIButton!
    @IBOutlet var addNeedButton: UIButton!
    @IBOutlet var tableView: UITableView!
    var event: Event?
    var memberMode = MemberStatus.Member
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func joinButtonTapped(sender: UIBarButtonItem) {
        makeAlert()
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
                if event.members.count <= 0 {
                    EventController.sharedInstance.deleteEvent(event, completion: { (success) in
                        if success {
                            self.dismissViewControllerAnimated(true, completion: nil)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.memberMode = .NonMember
                            })
                        }
                    })
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.memberMode = .NonMember
                    })
                }
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
    
    func makeAlert() {
        var title: String
        var message: String
        switch memberMode {
        case .Member:
            title = "Leaving Disaster Group"
            message = "Are you sure you'd like to leave the group?"
        case .NonMember:
            title = "Join Disaster Group"
            message = "Are you sure you'd like to joing the group?"
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (_) in
            guard let event = self.event else { return }
            self.switchOnMember(event)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addNeedButtonTapped(sender: UIButton) {
        // Present an alert
        let alertController = UIAlertController(title: "Add a Need", message: "Enter your need and a specified quantity.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Need"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            if let needText = alertController.textFields?[0].text where needText.isEmpty == false {
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
        alertController.addAction(cancelAcion)
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.updateWithEvent(self.event)
        self.configureViews()
    }
    
    func configureViews() {
        self.feedButton.tintColor = UIColor.reliefYellow()
        self.addNeedButton.tintColor = UIColor.reliefYellow()
    }
    
    func updateWithEvent(event: Event?) {
        if let event = event {
            self.titleLabel.text = event.title
            self.typeLabel.text = event.type
            if self.event?.members.count < 2 {
                self.memberCountLabel.text = "\(event.members.count) Member"
            } else {
                self.memberCountLabel.text = "\(event.members.count) Members"
            }
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
            destinationView.view.backgroundColor = UIColor.reliefAlphaBlack()
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










