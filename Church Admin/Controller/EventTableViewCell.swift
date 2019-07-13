//
//  EventTableViewCell.swift
//  Church Admin
//
//  Created by Roney Thomas Mannoocheril on 2019-07-11.
//  Copyright © 2019 Roney Thomas Mannoocheril. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var datePicker = UIDatePicker()
    var toolBar = UIToolbar()
    var eventSuggestions = ["Prabhatha Namaskaram", "Holy Qurbana", "Sunday School"]
    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var eventTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        eventTextField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func timeFieldEditing(_ sender: UITextField) {
        datePicker = UIDatePicker.init()
        
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .time
        
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(self.timeChanged(_:)), for: .valueChanged)
    }
    
    @objc func timeChanged(_ sender: UIDatePicker?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        
        if let date = sender?.date {
            print("Picked the date \(dateFormatter.string(from: date))")
            self.timeTextField.text = dateFormatter.string(from: date)
        }
    }
    
    @objc func onDoneButtonClick() {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !autoCompleteText(in: textField, using: string, suggestions: eventSuggestions)
    }
    
    func autoCompleteText(in textField: UITextField, using string: String, suggestions: [String]) -> Bool {
        if !string.isEmpty,
            let selectedTextRange = textField.selectedTextRange, selectedTextRange.end == textField.endOfDocument,
            let prefixRange = textField.textRange(from: textField.beginningOfDocument, to: selectedTextRange.start),
            let text = textField.text(in: prefixRange) {
            let prefix = text + string
            let matches = suggestions.filter { $0.lowercased().hasPrefix(prefix.lowercased()) }
            
            if (matches.count > 0) {
                textField.text = matches[0]
                
                if let start = textField.position(from: textField.beginningOfDocument, offset: prefix.count) {
                    textField.selectedTextRange = textField.textRange(from: start, to: textField.endOfDocument)
                    
                    return true
                }
            }
        }
        return false
    }
}
