//
//  Survey.swift
//  HSRatings
//
//  Created by mac apple on 10/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Survey {
    
    let surveyid: String
    let timestamp: Double
    var ratings = [String: Double]()
    
    init(snapshot: DataSnapshot) {
        surveyid = snapshot.key
        
        let snapshotValue = snapshot.value as! [String : AnyObject]
        timestamp = snapshotValue["timestamp"] as! Double
        ratings = snapshotValue["ratings"] as! [String: Double]
    }
}
