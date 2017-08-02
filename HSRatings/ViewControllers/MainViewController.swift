    //
//  MainViewController.swift
//  HSRatings
//
//  Created by mac apple on 08/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MainViewController: UIViewController {
    @IBOutlet weak var avgRatingLabel: UILabel!
    @IBOutlet weak var matchCountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorBelow: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorBelowView: UIView!
    
    
    let usersRef = Database.database().reference(withPath: "users")
    let surveysRef = Database.database().reference(withPath: "surveys")
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBackgroundImage()
        
        activityIndicator.startAnimating()
        activityIndicatorBelow.startAnimating()
        
        let currentUserRef = self.usersRef.child((self.user?.uid)!)
        currentUserRef.observe(DataEventType.value, with: { (snapshot) in
            let userData = User(snapshot: snapshot)
            self.usernameLabel.text = userData.username
            self.avgRatingLabel.text = "Average rating: \(userData.rating)"
            self.matchCountLabel.text = "Games played: \(userData.matchesCount)"
            
            if self.activityIndicator.isAnimating && self.activityIndicatorBelow.isAnimating{
                self.activityIndicator.stopAnimating()
                self.activityIndicatorBelow.stopAnimating()
                self.activityIndicatorBelowView.removeFromSuperview()
            }
        })
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSurveys" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

}
