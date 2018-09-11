//
//  CallDirectoryHandler.swift
//  Cordova Call Directory
//
//  Created by Niklas Merz on 12.03.18.
//  Copyright © 2018 GEDYS IntraWare. All rights reserved.
//

import Foundation
import CallKit
import SQLite3

let GROUP = "group.__APP_IDENTIFIER__"


@available(iOS 11.0, *)
class CallDirectoryHandler: CXCallDirectoryProvider {
    let defaults = UserDefaults(suiteName: GROUP)
    var logEntries = [String]()
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        self.log("Begin request")
        
        // Check whether this is an "incremental" data request
        if context.isIncremental {
            if (self.defaults?.bool(forKey: "clearAll"))! {
                self.log("Delete all")
                context.removeAllIdentificationEntries();
                
                self.defaults?.set(false, forKey: "clearAll")
                self.defaults?.synchronize()
            } else {
                addOrRemoveIncrementalBlockingPhoneNumbers(to: context)
                addOrRemoveIncrementalIdentificationPhoneNumbers(to: context)
            }
        } else {
            addAllBlockingPhoneNumbers(to: context)
            addAllIdentificationPhoneNumbers(to: context)
        }
        
        self.flushLog()
        context.completeRequest()
    }
    
    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        //TODO
    }
    
    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        //TODO
    }
    
    //Helper function
    func handleNumbers(to context: CXCallDirectoryExtensionContext, mode: String) {
        var tableName: String = "CallDirectoryAdd"
        if(mode == "addAll") {
            tableName = "CallDirectory"
        } else if(mode == "delete") {
            tableName = "CallDirectoryDelete"
        }
        
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: GROUP) {
            let fileURL = directory.appendingPathComponent("CordovaCallDirectory.sqlite")
            var db: OpaquePointer?
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                self.log("error opening database")
            } else {
                self.log("Query \(tableName)")
                let queryStatementString = "SELECT * FROM \(tableName) ORDER BY CAST(number AS INTEGER);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                    while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                        autoreleasepool {
                            let queryResultCol0 = sqlite3_column_text(queryStatement, 0)
                            let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                            if queryResultCol0 != nil && queryResultCol1 != nil {
                                let numberString = String(cString: queryResultCol0!)
                                let number = Int64(numberString);
                                let label = String(cString: queryResultCol1!)
                                if number != nil {
                                    if(mode == "delete") {
                                        self.log("Delete \(number!)")
                                        context.removeIdentificationEntry(withPhoneNumber: number!)
                                    } else {
                                        self.log("Add \(numberString), \(number!)")
                                        context.addIdentificationEntry(withNextSequentialPhoneNumber: number!, label: label)
                                    }
                                } else {
                                    self.log("Invalid number, parse int failed: \(numberString)")
                                }
                            } else {
                                self.log("Row invalid")
                            }
                        }
                    }
                    sqlite3_finalize(queryStatement)
                    
                    //clear table
                    if (mode != "addAll") {
                        if sqlite3_exec(db, "DELETE FROM \(tableName)", nil, nil, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            self.log("error deleting from table \(errmsg)")
                        }
                    }
                } else {
                    self.log("SELECT statement could not be prepared")
                }
            }
        }
    }
    
    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        handleNumbers(to: context, mode: "addAll")
    }
    
    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        handleNumbers(to: context, mode: "delete")
        handleNumbers(to: context, mode: "add")
    }
    
    private func log(_ message: String) {
        self.logEntries.append(message)
        print(message)
    }
    
    private func flushLog() {
        self.defaults?.set(self.logEntries, forKey: "log")
        self.defaults?.synchronize()
    }
}

@available(iOS 11.0, *)
extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print(error.localizedDescription)
    }
    
}