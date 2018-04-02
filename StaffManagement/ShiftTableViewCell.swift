//
//  ShiftTableViewCell.swift
//  StaffManagement
//
//  Created by Aaron Chong on 3/31/18.
//  Copyright © 2018 Derek Harasen. All rights reserved.
//

import UIKit

class ShiftTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var shiftTimeLabel: UILabel!
    
    var shift: Shift! {
        
        didSet {
            self.configureCell()
        }
    }
    
    private func configureCell() {
        
        let day = dateFormatter(dateFormat: "dd", date: shift.date)
        let month = dateFormatter(dateFormat: "MMM", date: shift.date)
        
        let startTime = timeFormatter(time: shift.startTime)
        let endTime = timeFormatter(time: shift.endTime)
        
        dateLabel.text = day
        monthLabel.text = month
        shiftTimeLabel.text = "\(startTime) - \(endTime)"
    }
    
    private func dateFormatter(dateFormat: String, date: Date) -> String {
        
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = dateFormat
        
        return dayDateFormatter.string(from: date)
    }
    
    private func timeFormatter(time: Date) -> String {
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        return timeFormatter.string(from: time)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
