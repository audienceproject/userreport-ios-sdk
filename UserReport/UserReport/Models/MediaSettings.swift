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
    var settings: Settings = Settings()
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
        
        guard let kitTcode = dict["kitTcode"] as? String else {
            throw URError.responseDataNotFoundKey("kitTcode")
        }
        self.kitTcode = kitTcode
        
        guard let localQuarantineDays = dict["localQuarantineDays"] as? Int else {
            throw URError.responseDataNotFoundKey("localQuarantineDays")
        }
        self.settings.localQuarantineDays = localQuarantineDays
        
        guard let inviteAfterNSecondsInApp = dict["inviteAfterNSecondsInApp"] as? TimeInterval else {
            throw URError.responseDataNotFoundKey("inviteAfterNSecondsInApp")
        }
        self.settings.inviteAfterNSecondsInApp = inviteAfterNSecondsInApp
        
        guard let inviteAfterTotalScreensViewed = dict["inviteAfterTotalScreensViewed"] as? Int else {
            throw URError.responseDataNotFoundKey("inviteAfterTotalScreensViewed")
        }
        self.settings.inviteAfterTotalScreensViewed = inviteAfterTotalScreensViewed
        
        guard let sessionScreensView = dict["sessionScreensView"] as? Int else {
            throw URError.responseDataNotFoundKey("sessionScreensView")
        }
        self.settings.sessionScreensView = sessionScreensView
        
        guard let sessionNSecondsLength = dict["sessionNSecondsLength"] as? TimeInterval else {
            throw URError.responseDataNotFoundKey("sessionNSecondsLength")
        }
        self.settings.sessionNSecondsLength = sessionNSecondsLength
    }
    
}
