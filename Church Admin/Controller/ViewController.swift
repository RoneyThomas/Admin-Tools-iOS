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
    
    var keys: Array<String> = []
    var snapshots: [DataSnapshot] = [DataSnapshot]()
    var schedules: [Schedule] = [Schedule]()
    var ref: DatabaseReference = DatabaseReference()
    var selected: Int = 0
    var editingExistingSchedule: Bool = false
    @IBOutlet weak var scheduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // User is signed in
        ref = Database.database().reference().child("schedule")
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        // Used to set UITableView height to height of the cells
        scheduleTableView.tableFooterView = UIView()
        configureTableView()
        editingExistingSchedule = false
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("Coming back to main view controller")
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        } else {
            loadData()
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
        cell.eventLabel.attributedText = makeAttributedString(title: schedules[indexPath.row].title ?? "", times: schedules[indexPath.row].times ?? [""],
                                                              events: schedules[indexPath.row].events ?? [""])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            schedules.remove(at: indexPath.row)
            scheduleTableView.deleteRows(at: [indexPath], with: .fade)
            ref.child(keys[indexPath.row]).removeValue()
            keys.remove(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
        editingExistingSchedule = true
        performSegue(withIdentifier: "addSchedule", sender: nil)
        scheduleTableView.deselectRow(at: indexPath, animated: true)
        editingExistingSchedule = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSchedule" && editingExistingSchedule {
            if let destinationViewController = segue.destination as? AddScheduleViewController {
                destinationViewController.schedule = schedules[selected]
                destinationViewController.id = keys[selected]
            }
        }
    }
    
    // Mark: - Firebase DB
    func loadData() {
        print("Inside load data")
        schedules = [Schedule]()
        keys = []
        ref.observeSingleEvent(of: DataEventType.value, with: { (DataSnapshot) in
            for item in DataSnapshot.children {
                let child = item as! DataSnapshot
                self.keys.append(child.key)
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
    
    func makeAttributedString(title: String, times: Array<String>, events: Array<String>) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.purple]
        let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        let timeAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        
        let attributedString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        for (event, time) in zip(events.dropLast(), times.dropLast()) {
            attributedString.append(NSAttributedString(string: "\(time) ", attributes: timeAttributes))
            attributedString.append(NSAttributedString(string: "\(event)\n", attributes: subtitleAttributes))
        }
        if events.count >= 1 || times.count >= 1 {
            attributedString.append(NSAttributedString(string: "\(times.last!) ", attributes: timeAttributes))
            attributedString.append(NSAttributedString(string: events.last!, attributes: subtitleAttributes))
        }
        print(attributedString)
        return attributedString
    }
}
