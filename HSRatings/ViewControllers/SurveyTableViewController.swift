//
//  SurveyTableViewController.swift
//  HSRatings
//
//  Created by mac apple on 09/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SurveyTableViewController: UITableViewController {
    
    let surveysRef = Database.database().reference(withPath: "surveys")
    var surveys: [Survey] = []
    let currentUser = Auth.auth().currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //loadBackgroundImage()
        
        self.tableView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
        
        
        
        surveysRef.observe(DataEventType.value, with: { (snapshot) in
            self.surveys = []
            for survey in snapshot.children {
                
                let surveyInList = Survey(snapshot: survey as! DataSnapshot)
                self.surveys.append(surveyInList)
                
            }
            self.tableView.reloadData()
        })
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return surveys.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "surveyTableViewCell", for: indexPath) as! SurveyTableViewCell
        
        // Configure the cell...
        let cellSurvey = surveys[indexPath.row]
        let date = NSDate(timeIntervalSince1970: cellSurvey.timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let timestamp = dateFormatter.string(from: date as Date)
        cell.surveyCellDateLabel.text = String(timestamp)
        
        if cellSurvey.players[currentUser.uid] == 0 {
            cell.surveyCellStatusLabel.text = "Unanswered"
        } else {
            cell.surveyCellStatusLabel.text = "Show Detail"
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSurveyDetail",
        let destination = segue.destination as? SurveyDetailTableViewController,
        let surveyIndex = self.tableView.indexPathForSelectedRow?.row {
            destination.currentSurvey = surveys[surveyIndex]
        } else if segue.identifier == "showSurveyResult",
            let destination = segue.destination as? SurveyResultViewController,
            let surveyIndex = self.tableView.indexPathForSelectedRow?.row {
            destination.currentSurvey = surveys[surveyIndex]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let cell = self.tableView.cellForRow(at: indexPath) as! SurveyTableViewCell
        if cell.surveyCellStatusLabel.text == "Unanswered" {
            performSegue(withIdentifier: "showSurveyDetail", sender: self)
        } else if cell.surveyCellStatusLabel.text == "Show Detail" {
            performSegue(withIdentifier: "showSurveyResult", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
