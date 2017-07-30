//
//  SurveyDetailTableViewController.swift
//  HSRatings
//
//  Created by mac apple on 12/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SurveyDetailTableViewController: UITableViewController {

    var currentSurvey : Survey?
    let currentUser = Auth.auth().currentUser!
    let surveysRef = Database.database().reference(withPath: "surveys")
    let usersRef = Database.database().reference(withPath: "users")
    
    var users: [User] = []
    var ratings: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadBackgroundImage()
        loadSurveyUsers()
        
    }

    // MARK: - Firebase
    func loadSurveyUsers() {
        let uids = (currentSurvey?.players)!
//        
//        
//        
//        if let index = uids.index(of: currentUser.uid) {
//            uids.remove(at: index)
//        }
        
        for uid in uids {
            usersRef.queryOrderedByKey().queryEqual(toValue: uid.key).observe(DataEventType.value, with: { (snapshot) in
                if uid.key != self.currentUser.uid {
                    self.users.append(User(snapshot: snapshot.childSnapshot(forPath: uid.key)))
                    self.ratings.append(0)
                }
                self.tableView.reloadData()
            })
        }
    }
    
    func submitSurvey() {
        var ratingsArray: [NSDictionary] = []
        for(index, rating) in ratings.enumerated(){
            let ratingDict = ["raterId": currentUser.uid, "ratedId": users[index].uid, "rating": rating] as [String : Any]
            ratingsArray.append(ratingDict as NSDictionary)
        }
        
        let currentSurveyRef = surveysRef.child((currentSurvey?.surveyid)!)
        // Create the data we want to update
        let ratingData = ["players/\(currentUser.uid)": 1, "ratings": ratingsArray] as [String : Any]
        // Do a deep-path update
        currentSurveyRef.updateChildValues(ratingData, withCompletionBlock: { (error, ref) -> Void in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: "An error occured while submitting the ratings.", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
        
//        surveysRef.child((currentSurvey?.surveyid)!).child("ratings").setValue(ratingsArray) { (error, surveysRef) -> Void in
//            if error != nil {
//                let alertController = UIAlertController(title: "Error", message: "An error occured while submitting the ratings.", preferredStyle: .alert)
//                self.present(alertController, animated: true, completion: nil)
//            } else {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
        
        
        
        //self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "surveyDetailTableViewCell", for: indexPath) as! SurveyDetailTableViewCell
        
        cell.playerNameLabel.text = users[indexPath.row].username
        cell.cosmosView.didFinishTouchingCosmos = { rating in
            self.ratings[indexPath.row] = rating
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    // MARK: - Actions
    @IBAction func submitSurveyButtonTapped(_ sender: Any) {
        
        if ratings.contains(0) {
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to rate some players 0 stars?", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                title: "Yes",
                style: UIAlertActionStyle.default,
                handler: {
                    (alert: UIAlertAction!) in
                        self.submitSurvey()
                }
            ))
            
            alertController.addAction(UIAlertAction(
                title: "No",
                style: UIAlertActionStyle.cancel,
                handler: nil
            ))
            
            
            present(alertController, animated: true, completion: nil)
        }
        else {
            submitSurvey()
        }
        
    }
    
    

}
