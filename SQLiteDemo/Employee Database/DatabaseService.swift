//
//  Database.swift
//  SQLiteDemo
//
//  Created by Jack Smith on 29/11/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import SQLite3

enum DatabaseError: Error {
  case OpenDatabase(message: String)
  case Prepare(message: String)
  case Step(message: String)
  case Bind(message: String)
}

class DatabaseService {
    
    // MARK:- Properties
    
    private let dbPointer: OpaquePointer?
    
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    // MARK:- Init
    
    fileprivate init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    // MARK:- Deinit
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    // MARK:- Methods
    
    static func open(path: String) throws -> DatabaseService {
        var db: OpaquePointer? = nil
        if sqlite3_open(path, &db) == SQLITE_OK {
                return DatabaseService(dbPointer: db)
            } else {
                defer { if db != nil { sqlite3_close(db) }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw DatabaseError.OpenDatabase(message: message)
            } else {
                throw DatabaseError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

extension DatabaseService {
    
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw DatabaseError.Prepare(message: errorMessage)
        }
        return statement
    }
}

extension DatabaseService {
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createTableStatement)
        defer {
            sqlite3_finalize(createTableStatement)
        }
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
        throw DatabaseError.Step(message: errorMessage)
        }
        print("\(table) table created.")
    }
}

extension DatabaseService {
    func insertEmployee(employee: Employee) throws {
        let insertSql = "INSERT INTO Employees (Id, Name, Age, Department) VALUES (?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer { sqlite3_finalize(insertStatement) }
        let name: NSString = employee.name
        guard sqlite3_bind_int(insertStatement, 1, employee.employeeID) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 3, employee.age) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 4, employee.department.utf8String, -1, nil) == SQLITE_OK else {
            throw DatabaseError.Bind(message: errorMessage)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
          throw DatabaseError.Step(message: errorMessage)
        }
        print("Successfully inserted row.")
    }

}

extension DatabaseService {
    
    func fetchAllEmployees() -> [Employee]? {
        let querySql = "SELECT * FROM Employees"
        guard let queryStatement = try? prepareStatement(sql: querySql) else { return nil }
        defer { sqlite3_finalize(queryStatement) }
        var employees : [Employee] = []
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            employees.append(employeeFromQuery(queryStatement))
        }
        return employees
    }
    
    func fetchEmployee(id: Int32) -> Employee? {
        let querySql = "SELECT * FROM Employees WHERE Id = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else { return nil }
        defer { sqlite3_finalize(queryStatement) }
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else { return nil }
        guard sqlite3_step(queryStatement) == SQLITE_ROW else { return nil }
        return employeeFromQuery(queryStatement)
    }
    
    fileprivate func employeeFromQuery(_ queryStatement: OpaquePointer) -> Employee {
        let id = sqlite3_column_int(queryStatement, 0)
        let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
        let name = String(cString: queryResultCol1!)
        let age = sqlite3_column_int(queryStatement, 2)
        let queryResultCol2 = sqlite3_column_text(queryStatement, 3)
        let department = String(cString: queryResultCol2!)
        return Employee(name: name, department: department, age: age, id: id)
    }
    
}

extension DatabaseService {
    
    func deleteEmployee(id: Int32) {
        let querySql = "DELETE FROM Employees WHERE Id = ?";
        guard let queryStatement = try? prepareStatement(sql: querySql) else { return }
        defer { sqlite3_finalize(queryStatement) }
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else { return }
        guard sqlite3_step(queryStatement) == SQLITE_ROW else { return }
    }
}
