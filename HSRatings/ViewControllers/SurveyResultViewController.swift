//
//  SurveyResultViewController.swift
//  HSRatings
//
//  Created by mac apple on 16/07/2017.
//  Copyright © 2017 grkmndr. All rights reserved.
//

import UIKit
import Charts
import FirebaseAuth
import FirebaseDatabase

class SurveyResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var matrixTableView: UITableView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!

    var currentSurvey : Survey?
    let usersRef = Database.database().reference(withPath: "users")
    let surveysRef = Database.database().reference(withPath: "surveys")
    
    var dataEntries: [BarChartDataEntry] = []
    var barValues: [Double] = []
    var barLabels: [String] = []

    var surveyUsers: [User] = []

    @IBOutlet weak var surveyResultBarChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBackgroundImage()
        
        containerViewHeightConstraint.constant = 420
        if currentSurvey != nil {
            let currentSurveyRef = surveysRef.child((currentSurvey?.surveyid)!)
            currentSurveyRef.observe(DataEventType.value, with: { (snapshot) in
                
                if snapshot.childrenCount != 0 {
                    self.currentSurvey = Survey(snapshot: snapshot)
                    self.clearChartData()
                    self.fetchChartData()
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchChartData() {
        var loadedPlayerCount = 0
        
        for player in (currentSurvey?.players)! {
            let currentUserRef = self.usersRef.child(player.key)
            currentUserRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let userData = User(snapshot: snapshot)
                
                self.surveyUsers.append(userData)
                self.barLabels.append(userData.username)
                
                var count = 0.0
                var playerTotalRating = 0.0
                let predicate = NSPredicate(format: "ratedId = %@", player.key)
                let filteredRatings = ((self.currentSurvey?.ratings)! as NSArray).filtered(using: predicate)
                for rating in filteredRatings {
                    playerTotalRating += ((rating as! NSDictionary).value(forKey: "rating") as! Double)
                    count += 1
                }
                
                var playerAverageRating = 0.0
                
                if count != 0.0 {
                    playerAverageRating = playerTotalRating/count
                }
                
                self.barValues.append(playerAverageRating)
                
                loadedPlayerCount += 1
                if loadedPlayerCount == self.currentSurvey?.players.count {
                    self.sortChartData()
                    self.setChartProperties()
                    self.setChartData()
                    self.matrixTableView.reloadData()
                    self.containerViewHeightConstraint.constant = CGFloat(self.matrixTableView.numberOfRows(inSection: 1)*50 + 370)
                }
            })
            
        }
        
    }
    
    func setChartProperties() {
        
        // formatting the bar chart
        surveyResultBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:self.barLabels)
        surveyResultBarChartView.xAxis.setLabelCount(self.barLabels.count, force: false)
        surveyResultBarChartView.xAxis.drawGridLinesEnabled = false
        surveyResultBarChartView.xAxis.drawAxisLineEnabled = true
        surveyResultBarChartView.xAxis.labelRotationAngle = -70
        surveyResultBarChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        surveyResultBarChartView.rightAxis.enabled = false
        surveyResultBarChartView.leftAxis.enabled = true
        surveyResultBarChartView.leftAxis.spaceMax = 10.0
        surveyResultBarChartView.leftAxis.spaceMin = 0.0
        surveyResultBarChartView.leftAxis.drawGridLinesEnabled = true
        
        surveyResultBarChartView.leftAxis.axisMinimum = 0.0
        surveyResultBarChartView.leftAxis.axisMaximum = 10.2
        surveyResultBarChartView.leftAxis.labelCount = 5
        surveyResultBarChartView.leftAxis.drawZeroLineEnabled = true
        
        surveyResultBarChartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.6)
        surveyResultBarChartView.legend.enabled = false
        surveyResultBarChartView.chartDescription?.enabled = false
        surveyResultBarChartView.drawValueAboveBarEnabled = true
        

    }
    
    func setChartData() {
        // create the datapoints
        for (index, dataPoint) in self.barValues.enumerated() {
            let dataEntry = BarChartDataEntry(x: Double(index),
                                              y: dataPoint)
            dataEntries.append(dataEntry)
        }
        
        // create the chartDataSet
        let chartDataSet = BarChartDataSet(values: dataEntries,
                                           label: "")
        chartDataSet.colors = ChartColorTemplates.material()
        //chartDataSet.valueTextColor = UIColor.white
        
        let chartData = BarChartData(dataSet: chartDataSet)

        surveyResultBarChartView.data = chartData
        surveyResultBarChartView.notifyDataSetChanged()
        
    }
    
    func clearChartData() {
        self.barLabels = []
        self.barValues = []
        self.dataEntries = []
        self.surveyUsers = []
    }
    
    func sortChartData() {
        let combined1 = zip(barValues, barLabels).sorted {$0.0 > $1.0}
        let combined2 = zip(barValues, surveyUsers).sorted {$0.0 > $1.0}
        
        barValues = combined1.map {$0.0}
        barLabels = combined1.map {$0.1}
        surveyUsers = combined2.map {$0.1}
        
        print(barValues)
        print(barLabels)
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            //return barLabels.count
            return (currentSurvey?.players)!.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "surveyResultHeaderTableViewCell", for: indexPath) as! SurveyResultHeaderTableViewCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "surveyResultTableViewCell", for: indexPath) as! SurveyResultTableViewCell
            
            var ratingDistribution = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            
            if surveyUsers.count != 0 {
                let playerId = surveyUsers[indexPath.row].uid
                let predicate = NSPredicate(format: "ratedId = %@", playerId)
                let filteredRatings = ((self.currentSurvey?.ratings)! as NSArray).filtered(using: predicate)
                if filteredRatings.count != 0 {
                    for rating in filteredRatings {
                        let ratingValue = ((rating as! NSDictionary).value(forKey: "rating") as! Double)
                        ratingDistribution[Int(ratingValue)] += 1
                    }

                    cell.label0.text = String(ratingDistribution[0])
                    cell.label1.text = String(ratingDistribution[1])
                    cell.label2.text = String(ratingDistribution[2])
                    cell.label3.text = String(ratingDistribution[3])
                    cell.label4.text = String(ratingDistribution[4])
                    cell.label5.text = String(ratingDistribution[5])
                    cell.label6.text = String(ratingDistribution[6])
                    cell.label7.text = String(ratingDistribution[7])
                    cell.label8.text = String(ratingDistribution[8])
                    cell.label9.text = String(ratingDistribution[9])
                    cell.label10.text = String(ratingDistribution[10])
                }
                
                cell.nameLabel.text = surveyUsers[indexPath.row].username
                cell.avgRatingLabel.text = String(barValues[indexPath.row])
            }
            
            return cell
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

}
