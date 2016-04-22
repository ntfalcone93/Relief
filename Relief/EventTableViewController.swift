//
//  EventTableViewController.swift
//  Relief
//
//  Created by Jake Hardy on 4/15/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit

class EventTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EventsUpdating {
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventController.sharedInstance.delegate = self
        // Do any additional setup after loading the view.
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath)
        let event = EventController.sharedInstance.events[indexPath.row]
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "\(event.needs.count) Needs"
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
//            evc.view.backgroundColor = UIColor.reliefAlphaBlack()
            evc.navigationController?.navigationItem.leftBarButtonItem?.title = "Done"
        }
    }
}








