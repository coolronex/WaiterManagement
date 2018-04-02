//
//  WaiterShiftsTableVC.swift
//  StaffManagement
//
//  Created by Aaron Chong on 3/31/18.
//  Copyright © 2018 Derek Harasen. All rights reserved.
//

import UIKit

class WaiterShiftsTableVC: UITableViewController {

    var waiter: Waiter?
    var managedObjectContext: NSManagedObjectContext!
    var shiftArray = [Shift]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateShiftArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateShiftArray()
        tableView.reloadData()
    }
    
    private func updateShiftArray() {
        
        if let waiter = waiter {
            shiftArray = Array(waiter.shifts)
            shiftArray.sort(by: { $0.date < $1.date })
        }
    }
    
    // MARK: - TableView Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "shiftCell", for: indexPath) as? ShiftTableViewCell else {
            fatalError("The dequeued cell is not an instance of ShiftTableViewCell.")
        }
            let shift = shiftArray[indexPath.row]
            cell.shift = shift
            
            return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            managedObjectContext.delete(shiftArray[indexPath.row] as NSManagedObject)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(#line, error.localizedDescription)
            }
            
            tableView.beginUpdates()
            shiftArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAddShift" {
            if let addShiftVC = segue.destination as? AddShiftViewController {
                addShiftVC.waiter = waiter
            }
        }
        
    }
    
}
