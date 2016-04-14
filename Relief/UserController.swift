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
    
//    currentUser: User!
    
    func fetchUserWithId(identifier: String, completion: (user: User?) -> Void) {
        
        let ref = FirebaseController.firebase
        
        ref.fetchUserWithId(identifier, completion: completion)
    }
    
    func createUser(firstName: String, lastName: String?, email: String, password: String, completion: (success: Bool) -> Void) {
        
        
    }
    
    func authenticateUser(email: String, password: String, completion: (success: Bool) -> Void) {
        
        
    }
    
    func logOutUser(completion: (success: Bool) -> Void) {
        
        
    }
    
    
}