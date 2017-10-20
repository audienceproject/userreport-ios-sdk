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
    
    static var totalScreenView: Int {
        get {
            return self.shared.data?[Keys.totalScreenView] as? Int ?? 0
        }
        set {
            self.shared.data?[Keys.totalScreenView] = newValue
            self.shared.save()
        }
    }
    
    static var totalSecondsInApp: TimeInterval {
        get {
            return self.shared.data?[Keys.totalSecondsInApp] as? TimeInterval ?? 0
        }
        set {
            self.shared.data?[Keys.totalSecondsInApp] = newValue
            self.shared.save()
        }
    }
    
    static var localQuarantineDate: Date {
        get {
            return self.shared.data?[Keys.localQuarantineDate] as! Date
        }
        set {
            self.shared.data?[Keys.localQuarantineDate] = newValue
            self.shared.save()
        }
    }
    
    /// Singleton instance
    private static let shared = Store()
    
    /// Name of the file stored in documents
    private static let fileName = "userreport_store.plist"
    
    /// A dictionary that is saved to a file after any changes
    private var data: [String: Any]? {
        didSet {
            self.save()
        }
    }
    
    // MARK: Init
    
    private init() {
        self.load()
        if self.data?[Keys.localQuarantineDate] == nil {
            self.data?[Keys.localQuarantineDate] = Date()
            self.save()
        }
    }
    
    // MARK: Methods
    
    /// Load data from file in documents
    private func load() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = paths + "/\(Store.fileName)"
        self.data = NSDictionary(contentsOfFile: path) as? [String: Any] ?? [:]
    }
    
    /// Save data to file in documents
    private func save() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = paths + "/\(Store.fileName)"
        if let data = self.data as NSDictionary? {
            data.write(toFile: path, atomically: true)
        }
    }
    
}
