//
//  User.swift
//  HSRatings
//
//  Created by mac apple on 08/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct User {

    let uid: String
    let email: String
    let username: String
    
    init(snapshot: DataSnapshot) {
        uid = snapshot.key
        
        let snapshotValue = snapshot.value as! [String : AnyObject]
        email = snapshotValue["email"] as! String
        username = snapshotValue["username"] as! String
    }
    
    
}
