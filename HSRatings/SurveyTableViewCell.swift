//
//  SurveyTableViewCell.swift
//  HSRatings
//
//  Created by mac apple on 09/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit

class SurveyTableViewCell: UITableViewCell {

    @IBOutlet weak var surveyCellStatusLabel: UILabel!
    @IBOutlet weak var surveyCellDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
