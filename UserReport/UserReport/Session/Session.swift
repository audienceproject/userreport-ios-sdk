//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation
import UIKit

/**
 *   Class stores the data on the count of screens viewed and the time the application is used
 */
public class Session: NSObject {
    
    // MARK: Typealias
    
    internal typealias SessionRulesPassedHandler = () -> Void
    
    // MARK: Properties
    
    /// A closure executed when all rules pass
    internal var rulesPassed: SessionRulesPassedHandler?
    
    /// Number of seconds spent in the application for current session
    @objc public private(set) var sessionSeconds: TimeInterval = 0
    
    /// Settings used for the current session
    @objc public private(set) var settings: UserReportSettings?
    
    /// Number of screen viewed in current session
    @objc public private(set) var screenView: Int = 0
    
    /// Number of screen viewed in all session
    @objc public private(set) var totalScreenView: Int {
        get {
            localStore.totalScreenView
        }
        set {
            localStore.totalScreenView = newValue
        }
    }

    /// Number of seconds spent in the application for all time
    @objc public private(set) var totalSecondsInApp: TimeInterval {
        get {
            localStore.totalSecondsInApp
        }
        set {
            localStore.totalSecondsInApp = newValue
        }
    }

    /// Date when the survey will be appear again
    @objc public internal(set) var localQuarantineDate: Date {
        get {
            localStore.localQuarantineDate
        }
        set {
             localStore.localQuarantineDate = newValue
        }
    }
    
    /// Date when was last tracked screen view
    internal var lastViewScreenDate: Date?
    
    /// Date when the parameters `sessionSeconds` and `totalSecondsInApp` were last updated
    private var lastStoreDate: Date?
    
    /// Step in seconds for update `sessionSeconds` and `totalSecondsInApp`
    private static let sessionUpdateInterval: TimeInterval = 1
    
    /// The timer with which the parameters `sessionSeconds` and `totalSecondsInApp` will be updated
    private var sessionUpdateTimer: Timer?
    
    /// Store used for the store current session
    private var localStore: Store!
    
    // MARK: Init
    
    /**
     * Creates an instance with the specified object `settings` (options) and closure `rulesPassed`.
     *
     * - parameter settings:    Settings used for the current session
     * - parameter store:    Store used for the store current session
     * - parameter rulesPassed: A closure executed when all rules pass
     *
     * - returns: The new `Session` instance.
     */
    internal convenience init(settings: UserReportSettings? = nil, store: Store, rulesPassed: @escaping SessionRulesPassedHandler) {
        self.init()
        
        // DI
        self.settings = settings
        self.rulesPassed = rulesPassed
        self.localStore = store

        self.startTimer()
        
        // Observe UIApplication enter background/foreground
        NotificationCenter.default.addObserver(self, selector: #selector(self.startTimer), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // MARK: de-init
    
    /// Stop timers and unsubscribe for notifications
    deinit {
        self.stopTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Methods
    
    /**
     * Tracking screen view
     */
    internal func updateScreenViewed() {
        self.screenView += 1
        self.totalScreenView += 1
        self.lastViewScreenDate = Date()
    }
    
    /**
     * Set new settings.
     */
    internal func updateSettings(_ settings: UserReportSettings) {
        self.settings = settings
        self.validate()
    }
    
    // MARK: Session time
    
    /**
     * Updates of session time and total time in the application
     */
    @objc private func updateSessionInterval() {
        if let lastStoreDate = self.lastStoreDate {
            let diff = Swift.abs(lastStoreDate.timeIntervalSinceNow)
            self.sessionSeconds += diff
            self.totalSecondsInApp += diff
        }
        self.lastStoreDate = Date()
        self.validate()
    }
    
    // MARK: Timers
    
    /**
     * Start `sessionUpdateTimer` timer
     */
    @objc private func startTimer() {
        self.lastStoreDate = Date()
        self.sessionUpdateTimer = Timer.scheduledTimer(timeInterval: Session.sessionUpdateInterval, target: self, selector: #selector(updateSessionInterval), userInfo: nil, repeats: true)
    }
    
    /**
     * Stop `sessionUpdateTimer` timer
     */
    @objc private func stopTimer() {
        self.sessionUpdateTimer?.invalidate()
        self.sessionUpdateTimer = nil
        
        self.updateSessionInterval()
        self.lastStoreDate = nil
    }
    
    // MARK: Validation
    
    /**
     * Comparing session info and settings.
     * If all the rules are pass then closure `rulesPassed` executed.
     */
    private func validate() {
        guard let settings = self.settings else { return }
        guard self.screenView >= settings.sessionScreensView else { return }
        guard self.totalScreenView >= settings.inviteAfterTotalScreensViewed else { return }
        guard self.sessionSeconds >= settings.sessionNSecondsLength else { return }
        guard self.totalSecondsInApp >= settings.inviteAfterNSecondsInApp else { return }
        guard Date() >= localStore.localQuarantineDate  else { return }
        
        self.rulesPassed?()
    }
}
