//
//  Employee.swift
//  SQLiteDemo
//
//  Created by Jack Smith on 28/11/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation

protocol SQLTable {
  static var createTableStatement: String { get }
}

class Employee {
    
    // MARK:- Properties
    
    static var employeeIDPool: Int32 = 1
    
    var employeeID: Int32!
    var name: NSString
    var department: NSString
    var age: Int32
    
    // MARK:- Init
    
    init(name: String, department: String, age: Int32, id: Int32?) {
        self.name = name as NSString
        self.department = department as NSString
        self.age = age
        if let employeeID = id {
            self.employeeID = employeeID
        } else {
            setID(employeeID: Employee.employeeIDPool)
            Employee.employeeIDPool++
        }
    }
    
    // MARK:- Methods:
    
    func printDescription() {
        print("| \(self.employeeID!) | \(self.name) | \(self.age) | \(self.department) |")
    }
    
    func returnDict() -> [String: Any] {
        let dict : [String: Any] = [
            "Id": employeeID!,
            "Name": name,
            "Age": age,
            "Department": department
            ]
        return dict
    }
    
    fileprivate func setID(employeeID: Int32){
        self.employeeID = employeeID
    }
    
}

extension Employee: SQLTable {
    static var createTableStatement: String {
        return """
        CREATE TABLE Employees(
        Id INTEGER PRIMARY KEY NOT NULL,
        Name CHAR(255),
        Age INTEGER,
        Department CHAR(255)
        );
        """
    }
}
