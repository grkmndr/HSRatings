//
//  SurveyDetailTableViewCell.swift
//  HSRatings
//
//  Created by mac apple on 12/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit
import Cosmos

class SurveyDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cosmosView.settings.fillMode = .half
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
