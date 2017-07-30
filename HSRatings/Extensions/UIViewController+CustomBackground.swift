//
//  UIViewController+CustomBackground.swift
//  HSRatings
//
//  Created by mac apple on 29/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit

extension UIViewController {
    func loadBackgroundImage() {
        UIGraphicsBeginImageContext(view.frame.size)
        UIImage(named: "background_image_soccer")!.draw(in: view.frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetCurrentContext()
        view.backgroundColor = UIColor(patternImage: image!)
    }
}
