//
//  CreateSurveyViewController.swift
//  HSRatings
//
//  Created by mac apple on 09/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseDatabase

class CreateSurveyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var playerTableView: UITableView!
    
    let usersRef = Database.database().reference(withPath: "users")
    let surveysRef = Database.database().reference(withPath: "surveys")
    let user = Auth.auth().currentUser
    var users : [User] = []

    var selectedUsers : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadBackgroundImage()
        
        usersRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            for user in snapshot.children {
                
                let userInList = User(snapshot: user as! DataSnapshot)
                self.users.append(userInList)
                
            }
            self.playerTableView.reloadData()
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createSurveyTableViewCell", for: indexPath) as! CreateSurveyTableViewCell
        
        cell.playerNameLabel.text = users[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if (cell?.accessoryType == UITableViewCellAccessoryType.checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.none;
            selectedUsers = selectedUsers.filter { $0.uid != users[indexPath.row].uid }
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.checkmark;
            selectedUsers.append(users[indexPath.row])
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func createSurveyButtonTapped(_ sender: Any) {
        
        let timestamp = NSDate().timeIntervalSince1970
        
        var players = [String: Int]()
        
        for user in selectedUsers {
            players[user.uid] = 0
            
            if user.matchesCount != 0 {
                usersRef.child(user.uid).updateChildValues(["matchcount" : user.matchesCount + 1])
            } else {
                usersRef.child(user.uid).updateChildValues(["matchcount" : 1])
            }
            
            //players.append([user.uid: "Unanswered"])
        }
        
        let createdSurvey = surveysRef.childByAutoId()
        createdSurvey.setValue(["timestamp": timestamp, "players": players, "answercount": 0])
        
        for user in selectedUsers {
            usersRef.child(user.uid).child("surveyratings").updateChildValues([createdSurvey.key : 0.0])
        }
    }

}
