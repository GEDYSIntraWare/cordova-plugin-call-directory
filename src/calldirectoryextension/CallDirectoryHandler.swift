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

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        // Check whether this is an "incremental" data request
        if context.isIncremental {
            let defaults = UserDefaults(suiteName: "group.__APP_IDENTIFIER__")
            if (defaults?.bool(forKey: "clearAll"))! {
                print("Delete all")
                context.removeAllIdentificationEntries();
                
                defaults?.set(false, forKey: "clearAll")
                defaults?.synchronize()
            } else {
                addOrRemoveIncrementalBlockingPhoneNumbers(to: context)
                addOrRemoveIncrementalIdentificationPhoneNumbers(to: context)
            }
        } else {
            addAllBlockingPhoneNumbers(to: context)
            addAllIdentificationPhoneNumbers(to: context)
        }
        
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
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.__APP_IDENTIFIER__") {
            let fileURL = directory.appendingPathComponent("CordovaCallDirectory.sqlite")
            var db: OpaquePointer?
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            } else {
                print("Query \(tableName)")
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
                                print("Query Result:")
                                print("\(numberString) | \(label)")
                                if number != nil {
                                    if(mode == "delete") {
                                        context.removeIdentificationEntry(withPhoneNumber: number!)
                                    } else {
                                        print("Add from", tableName, numberString, number!)
                                        context.addIdentificationEntry(withNextSequentialPhoneNumber: number!, label: label)
                                    }
                                } else {
                                    print("Invalid number")
                                }
                            } else {
                                print("Row invalid")
                            }
                        }
                    }
                    sqlite3_finalize(queryStatement)
                    
                    //clear table
                    if (mode != "addAll") {
                        if sqlite3_exec(db, "DELETE FROM \(tableName)", nil, nil, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("error deleting from table \(errmsg)")
                        }
                    }
                } else {
                    print("SELECT statement could not be prepared")
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
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print(error.localizedDescription)
    }
    
}