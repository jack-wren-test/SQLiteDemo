//
//  ViewController.swift
//  SQLiteDemo
//
//  Created by Jack Smith on 27/11/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    // MARK:- Properties
    
    let dbPath: String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return "\(path)/db.sqlite"
    }()
    var db: DatabaseService?
    let reuseID = "EmployeeCell"
    var employees = [Employee]()
    
    // MARK:- Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openDB()
        createTableIfNeeded()
        employees = db?.fetchAllEmployees() ?? []
        tableView.register(EmployeeCell.self, forCellReuseIdentifier: reuseID)
    }
    
    // MARK:- TableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID) as! EmployeeCell
        cell.employee = employees[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            db?.deleteEmployee(id: Int32(self.employees[indexPath.row].employeeID))
            self.employees.remove(at: indexPath.row)
            self.employees = (db?.fetchAllEmployees())!
            DispatchQueue.main.async {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
    // MARK:- Methods
    
    fileprivate func openDB() {
        do {
            db = try DatabaseService.open(path: dbPath)
            print("Successfully opened connection to database.")
        } catch DatabaseError.OpenDatabase(let message) {
            print("Unable to open database: \(message)")
        } catch {
            print("Unable to open database, unknown error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func createTableIfNeeded() {
        do {
            try db?.createTable(table: Employee.self)
        } catch {
            print(db!.errorMessage)
        }
    }
    
    fileprivate func addEmployee(employee: Employee) {
        do {
            try db?.insertEmployee(employee: employee)
        } catch {
            print(db!.errorMessage)
        }
    }
    
    fileprivate func presentAlert() {
        let alert = UIAlertController(title: "Action", message: "Add or Edit Your Employees", preferredStyle: .alert)
        alert.addAction(.init(title: "Add Employee Details", style: .default, handler: { (_) in
            let addEmployeeAlert = UIAlertController(title: "Add Employee", message: "", preferredStyle: .alert)
            addEmployeeAlert.addTextField { (tf) in
                tf.placeholder = "Name"
            }
            addEmployeeAlert.addTextField { (tf) in
                tf.placeholder = "Age"
            }
            addEmployeeAlert.addTextField { (tf) in
                tf.placeholder = "Department"
            }
            let action = UIAlertAction(title: "Submit", style: .default) { (_) in
                self.addEmployee(employee: Employee(name: addEmployeeAlert.textFields?.first?.text ?? "NoName", department: addEmployeeAlert.textFields?.last?.text ?? "None", age: Int32(addEmployeeAlert.textFields?[1].text ?? "0")!, id: Int32(self.employees.count+1)))
                addEmployeeAlert.dismiss(animated: true) {
                    self.employees = self.db?.fetchAllEmployees() ?? []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            addEmployeeAlert.addAction(action)
            alert.dismiss(animated: true) {
                self.navigationController?.present(addEmployeeAlert, animated: true)
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .default, handler: { (_) in
            alert.dismiss(animated: true)
        }))
        navigationController?.present(alert, animated: true)
    }
    
    // MARK:- IBActions
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        presentAlert()
    }
    

}

