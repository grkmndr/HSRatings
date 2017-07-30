//
//  CardView.swift
//  HSRatings
//
//  Created by mac apple on 29/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit

class CardView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.init(width: 5, height: 5)
        self.layer.shadowRadius = 10
    }
 

}
