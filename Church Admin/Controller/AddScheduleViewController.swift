//
//  AddScheduleViewController.swift
//  Church Admin
//
//  Created by Roney Thomas Mannoocheril on 2019-07-06.
//  Copyright © 2019 Roney Thomas Mannoocheril. All rights reserved.
//

import UIKit
import Firebase

class AddScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var datePicker = UIDatePicker()
    var toolBar = UIToolbar()
    var schedule: Schedule = Schedule()
    var id: String = ""
    var deleted: Bool = false
    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eventTableView.delegate = self
        eventTableView.dataSource = self
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        titleTextField.text = schedule.title
        configureTableView()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func pressedDatePicker(_ sender: Any) {
        print("pressedDatePicker")
        datePicker = UIDatePicker.init()
        //        datePicker.backgroundColor = UIColor.white
        
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(datePicker)
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        //        toolBar.barStyle = .blackTranslucent
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneButtonClick))]
        toolBar.sizeToFit()
        self.view.addSubview(toolBar)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, EEEE"
        
        if let date = sender?.date {
            print("Picked the date \(dateFormatter.string(from: date))")
            self.titleTextField.text = dateFormatter.string(from: date)
        }
    }
    
    @objc func onDoneButtonClick() {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    func configureTableView() {
        eventTableView.rowHeight = UITableView.automaticDimension
        eventTableView.estimatedRowHeight = 30.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if deleted {
            return schedule.events?.count ?? 0
        } else {
            return schedule.events?.count ?? 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath) as! EventTableViewCell
        print("inside the cellForRowAt")
        if schedule.events?.count ?? 0 > 0 {
            cell.timeTextField.text = schedule.times![indexPath.row]
            cell.eventTextField.text = schedule.events![indexPath.row]
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let _ = schedule.events, let _ = schedule.times else {
                return
            }
            deleted = true
            schedule.events!.remove(at: indexPath.row)
            schedule.times!.remove(at: indexPath.row)
            eventTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func addEventRow(_ sender: Any) {
        schedule.events?.append("")
        schedule.times?.append("")
        eventTableView.reloadData()
    }
    
    @IBAction func saveSchedule(_ sender: Any) {
        print(titleTextField.text ?? "")
        var events: Array<String> = [], times: Array<String> = []
        for row in 0..<eventTableView.numberOfRows(inSection: 0) {
            let indexpath: IndexPath = IndexPath(row: row, section: 0)
            let cell = eventTableView.cellForRow(at: indexpath) as! EventTableViewCell
            times.append(cell.timeTextField.text ?? "")
            events.append(cell.eventTextField.text ?? "")
        }
        let schedule: [String: Any] = ["title": titleTextField.text!, "events": events , "times": times]
        if id.isEmpty {
            let ref: DatabaseReference = Database.database().reference().child("schedule")
            ref.childByAutoId().setValue(schedule) { (error, databaseReference) in
                if let error = error {
                    print(error)
                    return
                }
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            let ref: DatabaseReference = Database.database().reference().child("schedule").child(id)
            ref.updateChildValues(schedule) { (error, databaseReference) in
                if let error = error {
                    print(error)
                    return
                }
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
