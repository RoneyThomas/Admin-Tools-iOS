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
    
    
    var snapshots: [DataSnapshot] = [DataSnapshot]()
    var schedules: [Schedule] = [Schedule]()
    @IBOutlet weak var scheduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // User is signed in
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        if Auth.auth().currentUser != nil {
            loadData()
        }
        configureTableView()
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
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath) as! SchdeduleTableViewCell
        cell.eventLabel.text = schedules[indexPath.row].events?[0]
        return cell
    }
    
    // Mark: - Firebase DB
    func loadData() {
        print("Inside load data")
        let ref: DatabaseReference = Database.database().reference().child("schedule")
        ref.observeSingleEvent(of: DataEventType.value, with: { (DataSnapshot) in
            for item in DataSnapshot.children {
                let child = item as! DataSnapshot
                let snapshot = child.value as! [String:AnyObject]
                var schedule: Schedule = Schedule()
                if let events = snapshot["events"] as! Array<String>? {
                    print(events)
                    schedule.events = events
                }
                if let times = snapshot["times"] as! Array<String>? {
                    print(times)
                    schedule.times = times
                }
                if let title = snapshot["title"] as! String? {
                    print(title)
                    schedule.title = title
                }
                if let expiryDate = snapshot["expiryDate"] as! TimeInterval? {
                    print(expiryDate)
                    schedule.expiryDate = expiryDate
                }
                self.schedules.append(schedule)
            }
            self.configureTableView()
            self.scheduleTableView.reloadData()
        })
    }
    
    func configureTableView() {
        scheduleTableView.rowHeight = UITableView.automaticDimension
        scheduleTableView.estimatedRowHeight = 400
    }
}
