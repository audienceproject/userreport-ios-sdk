//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/**
 * Class for saving and reading data to a file in documents.
 */
internal class Store {
    
    /// The name of the keys on which the data is stored in the dictionary `data`
    private struct Keys {
        static let totalScreenView = "total_screen_view"
        static let totalSecondsInApp = "total_seconds_in_app"
        static let localQuarantineDate = "local_quarantine_date"
    }
    
    // MARK: Values
    
    var totalScreenView: Int {
        get {
            data?[Keys.totalScreenView] as? Int ?? 0
        }
        set {
            data?[Keys.totalScreenView] = newValue
            save()
        }
    }
    
    var totalSecondsInApp: TimeInterval {
        get {
            data?[Keys.totalSecondsInApp] as? TimeInterval ?? 0
        }
        set {
            data?[Keys.totalSecondsInApp] = newValue
            save()
        }
    }
    
    var localQuarantineDate: Date {
        get {
            data?[Keys.localQuarantineDate] as! Date
        }
        set {
            data?[Keys.localQuarantineDate] = newValue
            save()
        }
    }
    
    /// Name of the file stored in documents
    private static let fileName = "userreport_store.plist"
    
    /// A dictionary that is saved to a file after any changes
    private var data: [String: Any]? {
        didSet {
            self.save()
        }
    }
    
    // MARK: Init
    
    init() {
        self.load()
        if self.data?[Keys.localQuarantineDate] == nil {
            self.data?[Keys.localQuarantineDate] = Date()
            self.save()
        }
    }
    
    // MARK: Methods
    
    /// Load data from file in documents
    private func load() {
        if let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let path = paths + "/\(Store.fileName)"
            self.data = NSDictionary(contentsOfFile: path) as? [String: Any] ?? [:]
        }
    }
    
    /// Save data to file in documents
    private func save() {
        if let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let path = paths + "/\(Store.fileName)"
            if let data = self.data as NSDictionary? {
                data.write(toFile: path, atomically: true)
            }
        }
    }
    
}
