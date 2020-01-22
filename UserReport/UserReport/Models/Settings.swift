//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit

/**
 * A set of rules after which the survey will be displayed on the screen
 */
public class Settings: NSObject {
    
    private var _localQuarantineDays : Int?
    
    /// Number of days through which the survey will be appear again
    @objc public var localQuarantineDays: Int {
        get {
            return _localQuarantineDays ?? Settings.defaultInstance?._localQuarantineDays ?? 7
        }
        set {
            _localQuarantineDays = newValue
        }
    }

    private var _inviteAfterNSecondsInApp : TimeInterval?
    
    /// Number of seconds need to spent in the application for all time
    @objc public var inviteAfterNSecondsInApp: TimeInterval {
        get {
            return _inviteAfterNSecondsInApp ?? Settings.defaultInstance?._inviteAfterNSecondsInApp ?? 60
        }
        set {
            _inviteAfterNSecondsInApp = newValue
        }
    }
    
    private var _inviteAfterTotalScreensViewed : Int?
    
    /// Number of screens need to view at in all session
    @objc public var inviteAfterTotalScreensViewed: Int {
        get {
            return _inviteAfterTotalScreensViewed ?? Settings.defaultInstance?._inviteAfterTotalScreensViewed ?? 5
        }
        set {
            _inviteAfterTotalScreensViewed = newValue
        }
    }
    
    private var _sessionScreensView : Int?
    
    /// Number of screens need to view at in current session
    @objc public var sessionScreensView: Int {
        get {
            return _sessionScreensView ?? Settings.defaultInstance?._sessionScreensView ?? 3
        }
        set {
            _sessionScreensView = newValue
        }
    }
    
    private var _sessionNSecondsLength : TimeInterval?
    
    /// Number of seconds need to spent in the application for current session
    @objc public var sessionNSecondsLength: TimeInterval {
        get {
            return _sessionNSecondsLength ?? Settings.defaultInstance?._sessionNSecondsLength as TimeInterval? ?? 3
        }
        set {
            _sessionNSecondsLength = newValue
        }
    }
    
    /// Settings that came from the server
    internal static var defaultInstance: Settings?

}
