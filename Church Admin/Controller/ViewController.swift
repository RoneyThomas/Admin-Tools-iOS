//
//  ViewController.swift
//  Church Admin
//
//  Created by Roney Thomas Mannoocheril on 2019-07-05.
//  Copyright © 2019 Roney Thomas Mannoocheril. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    var schedules: [String: String] = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // User is signed in
        if Auth.auth().currentUser != nil {
            ref = Database.database().reference().child("Schedule")
            loadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        print("Coming back to main view controller")
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
    
    @IBAction func addTouchButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        } catch let error {
            print(error)
        }
    }
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customScheduleCell", for: indexPath) as! SchdeduleTableViewCell
        return cell
    }
    
    // Mark: - Firebase DB
    func loadData() {
        ref.observe(.childAdded) { (DataSnapshot) in
            print(DataSnapshot.value as! String)
        }
    }
}

