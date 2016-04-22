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
    
    let cellHeaderTitles = ["Local Events", "All Events"]
    
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
            }
        }
    }
    
}

extension EventTableViewController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventController.sharedInstance.events.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < cellHeaderTitles.count {
            return cellHeaderTitles[section]
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath)
        let event = EventController.sharedInstance.events[indexPath.row]
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "\(event.needs.count) Needs"
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cellHeaderTitles.count
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
            let navController = segue.destinationViewController as! UINavigationController
            let evc = navController.childViewControllers[0] as! EventViewController
            let event = EventController.sharedInstance.events[indexPath!.row]
            evc.event = event
            evc.view.backgroundColor = UIColor.reliefAlphaBlack()
            evc.navigationController?.navigationItem.leftBarButtonItem?.title = "Done"
        }
    }
    
}

// When a user taps a cell we need to send a notification to the map view
// That notification will present a modal segue.
// We will need to somehow reference the cell and event assosciated with it (if we can get the indexpath.row we can do it).






