import CallKit
import SQLite3

@available(iOS 10.0, *)
@objc(CallDirectory) class CallDirectory : CDVPlugin {

    func isAvailable(_ command: CDVInvokedUrlCommand){
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: "__APP_IDENTIFIER__.__BUNDLE_SUFFIX__", completionHandler: { (status:CXCallDirectoryManager.EnabledStatus, e:Error?) -> Void in
            
            if e != nil {
                print(e ?? "Error")
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: e.debugDescription);
                self.commandDelegate.send(pluginResult, callbackId:command.callbackId);
            } else if (status == CXCallDirectoryManager.EnabledStatus.enabled) {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true);
                self.commandDelegate.send(pluginResult, callbackId:command.callbackId);
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: false);
                self.commandDelegate.send(pluginResult, callbackId:command.callbackId);
            }
        })
    }
    
    func addIdentification(_ command: CDVInvokedUrlCommand){
        let data  = command.arguments[0] as! [Any];
        addToTable(mode: "add", data: data)
        
        print("Done adding numbers to CallDirectoryAdd")
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Numbers added to queue");
        self.commandDelegate.send(pluginResult, callbackId:command.callbackId);
    }
    
    func removeIdentification(_ command: CDVInvokedUrlCommand){
        let data  = command.arguments[0] as! [Any];
        addToTable(mode: "delete", data: data)
        
        print("Done adding numbers to CallDirectoryDelete")
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Numbers added to queue");
        self.commandDelegate.send(pluginResult, callbackId:command.callbackId);
    }
    
    func removeAllIdentification(_ command: CDVInvokedUrlCommand){
        let data  = [["label": "##REMOVEALL##", "number": "000000"]];
        addToTable(mode: "clearAll", data: data)
        
        reloadExtension(command)
    }
    
    //Helper function
    func addToTable(mode: String, data: [Any]) {
        
        var tableName = ""
        switch mode {
        case "add":
            tableName = "CallDirectoryAdd"
        case "delete":
            tableName = "CallDirectoryDelete"
        case "clear":
            tableName = "CallDirectoryAdd"
        case "clearAll":
            tableName = "CallDirectoryAdd"
        default:
            tableName = "CallDirectory"
        }
        
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.__APP_IDENTIFIER__") {
            let fileURL = directory.appendingPathComponent("CordovaCallDirectory.sqlite")
            var db: OpaquePointer?
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }

            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS \(tableName) (number TEXT PRIMARY KEY, label TEXT)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            
            //creating a statement
            var stmt: OpaquePointer?
            
            //the replace query
            var queryString = "REPLACE INTO \(tableName) (number, label) VALUES (?,?)"
            if mode == "deleteAll" {
                queryString = "DELETE FROM \(tableName) WHERE number = ?"
            } else if mode == "clearAll" {
                queryString = "DELETE FROM \(tableName)"
            }
            
            //preparing the query
            if sqlite3_exec(db, "BEGIN EXCLUSIVE TRANSACTION", nil, nil, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error begin transaction: \(errmsg)")
            }
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            for item in data {
                let entry = item as? [String: Any];
                
                //binding the parameters
                if mode == "deleteAll" {
                    if sqlite3_bind_text(stmt, 1, (entry!["number"] as! NSString).utf8String, -1, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding where: \(errmsg)")
                        continue
                    }
                } else if mode != "clearAll" {
                    if sqlite3_bind_text(stmt, 1, (entry!["number"] as! NSString).utf8String, -1, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding number: \(errmsg)")
                        continue
                    }
                    
                    if sqlite3_bind_text(stmt, 2, (entry!["label"] as! NSString).utf8String, -1, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding label: \(errmsg)")
                        continue
                    }
                }
                
                //executing the query
                if  sqlite3_step(stmt) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("statement failed: \(errmsg)")
                    continue
                }
                sqlite3_reset(stmt);
            }
            
            if  sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("commit failed: \(errmsg)")
            }
            print("PhoneNumbers processed in \(tableName)")
            sqlite3_finalize(stmt)
            sqlite3_close(db);
            db = nil
            
            //Repeat for all table
            if mode.range(of:"All") == nil {
                addToTable(mode: mode + "All", data: data)
            }
        }
    }
    
    func reloadExtension(_ command: CDVInvokedUrlCommand) {
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "__APP_IDENTIFIER__.__BUNDLE_SUFFIX__", completionHandler: { (error) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription);
                self.commandDelegate.send(pluginResult, callbackId:command.callbackId);
            } else {
                print("Refresh/Delete success")
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Done");
                self.commandDelegate.send(pluginResult, callbackId:command.callbackId);
            }
        })
    }
    
    override func pluginInitialize() {
        super.pluginInitialize()
    }
}