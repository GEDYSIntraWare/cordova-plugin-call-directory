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
let TABLENAME = "CallDirectoryNumbers"


@available(iOS 11.0, *)
class CallDirectoryHandler: CXCallDirectoryProvider {
    let defaults = UserDefaults(suiteName: GROUP)
    var logEntries = [String]()
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        self.log("Begin request")
        self.defaults?.synchronize()
        
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
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: GROUP) {
            let fileURL = directory.appendingPathComponent("CordovaCallDirectory.sqlite")
            var db: OpaquePointer?
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                self.log("error opening database")
            } else {
                let lastRun = self.defaults?.double(forKey: "lastRun") ?? 0;
                let currentTime = Date().timeIntervalSince1970
                // Sort by remove to delete first and add numbers again after for update
                var queryStatementString = "SELECT * FROM \(TABLENAME) WHERE (updated > ? OR added > ?) ORDER BY CAST(number AS INTEGER), remove DESC"
                if mode == "addAll" {
                    queryStatementString = "SELECT * FROM \(TABLENAME) ORDER BY CAST(number AS INTEGER)"
                }
                
                
                var queryStatement: OpaquePointer? = nil
                self.log("Query \(queryStatementString)")
                var count = 0;
                if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                    if mode != "addAll" {
                        if sqlite3_bind_double(queryStatement, 1, lastRun) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            self.log("failure binding where: \(errmsg)")
                        }
                        
                        if sqlite3_bind_double(queryStatement, 2, lastRun) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            self.log("failure binding where: \(errmsg)")
                        }
                    }
                    
                    while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                        autoreleasepool {
                            let queryResultCol0 = sqlite3_column_text(queryStatement, 0)
                            let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                            // Updated let queryResultCol3 = sqlite3_column_double(queryStatement, 3)
                            let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
                            if queryResultCol0 != nil && queryResultCol1 != nil {
                                let numberString = String(cString: queryResultCol0!)
                                let number = Int64(numberString);
                                let label = String(cString: queryResultCol1!)
                                var delete = false;
                                if queryResultCol4 != nil {
                                    delete = String(cString: queryResultCol4!) == "true"
                                }
                                if number != nil {
                                    if delete {
                                        self.log("Delete \(numberString)")
                                        context.removeIdentificationEntry(withPhoneNumber: number!)
                                    } else {
                                        context.addIdentificationEntry(withNextSequentialPhoneNumber: number!, label: label)
                                    }
                                } else {
                                    self.log("Invalid number, parse int failed: \(numberString)")
                                }
                                
                                count += 1
                            } else {
                                self.log("Row invalid")
                            }
                        }
                    }
                    sqlite3_finalize(queryStatement)
                    self.log("Processed \(count) in \(TABLENAME)");
                    
                    //Set updated
                    var stmt: OpaquePointer?
                    var queryString = "UPDATE \(TABLENAME) SET updated = ? WHERE (updated > ? OR added > ?)"
                    if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        self.log("error preparing update: \(errmsg)")
                        return
                    }
                    
                    if sqlite3_bind_double(stmt, 1, currentTime) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        self.log("failure binding added timestamp: \(errmsg)")
                    }
                    
                    if sqlite3_bind_double(stmt, 2, lastRun) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        self.log("failure binding added timestamp: \(errmsg)")
                    }
                    
                    if sqlite3_bind_double(stmt, 3, lastRun) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        self.log("failure binding added timestamp: \(errmsg)")
                    }
                    
                    if  sqlite3_step(stmt) != SQLITE_DONE {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        self.log("statement failed: \(errmsg)")
                    }
                    sqlite3_reset(stmt);
                    self.log("Timestamp updated to \(currentTime)")
                    
                    self.defaults?.set(currentTime, forKey: "lastRun")
                    self.defaults?.synchronize()
                    
                    // Remove deleted
                    queryString = "DELETE FROM \(TABLENAME) WHERE remove = 'true';"
                    if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        self.log("error deleting from table \(errmsg)")
                    }
                    
                    if  sqlite3_step(stmt) != SQLITE_DONE {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        self.log("statement failed: \(errmsg)")
                    }
                    
                    sqlite3_finalize(stmt)
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    self.log("SELECT statement could not be prepared: \(errmsg)")
                }
            }
        }
    }
    
    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        handleNumbers(to: context, mode: "addAll")
    }
    
    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        handleNumbers(to: context, mode: "update")
    }
    
    private func log(_ message: String) {
        self.logEntries.append(message)
        print(message)
    }
    
    private func flushLog() {
        print(self.logEntries.count)
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