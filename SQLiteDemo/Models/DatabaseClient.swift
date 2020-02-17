//
//  DatabaseInterface.swift
//  SQLiteDemo
//
//  Created by Jack Smith on 27/11/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import SQLite3

class DatabaseClient {
    
    // MARK:- Properties
    
    // Database Handle - manages database schema and file
    var dbHandle: OpaquePointer? = nil
    var result: Int32?
    
    // MARK:- Init
    
    init(databasePath: String) {
        openDatabase(databasePath)
    }
    
    // MARK:- Deinit
    
    deinit {
        result = sqlite3_close(dbHandle)
    }
    
    // MARK:- Methods
    
    fileprivate func openDatabase(_ databasePath: String) {
        if sqlite3_open(databasePath+"db.sqlite", &dbHandle) == SQLITE_OK {
            print("Successfully opened connection to database at \(databasePath)")
        } else {
            print("Unable to open database")
        }
    }
    
    func createTable(tableString: String) {
        var createTableStatement: OpaquePointer? = nil //Pointer to our statement
        defer { sqlite3_finalize(createTableStatement) }
        if sqlite3_prepare_v2(dbHandle, tableString, -1, &createTableStatement, nil) == SQLITE_OK { // Prepare the statement
            if sqlite3_step(createTableStatement) == SQLITE_DONE { // Run the compiled statement
                print("Contact table created.")
            } else {
                print("Contact table could not be created.")
            }
        } else {
            let errorMessage = String.init(cString: sqlite3_errmsg(dbHandle))
            print("CREATE TABLE statement could not be prepared: \(errorMessage)")
        }
    }
    
    func addToDB(table: String, values: [String: Any]) {
        let keys = values.keys
        let keysString = toSQLColumnHeaders(arrayOfStrings: Array(keys))
        let insertStatementString = "INSERT INTO \(table) \(keysString) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil // Pointer to our statement
        defer { sqlite3_finalize(insertStatement) }
        if sqlite3_prepare_v2(dbHandle, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK { // Prepare the statement
                let age: Int32 = values["Age"] as! Int32
                let department: NSString = "\(values["Department"] ?? "")" as NSString
                let name: NSString = "\(values["Name"] ?? "")" as NSString
                let id: Int32 = values["Id"] as! Int32

                sqlite3_bind_int(insertStatement, 1, age)
                sqlite3_bind_text(insertStatement, 2, department.utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 3, id)
                sqlite3_bind_text(insertStatement, 4, name.utf8String, -1, nil)

                if sqlite3_step(insertStatement) == SQLITE_DONE { // Run the compiled statement
                    print("Successfully inserted row.")
                } else {
                    print("Could not insert row.")
                }
            } else {
                let errorMessage = String.init(cString: sqlite3_errmsg(dbHandle))
                print("INSERT statement could not be prepared: \(errorMessage)")
            }
    }
    
    func queryDB(queryStatementString: String) {
        var queryStatement: OpaquePointer? = nil
        defer { sqlite3_finalize(queryStatement) }
        if sqlite3_prepare_v2(dbHandle, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            print("Query Result:")
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let age = sqlite3_column_int(queryStatement, 0)
                let department = String(cString: sqlite3_column_text(queryStatement, 1))
                let id = sqlite3_column_int(queryStatement, 2)
                let name = String(cString: sqlite3_column_text(queryStatement, 3))
                print(" \(id) | \(name) | \(age) | \(department)")
            }
        } else {
            let errorMessage = String.init(cString: sqlite3_errmsg(dbHandle))
            print("SELECT statement could not be prepared: \(errorMessage)")
        }
    }
    
    func updateById(table: String, Id: String, setColumn: String, toValue: String) {
        let updateStatementString = "UPDATE \(table) SET \(setColumn) = (?) WHERE Id = \(Id);"
        var updateStatement: OpaquePointer? = nil
        defer { sqlite3_finalize(updateStatement) }
        if sqlite3_prepare_v2(dbHandle, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            bindUpdateByIdInstructions(updateStatement, toValue)
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Successfully updated row.")
                } else {
                    print("Could not update row.")
                }
        } else {
            let errorMessage = String.init(cString: sqlite3_errmsg(dbHandle))
            print("UPDATE statement could not be prepared: \(errorMessage)")
        }
    }
    
    func deleteById(table: String, Id: String) {
        let deleteStatementStirng = "DELETE FROM \(table) WHERE Id = \(Id);"
        print(deleteStatementStirng)
        var deleteStatement: OpaquePointer? = nil
        defer { sqlite3_finalize(deleteStatement) }
        if sqlite3_prepare_v2(dbHandle, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            let errorMessage = String.init(cString: sqlite3_errmsg(dbHandle))
            print("DELETE statement could not be prepared: \(errorMessage)")
        }
    }
    
    fileprivate func toSQLColumnHeaders(arrayOfStrings: [String]) -> String {
        let sortedArray = arrayOfStrings.sorted()
        var stringOfHeaders = "("
        sortedArray.forEach { (header) in
            stringOfHeaders += "\(header), "
        }
        stringOfHeaders = String(String(stringOfHeaders.dropLast()).dropLast())
        stringOfHeaders += ")"
        return stringOfHeaders
    }
    
    fileprivate func bindUpdateByIdInstructions(_ updateStatement: OpaquePointer?, _ value: String?) {
        if let value = Int(value!)  {
            let setValue = Int32(value)
            sqlite3_bind_int(updateStatement, 1, setValue)
        } else {
            let setValue = "\(value ?? "")" as NSString
            sqlite3_bind_text(updateStatement, 1, setValue.utf8String, -1, nil)
        }
    }
    
    func closeDb() {
        sqlite3_close(dbHandle)
    }

}
