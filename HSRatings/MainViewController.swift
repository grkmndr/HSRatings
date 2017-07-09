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
    @IBOutlet weak var usernameLabel: UILabel!
    let usersRef = Database.database().reference(withPath: "users")
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUserRef = self.usersRef.child((self.user?.uid)!)
        currentUserRef.observe(DataEventType.value, with: { (snapshot) in
            
            guard let userData = snapshot.value as? NSDictionary else { return }
            self.usernameLabel.text = userData["username"] as? String
            
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
