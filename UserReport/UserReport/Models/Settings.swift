//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit

/**
 * A set of rules after which the survey will be displayed on the screen
 */
public class Settings: NSObject {
    
    /// Number of days through which the survey will be appear again
    @objc public var localQuarantineDays: Int = 7
    
    /// Number of seconds need to spent in the application for all time
    @objc public var inviteAfterNSecondsInApp: TimeInterval = 60
    
    /// Number of screens need to view at in all session
    @objc public var inviteAfterTotalScreensViewed: Int = 5
    
    /// Number of screens need to view at in current session
    @objc public var sessionScreensView: Int = 3
    
    /// Number of seconds need to spent in the application for current session
    @objc public var sessionNSecondsLength: TimeInterval = 3
    
    /// Settings that came from the server
    internal static var defaultInstance: Settings?
    
    // MARK: Init
    
    public override init() {
        super.init()
        if let defaultInstance = Settings.defaultInstance {
            self.localQuarantineDays = defaultInstance.localQuarantineDays
            self.inviteAfterNSecondsInApp = defaultInstance.inviteAfterNSecondsInApp
            self.inviteAfterTotalScreensViewed = defaultInstance.inviteAfterTotalScreensViewed
            self.sessionScreensView = defaultInstance.sessionScreensView
            self.sessionNSecondsLength = defaultInstance.sessionNSecondsLength
        }
    }
}
