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
    let currentUser = Auth.auth().currentUser
    let surveysRef = Database.database().reference(withPath: "surveys")
    let usersRef = Database.database().reference(withPath: "users")
    
    var users: [User] = []
    var ratings: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSurveyUsers()
        
    }

    // MARK: - Firebase
    func loadSurveyUsers() {
        var uids = (currentSurvey?.players)!
        
        if let index = uids.index(of: (currentUser?.uid)!) {
            uids.remove(at: index)
        }
        
        for uid in uids {
            usersRef.queryOrderedByKey().queryEqual(toValue: uid).observe(DataEventType.value, with: { (snapshot) in
                self.users.append(User(snapshot: snapshot.childSnapshot(forPath: uid)))
                self.ratings.append(0)
                self.tableView.reloadData()
            })
        }
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
        self.navigationController?.popViewController(animated: true)
        
    }

}
