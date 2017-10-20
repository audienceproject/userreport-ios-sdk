//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit

/**
 * A set of rules after which the survey will be displayed on the screen
 */
public class Settings: NSObject {
    
    /// Number of days through which the survey will be appear again
    public var localQuarantineDays: Int = -1
    
    /// Number of seconds need to spent in the application for all time
    public var inviteAfterNSecondsInApp: TimeInterval = -1
    
    /// Number of screens need to view at in all session
    public var inviteAfterTotalScreensViewed: Int = -1
    
    /// Number of screens need to view at in current session
    public var sessionScreensView: Int = -1
    
    /// Number of seconds need to spent in the application for current session
    public var sessionNSecondsLength: TimeInterval = -1
    
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
