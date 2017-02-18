//
//  EventViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum MemberStatus {
    case member
    case nonMember
}

class EventViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var joinButton: UIBarButtonItem!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var memberCountLabel: UILabel!
    @IBOutlet var collectionPointLabel: UILabel!
    @IBOutlet var needsLabel: UILabel!
    @IBOutlet var feedButton: UIButton!
    @IBOutlet var addNeedButton: UIButton!
    @IBOutlet var tableView: UITableView!
    var event: Event?
    var memberMode = MemberStatus.member
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinButtonTapped(_ sender: UIBarButtonItem) {
        makeAlert()
    }
    
    func switchOnMember(_ event: Event) {
        switch memberMode {
        case .member:
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
                            self.dismiss(animated: true, completion: nil)
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.memberMode = .nonMember
                            })
                        }
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.memberMode = .nonMember
                    })
                }
            })
        case .nonMember:
            self.joinButton.title = "Leave"
            EventController.sharedInstance.joinEvent(event, completion: { (success) in
                if !success {
                    // Make Alert
                    self.joinButton.title = "Join"
                    return
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.memberMode = .member
                })
            })
        }
    }
    
    func makeAlert() {
        var title: String
        var message: String
        switch memberMode {
        case .member:
            title = "Leaving Disaster Group"
            message = "Are you sure you'd like to leave the group?"
        case .nonMember:
            title = "Join Disaster Group"
            message = "Are you sure you'd like to joing the group?"
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            guard let event = self.event else { return }
            self.switchOnMember(event)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addNeedButtonTapped(_ sender: UIButton) {
        // Present an alert
        let alertController = UIAlertController(title: "Add a Need", message: "Enter your need and a specified quantity.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Need"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (UIAlertAction) in
            if let needText = alertController.textFields?[0].text, needText.isEmpty == false {
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
        let cancelAcion = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
        alertController.addAction(cancelAcion)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
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
    
    func updateWithEvent(_ event: Event?) {
        if let event = event {
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
                memberMode = .member
                joinButton.title = "Leave"
            } else {
                memberMode = .nonMember
                joinButton.title = "Join"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFeed" {
            guard let destinationView = segue.destination as? FeedViewController else { return }
            destinationView.event = event
            destinationView.view.backgroundColor = UIColor.reliefAlphaBlack()
        }
    }
    
}

extension EventViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let event = self.event {
            return event.needs.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "needCell", for: indexPath)
        if let event = self.event {
            let need = event.needs[indexPath.row]
            cell.textLabel?.text = need
        }
        return cell
    }
    
}










