//
//  EmployeeCell.swift
//  SQLiteDemo
//
//  Created by Jack Smith on 29/11/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class EmployeeCell: UITableViewCell {
    
    // MARK:- Outlets
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    
    // MARK:- Properties
    
    var employee : Employee?
    
    // MARK:- AwakeFromNib

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK:- Methods
    
    private func configureCell() {
        guard let employee = self.employee else {return}
        self.idLabel.text = "\(employee.employeeID ?? 0)"
        self.nameLabel.text = employee.name as String?
        self.ageLabel.text = "\(employee.age)"
        self.departmentLabel.text = employee.department as String?
    }

}
