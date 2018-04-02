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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    }

    @IBAction func saveShiftTapped(_ sender: UIButton) {
        
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
