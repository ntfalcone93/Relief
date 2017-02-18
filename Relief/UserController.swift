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
    
    fileprivate let kUser = "userKey"
    
    // Firebase - Current user check with data
    
    var currentUser: User!
            {
            get {
                guard let uid = FirebaseController.firebase?.authData?.uid,
                    let userDictionary = UserDefaults.standard.value(forKey: kUser) as? [String: AnyObject] else {
                        return nil
                }
    
                return User(json: userDictionary, identifier: uid)
            }
            set {
    
                if let newValue = newValue {
                    UserDefaults.standard.setValue(newValue.jsonValue, forKey: kUser)
                    UserDefaults.standard.synchronize()
                } else {
                    UserDefaults.standard.removeObject(forKey: kUser)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    
    // Firebase - Get user identifier
    
    static func fetchUserWithId(_ identifier: String, completion: @escaping (_ user: User?) -> Void) {
        
        FirebaseController.dataAtEndPoint("users/\(identifier)") { (data) -> Void in
            
            if let json = data as? [String: AnyObject] {
                let user = User(json: json, identifier: identifier)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    // Firebase - Create user
    
    static func createUser(_ firstName: String, lastName: String?, email: String, password: String, completion: @escaping (_ success: Bool, _ user: User?) -> Void) {
        
        FirebaseController.firebase?.createUser(email, password: password) { (error, userDict) in
            if let error = error {
                print(error)
                completion(false, nil)
                return
            }
            if let identifier = userDict?["uid"] as? String {
                var user = User(firstName: firstName, lastName: lastName, identifier: identifier)
                user.save()
                self.authenticateUser(email, password: password, completion: { (success) -> Void in
                    if success {
                        completion(success, user)
                    } else {
                        completion(false, nil)
                    }
                })
            } else {
                completion(false, nil)
            }
        }
    }
    
    // Firebase - User authentication
    
    static func authenticateUser(_ email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        
        FirebaseController.firebase?.authUser(email, password: password) { (error, authData) in
            completion(true)
            
            if error != nil {
                print("Unsuccessful login attempt.")
                completion(false)
            } else {
                print("User ID: \(authData?.uid) authenticated successfully.")
                self.fetchUserWithId((authData?.uid)!, completion: { (user) in
                    
                    if let user = user {
                        sharedInstance.currentUser = user
                    }
                    
                    completion(true)
                })
            }
        }
    }
    
    // Firebase - log out user
    
    func logOutUser(_ completion: (_ success: Bool) -> Void) {
        
        FirebaseController.firebase?.unauth()
        completion(true)
    }
    
    // Required block user function
    
    static func blockUser(_ identifier: String) {
        guard var user = UserController.sharedInstance.currentUser else { return }
        user.blockedUserIDs.append(identifier)
        user.save()
        UserController.sharedInstance.currentUser = user
        
    }
}
    
