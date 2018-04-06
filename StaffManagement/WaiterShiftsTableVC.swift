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
    
    var fetchedArray = [Shift]()
    var monthAndYearArray = [String]()
    var shiftsArray = [[Shift]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let waiter = waiter, let waiterName = waiter.name {
            self.title = "\(waiterName)'s Shifts"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        fetchAndCategorizeShifts()
        tableView.reloadData()
    }
    
    // MARK: - Private Functions
    
    private func fetchAndCategorizeShifts() {
       
        let fetchRequest = NSFetchRequest<Shift>(entityName: "Shift")
        let sortByDate = NSSortDescriptor(key: #keyPath(Shift.date), ascending: true)
        fetchRequest.sortDescriptors = [sortByDate]
        
        do {
            fetchedArray = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalError("Failed to fetch shifts: \(error)")
        }
        
        categorizeShifts()
    }
    
    private func categorizeShifts() {
        
        // remove all objects otherwise it'll continue to append to old array
        shiftsArray.removeAll()
        monthAndYearArray.removeAll()
        
        var arrayIndex = 0
        
        for shift in fetchedArray {
            
            let shiftMonthYear = dateFormatter(date: shift.date)
            
            if monthAndYearArray.contains(shiftMonthYear) {
                shiftsArray[arrayIndex].append(shift)
                
            } else {
                monthAndYearArray.append(shiftMonthYear)
                
                // should only run once when array is empty
                if shiftsArray.isEmpty {
                    shiftsArray.append([shift])
                    
                } else {
                    shiftsArray.append([shift])
                    arrayIndex += 1
                }
            }
        }
    }
    
    private func dateFormatter(date: Date) -> String {
        
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "MMMM yyyy"
        
        return dayDateFormatter.string(from: date)
    }
    
    // MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return monthAndYearArray[section]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return monthAndYearArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftsArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "shiftCell", for: indexPath) as? ShiftTableViewCell else {
            fatalError("The dequeued cell is not an instance of ShiftTableViewCell.")
        }
            let shift = shiftsArray[indexPath.section][indexPath.row]
            cell.shift = shift
            
            return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            managedObjectContext.delete(shiftsArray[indexPath.section][indexPath.row] as NSManagedObject)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(#line, error.localizedDescription)
            }
            
            tableView.beginUpdates()
            shiftsArray[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if shiftsArray[indexPath.section].isEmpty {
                monthAndYearArray.remove(at: indexPath.section)
                shiftsArray.remove(at: indexPath.section)
                tableView.deleteSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
            }
            
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
