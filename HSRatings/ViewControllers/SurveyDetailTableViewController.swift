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
            usersRef.queryOrderedByKey().queryEqual(toValue: uid.key).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if uid.key != self.currentUser.uid {
                    self.users.append(User(snapshot: snapshot.childSnapshot(forPath: uid.key)))
                    self.ratings.append(0)
                }
                self.tableView.reloadData()
            })
        }
    }
    
    func submitSurvey() {
        
        let currentSurveyRef = self.surveysRef.child((self.currentSurvey?.surveyid)!)
        currentSurveyRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.currentSurvey = Survey(snapshot: snapshot)
            
            var ratingsArray : [NSDictionary] = []
            if self.currentSurvey?.ratings != nil {
                ratingsArray = (self.currentSurvey?.ratings)!
            }
            
            for(index, rating) in self.ratings.enumerated(){
                let ratingDict = ["raterId": self.currentUser.uid, "ratedId": self.users[index].uid, "rating": rating] as [String : Any]
                ratingsArray.append(ratingDict as NSDictionary)
            }
            
            for (index, user) in self.users.enumerated() {
                let currentUserRef = self.usersRef.child(user.uid)
                currentUserRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                    
                    let predicate = NSPredicate(format: "ratedId = %@", user.uid)
                    let count = Double((ratingsArray as NSArray).filtered(using: predicate).count)
                    
                    var tempUser = User(snapshot: snapshot)
                    let playerCurrentSurveyRating = tempUser.surveyRatings[(self.currentSurvey?.surveyid)!]
                    
                    let playerCurrentSurveyNewRating = (playerCurrentSurveyRating! * count + self.ratings[index]) / (count + 1.0)
                    
                    currentUserRef.child("surveyratings").updateChildValues([(self.currentSurvey?.surveyid)! : playerCurrentSurveyNewRating])
                    tempUser.surveyRatings[(self.currentSurvey?.surveyid)!] = playerCurrentSurveyNewRating
                    
                    var ratingCount = 0.0
                    var playerTotalRating = 0.0
                    for surveyRating in tempUser.surveyRatings {
                        ratingCount += 1
                        playerTotalRating += surveyRating.value
                    }
                    
                    currentUserRef.updateChildValues(["rating" : playerTotalRating / ratingCount])
                    
                })
                
            }
            
//            for user in self.users {
//                var playerTotalRating = 0.0
//                var count = 0.0
//                
//                let predicate = NSPredicate(format: "ratedId = %@", user.uid)
//                let filteredRatings = (ratingsArray as NSArray).filtered(using: predicate)
//                
//                for rating in filteredRatings {
//                    playerTotalRating += ((rating as! NSDictionary).value(forKey: "rating") as! Double)
//                    count += 1
//                }
//                
//                let playerAvgRating = count == 0 ? -1 : playerTotalRating/count
//                
//                let currentUserRef = self.usersRef.child(user.uid)
//                currentUserRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
//                    let playerOverallRating = (snapshot.value as! NSDictionary)["rating"]! as! Double
//                    let playerMatchCount = (snapshot.value as! NSDictionary)["matchcount"]! as! Int
//                    if playerAvgRating != -1 {
//                        let playerNewOverallRating = (playerOverallRating * Double(playerMatchCount - 1) + playerAvgRating) / Double(playerMatchCount)
//                        currentUserRef.updateChildValues(["rating" : playerNewOverallRating])
//                    }
//                })
//
//            }
            // Create the data we want to update
            
            let ratingData = ["players/\(self.currentUser.uid)": 1, "ratings": ratingsArray, "answercount": (self.currentSurvey?.answerCount)! + 1] as [String : Any]
            // Do a deep-path update
            currentSurveyRef.updateChildValues(ratingData, withCompletionBlock: { (error, ref) -> Void in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: "An error occured while submitting the ratings.", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        })
        
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
            self.ratings[indexPath.row] = rating*2.0
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
