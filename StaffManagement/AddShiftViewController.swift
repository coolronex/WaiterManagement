//
//  AddShiftViewController.swift
//  StaffManagement
//
//  Created by Aaron Chong on 3/31/18.
//  Copyright © 2018 Derek Harasen. All rights reserved.
//

import UIKit

class AddShiftViewController: UIViewController {

    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var shiftDatePicker: UIDatePicker!
    
    var managedObjectContext: NSManagedObjectContext!
    var waiter: Waiter?
    var isConflicted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    }

    @IBAction func saveShiftTapped(_ sender: UIButton) {
        
        checkTimeConflict(chosenStartTime: startDatePicker.date,
                          chosenEndTime: endDatePicker.date,
                          chosenDay: shiftDatePicker.date)
        
        switch isConflicted {
        
        case true:
            let alert = UIAlertController(title:"Shift Conflict!", message: "Please try again", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            // reset isConflicted
            isConflicted = false
            
        default:
            
            if let shiftEntity = NSEntityDescription.entity(forEntityName: "Shift", in: managedObjectContext) {
                
                let newShift = Shift(entity: shiftEntity, insertInto: managedObjectContext)
                newShift.startTime = startDatePicker.date
                newShift.endTime = endDatePicker.date
                newShift.date = shiftDatePicker.date
                newShift.waiter = waiter
                waiter?.addShiftObject(newShift)
                
                do {
                    try managedObjectContext.save()
                    
                    let alert = UIAlertController(title:"Shift Added", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                } catch {
                    print(#line, error.localizedDescription)
                }
            }
        }
        
        
    }
    
    private func checkTimeConflict(chosenStartTime: Date, chosenEndTime: Date, chosenDay: Date) {
        
        if let waiter = waiter {
            
            for shift in waiter.shifts {
                
                let shiftDay = dateFormatter(date: shift.date)
                let pickedDay = dateFormatter(date: chosenDay)
                
                // check if the day is the same, if true then check conflicts
                if shiftDay == pickedDay {
                    
                    let shiftStartTime = timeFormatter(time: shift.startTime)
                    let shiftEndTime = timeFormatter(time: shift.endTime)
                    let pickedStartTime = timeFormatter(time: chosenStartTime)
                    let pickedEndTime = timeFormatter(time: chosenEndTime)
                    
                    if (pickedStartTime >= shiftStartTime && pickedStartTime <= shiftEndTime) || (pickedEndTime >= shiftStartTime && pickedEndTime <= shiftEndTime) {
                        isConflicted = true
                    }
                }
            }
        }
    }
    
    private func timeFormatter(time: Date) -> String {
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        return timeFormatter.string(from: time)
    }
    
    private func dateFormatter(date: Date) -> String {
        
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "dd MMM"
        
        return dayDateFormatter.string(from: date)
    }

}
