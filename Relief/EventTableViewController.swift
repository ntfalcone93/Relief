//
//  EventTableViewController.swift
//  Relief
//
//  Created by Jake Hardy on 4/15/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
import CoreGraphics

class EventTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EventsUpdating {
    @IBOutlet var tableView: UITableView!
    
    let cellHeaderTitles = ["User Events", "Local Events"]
    
    var userEvents: [Event] {
        get {
            guard UserController.sharedInstance.currentUser != nil else { return [] }
            return EventController.sharedInstance.events.filter { (Event) -> Bool in
                if Event.members.contains(UserController.sharedInstance.currentUser.identifier!) {
                    print("true in userEvents Array")
                    return true
                } else if UserController.sharedInstance.currentUser.identifier == nil {
                    print("wtf")
                }
                return false
            }
        }
    }
    
    var localEvents: [Event] {
        get {
            guard UserController.sharedInstance.currentUser != nil else { return [] }
            return EventController.sharedInstance.events.filter { (Event) -> Bool in
                if let identifier = UserController.sharedInstance.currentUser.identifier {
                    if !Event.members.contains(identifier) == true {
                        print("true in localEvents Array")
                        return true
                    } else if UserController.sharedInstance.currentUser.identifier == nil {
                        
                        return false
                    }
                }
                return false
            }
        }
    }
    
    var allEvents: [Event] {
        get { guard UserController.sharedInstance.currentUser != nil else { return [] }
            return userEvents + localEvents
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventController.sharedInstance.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    // MARK: - IBAction Functions
    @IBAction func logoutButtonTapped(sender: UIButton) {
        UserController.sharedInstance.logOutUser { (success) in
            if success {
                self.performSegueWithIdentifier("toLoginFromEventTableView", sender: nil)
                EventController.sharedInstance.events = []
            }
        }
    }
    
}

extension EventTableViewController {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userEvents.count
        } else {
            return localEvents.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cellHeaderTitles.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < cellHeaderTitles.count {
            return cellHeaderTitles[section]
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath)
        let event = allEvents[indexPath.row]
        cell.textLabel?.text = event.type
        cell.detailTextLabel?.text = "\(event.needs.count) Needs"
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailFromCell" {
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let lastView = destinationViewController.childViewControllers[0] as! FeedViewController
            lastView.event = allEvents[indexPath!.row]
            lastView.view.backgroundColor = UIColor.reliefAlphaBlack()
        }
    }
    
}

// When a user taps a cell we need to send a notification to the map view
// That notification will present a modal segue.
// We will need to somehow reference the cell and event assosciated with it (if we can get the indexpath.row we can do it).






