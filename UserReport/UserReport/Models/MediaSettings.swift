//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/**
 * Model describing customer of sdk
 */
internal struct MediaSettings {
    
    /// Company id (use internal SDK)
    var companyId: String
    
    /// Appropriate tracking code
    var kitTcode: String?
    
    /// Rules after which the survey will be displayed on the screen
    var settings: UserReportSettings = UserReportSettings()
    
    var sections: Dictionary<String, String>?
    
    var hardcodedConsent: String?
}

/**
 * An extension to initialize an object through a dictionary
 */
extension MediaSettings: Serialization {
    
    // MARK: - Init
    
    init(dict: [String: Any?]) throws {
        guard let companyId = dict["companyId"] as? String else {
            throw URError.responseDataNotFoundKey("companyId")
        }
        self.companyId = companyId
        
        if let kitTcode = dict["kitTcode"] as? String {
            self.kitTcode = kitTcode
        }

        if let localQuarantineDays = dict["localQuarantineDays"] as? Int {
            self.settings.localQuarantineDays = localQuarantineDays
        }
        
        if let inviteAfterNSecondsInApp = dict["inviteAfterNSecondsInApp"] as? TimeInterval {
            self.settings.inviteAfterNSecondsInApp = inviteAfterNSecondsInApp
        }
        
        if let inviteAfterTotalScreensViewed = dict["inviteAfterTotalScreensViewed"] as? Int {
            self.settings.inviteAfterTotalScreensViewed = inviteAfterTotalScreensViewed
        }

        if let sessionScreensView = dict["sessionScreensView"] as? Int {
            self.settings.sessionScreensView = sessionScreensView
        }
        
        if let sessionNSecondsLength = dict["sessionNSecondsLength"] as? TimeInterval {
            self.settings.sessionNSecondsLength = sessionNSecondsLength
        }
        
        if let sections = dict["sections"] as? Dictionary<String, String> {
            self.sections = sections
        }
        
        if let hardcodedConsent = dict["hardcodedConsent"] as? String {
            self.hardcodedConsent = hardcodedConsent
        }
    }
    
}
