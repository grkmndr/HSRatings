//
//  User.swift
//  HSRatings
//
//  Created by mac apple on 08/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let email: String
    
    init(authData: User) {
        uid = authData.uid
        email = authData.email
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
