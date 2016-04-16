//
//  UserController.swift
//  Relief
//
//  Created by Kaelin Osmun on 4/13/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import Firebase

class UserController {
    
    static let sharedInstance = UserController()
    
    private let kUser = "userKey"
    
    var currentUser: User!
//        {
//        get {
//            return 
//            guard let uid = FirebaseController.firebase.authData?.uid,
//                let userDictionary = NSUserDefaults.standardUserDefaults().valueForKey(kUser) as? [String: AnyObject] else {
//                    
//                    return nil
//            }
//            
//            return User(json: userDictionary, identifier: uid)
//        }
//        set {
//            
//            if let newValue = newValue {
//                NSUserDefaults.standardUserDefaults().setValue(newValue.jsonValue, forKey: kUser)
//                NSUserDefaults.standardUserDefaults().synchronize()
//            } else {
//                NSUserDefaults.standardUserDefaults().removeObjectForKey(kUser)
//                NSUserDefaults.standardUserDefaults().synchronize()
//            }
//        }
//    }
    
    
    static func fetchUserWithId(identifier: String, completion: (user: User?) -> Void) {
        
        FirebaseController.dataAtEndPoint("users/\(identifier)") { (data) -> Void in
            
            if let json = data as? [String: AnyObject] {
                let user = User(json: json, identifier: identifier)
                completion(user: user)
            } else {
                completion(user: nil)
            }
        }
    }
    
    static func createUser(firstName: String, lastName: String?, email: String, password: String, completion: (success: Bool) -> Void) {
        
        FirebaseController.firebase.createUser(email, password: password) { (error, userDict) in
            
            if let identifier = userDict["uid"] as? String {
                var user = User(firstName: firstName, lastName: lastName, identifier: identifier)
                user.save()
                
                self.authenticateUser(email, password: password, completion: { (success) -> Void in
                    completion(success: success)
                })
            } else {
                completion(success: false)
            }
        }
    }
    
    static func authenticateUser(email: String, password: String, completion: (success: Bool) -> Void) {
        
        FirebaseController.firebase.authUser(email, password: password) { (error, authData) in
            completion(success: true)
            
            if error != nil {
                print("Unsuccessful login attempt.")
                completion(success: false)
            } else {
                print("User ID: \(authData.uid) authenticated successfully.")
                self.fetchUserWithId(authData.uid, completion: { (user) in
                    
                    if let user = user {
                        sharedInstance.currentUser = user
                    }
                    
                    completion(success: true)
                })
            }
        }
    }
    
    func logOutUser(completion: (success: Bool) -> Void) {
        
        FirebaseController.firebase.unauth()
        completion(success: true)
    }
    
    //    static func mockUsers() -> [User] {
    //
    //        let user1 = User(firstName: "Nathan", identifier: "0001")
    //        let user2 = User(firstName: "Jake", identifier: "0002")
    //        let user3 = User(firstName: "Dylan", identifier: "0003")
    //        let user4 = User(firstName: "Kaelin", identifier: "0004")
    //
    //        return [user1, user2, user3, user4]
    //    }
    //    
}
    