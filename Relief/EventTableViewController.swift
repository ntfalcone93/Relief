//
//  EventTableViewController.swift
//  Relief
//
//  Created by Jake Hardy on 4/15/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController, EventsUpdating {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        EventController.sharedInstance.delegate = self
        guard let location = LocationController.sharedInstance.coreLocationManager.location else { return }
        EventController.sharedInstance.fetchEventsInArea(location) { (success) in
            if success {
                print("success")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension EventTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventController.sharedInstance.events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath)
        let event = EventController.sharedInstance.events[indexPath.row]
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "\(event.needs.count) Needs"
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailFromCell" {
            let navController = segue.destinationViewController as! UINavigationController
            let evc = navController.childViewControllers[0] as! EventViewController
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            let event = EventController.sharedInstance.events[indexPath!.row]
            evc.event = event
        }
    }
}








