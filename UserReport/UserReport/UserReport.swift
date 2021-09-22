//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation
import UIKit

/// Display style of the survey view on the screen
@objc public enum DisplayMode: Int {
    
    /// Show survey in full screen mode, like the modal view controller
    case fullscreen
    
    /// Show survey like an alert view (Default)
    case alert
}

/// Singleton instance
private var sharedInstance: UserReport?

@objc public class UserReport: NSObject {
    
    private enum SurveyStatus {
        
        /// Survey is not displayed on the screen
        case none
        
        /// Request information about survey from the server
        case requestInvite
        
        /// Try to download the page of survey
        case loadingInvitation
        
        /// Survey is displayed on the screen
        case surveyShown
    }
    
    //==========================================================================================================
    // MARK: - Properties -
    //==========================================================================================================
    
    // MARK: public
    
    ///  Get the shared UserReport instance
    @objc public class var shared: UserReport? {
        return sharedInstance
    }
    
    /// Current version of UserReport iOS SDK
    public static let sdkVersion = Bundle(for: UserReport.self).infoDictionary?["CFBundleShortVersionString"] as! String
    
    /// Survey view display style. Default `.alert`
    @objc public class func setDisplayMode(_ displayMode : DisplayMode) {
        UserReport.shared?.displayMode = displayMode
    }
    @objc public private(set) var displayMode: DisplayMode = .alert
    
    /// If user should be tracked anonymously
    @objc public class func setAnonymousTracking(_ anonymousTracking: Bool) {
        UserReport.shared?.anonymousTracking = anonymousTracking
    }
    @objc public private(set) var anonymousTracking: Bool = false
    
    /// Level of messages printing to the console. Default `.debug`
    public class var logLevel: LogLevel {
        set { UserReport.shared?.logger.level = newValue }
        get { return UserReport.shared?.logger.level ?? .debug }
    }
    
    /**
     * Flag for testing the display of the survey view.
     * The server will return data about the survey each time, otherwise they will set up the default settings.
     * Default `false`
     */
    @objc public class var testMode: Bool {
        set {
            UserReport.shared?.network.testMode = newValue
            UserReport.shared?.logger.log("Test mode: \(newValue ? "On" : "Off")", level: .debug)
        }
        get { return UserReport.shared?.testMode ?? false }
    }
    @objc private var testMode: Bool = false
    
    /**
     * Mute display of the survey.
     * In order for the survey not to be appear on important screens.
     * Default `false`
     *
     * - Note: Don't forget to return back to `false`
     */
    @objc public class var mute: Bool {
        set { UserReport.shared?.mute = newValue }
        get { return UserReport.shared?.mute ?? false }
    }
    @objc private var mute: Bool = false
    
    /// Returns whether the survey is displayed on the screen
    @objc public class var isSurveyShown: Bool {
        get { return UserReport.shared?.surveyStatus == .surveyShown }
    }
    
    /// Session data about count of screens viewed and the time the application is used
    @objc public class var session: Session? {
        set { UserReport.shared?.session = newValue }
        get { return UserReport.shared?.session }
    }
    @objc private var session: Session!
    
    // MARK: private
    private var logger: Logger!
    private var info: Info!
    private var network: Network!
    private var surveyStatus: SurveyStatus = .none
    private var userId: String!
    private var invitationId: String!
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        return dateFormatter
    }()
    
    //==========================================================================================================
    // MARK: - Public methods -
    //==========================================================================================================
    
    /**
     * Create userReport shared instance. Download config from backend and track screen view.
     *
     * - parameter sakId:   UserReport account SAK ID. (You can find these value on media setting page)
     * - parameter mediaId: ID of media created in UserReport account. (You can find these value on media setting page)
     * - parameter user:    User information
     * - parameter settings: Settings set by user
     * - parameter anonymousTracking: Do not send user identification if anonymous tracking is set
     */
    @objc public class func configure(sakId: String, mediaId: String, user: UserReportUser = UserReportUser(), settings: UserReportSettings? = nil, anonymousTracking: Bool = false) {
        sharedInstance = UserReport(sakId: sakId, mediaId: mediaId, user: user, settings: settings, anonymousTracking: anonymousTracking)
    }
    
    @objc public class func configure(sakId: String, mediaId: String, user: UserReportUser = UserReportUser(), settings: UserReportSettings? = nil) {
        sharedInstance = UserReport(sakId: sakId, mediaId: mediaId, user: user, settings: settings, anonymousTracking: false)
    }
    /**
     * Tracking screen view
     */
    @objc public class func trackScreenView() {
        UserReport.shared?.trackScreenView()
    }
    
    @objc private func trackScreenView() {
        // Track audience every screen view instead first screen view because we already tracked audience when initialize SDK
        if self.session.screenView != 0 {
            self.sendTrackScreenView()
        }
        
        // Update session `screenView` and `totalScreenView` values
        self.session.updateScreenViewed()
    }
    
    /**
     * Tracking section screen view
     */
    @objc public class func trackSectionScreenView(_ sectionId: String) {
        UserReport.shared?.trackSectionScreenView(sectionId)
    }
    
    @objc private func trackSectionScreenView(_ sectionId: String) {
        self.sendTrackSectionScreenView(sectionId)
        
        // Update session `screenView` and `totalScreenView` values
        self.session.updateScreenViewed()
    }
    
    /**
     * Force show survey on screen.
     * Will send invitation request to backend. Depending on response will invite to take survey or not.
     */
    @objc public class func tryInvite() {
        UserReport.shared?.tryInvite()
    }
    
    @objc private func tryInvite() {
        self.tryInvite(force: true)
    }
    
    /**
     * Provide possibility to extend data about user sent to backend.
     *
     * - parameter user: User with new data
     */
    @objc public class func updateUser(_ user: UserReportUser) {
        UserReport.shared?.updateUser(user)
    }
    @objc private func updateUser(_ user: UserReportUser) {
        self.info.user = user
    }
    
    /**
     * Change rules for shown Survey
     *
     * - parameter settings: New settings
     */
    @objc public class func updateSettings(_ settings: UserReportSettings) {
        UserReport.shared?.session.updateSettings(settings)
    }
    @objc private func updateSettings(_ settings: UserReportSettings) {
        self.session.updateSettings(settings)
    }
    
    //==========================================================================================================
    // MARK: - Private methods -
    //==========================================================================================================
    
    /**
     * Creates an instance with the specified `sakId`, `mediaId`, `user` and `settings`.
     * Download config from backend and track screen view.
     *
     * - parameter sakId:        UserReport account SAK ID. (You can find these value on media setting page)
     * - parameter mediaId:      ID of media created in UserReport account. (You can find these value on media setting page)
     * - parameter user:         User information
     * - parameter settings:     Settings set by user
     *
     * - returns: The new `UserReport` instance.
     */
    private init(sakId: String, mediaId: String, user: UserReportUser, settings: UserReportSettings?, anonymousTracking: Bool) {
        super.init()
        
        // Create info
        let media = Media(sakId: sakId, mediaId: mediaId)
        self.info = Info(media: media, user: user)
        
        // Create logger
        self.logger = Logger(info: self.info)
        self.logger.log("Initialize SDK version: \(UserReport.sdkVersion) (sakID:\(sakId) mediaID:\(mediaId))", level: .info)
        
        self.session = Session(store: Store(), rulesPassed: { [weak self] in
            self?.tryInvite(force: false)
        })
        
        // Anonymous tracking
        self.anonymousTracking = anonymousTracking
        
        // DI logger
        self.network = .init(logger: logger, testMode: testMode)
        
        self.network.getConfig(media: media, anonymousTracking: anonymousTracking) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let mediaSettings):
                
                self.info.mediaSettings = mediaSettings
                self.info.media.companyId = mediaSettings.companyId
                
                // Set settings
                let defaultSettings = mediaSettings.settings
                UserReportSettings.defaultInstance = defaultSettings
                self.session.updateSettings(defaultSettings)
                
                if let userSettings = settings {
                    self.session.updateSettings(userSettings)
                }
                
            case .failure(let error):
                self.logger.log("Failed get config. Error: \(error.localizedDescription)", level: .error)
            }
            
            self.trackScreenView()
        }
    }
    
    /**
     * Tracking audience measurement for Kits
     */
    private func sendTrackScreenView() {
        guard let tCode = info.mediaSettings?.kitTcode else {
            return
        }
        
        self.network.trackScreenView(info: self.info, tCode: tCode, anonymousTracking: self.anonymousTracking) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            
            case .success:
                self.logger.log("Viewed screen", level: .info)
                
            case .failure(let error):
                self.logger.log("Can't track screenView. Error: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    private func sendTrackSectionScreenView(_ sectionId: String) {
        guard let tCode = info.mediaSettings?.sections?[sectionId] else {
            self.logger.log("Can't find section in media. Section Id: \(sectionId)", level: .error)
            return
        }
        
        self.network.trackScreenView(info: self.info, tCode: tCode, anonymousTracking: self.anonymousTracking) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            
            case .success:
                self.logger.log("Viewed section screen", level: .info)
                
            case .failure(let error):
                self.logger.log("Can't track section screenView. Error: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    /**
     * Try show survey on screen.
     * Will send invitation request to backend. Depending on response will invite to take survey or not.
     *
     * - parameter force: If `true` then ignore rules and parameter `mute`
     */
    private func tryInvite(force: Bool) {
        
        // Don't try show invitation when `mute` true
        if self.mute == true && force == false {
            return
        }
        
        // Validate of `serverStatus` is .none
        guard self.surveyStatus == .none else {
            
            switch self.surveyStatus {
            case .none:
                break
                
            case .requestInvite, .loadingInvitation:
                self.logger.log("tryInvite() already in progress", level: .warning)
                
            case .surveyShown:
                self.logger.log("Survey is already shown on the screen", level: .warning)
            }
            return
        }
        
        self.surveyStatus = .requestInvite
        
        /// Set local quarantine for reason some internal troubles
        self.getLocalQuarantineDate().flatMap { self.session.localQuarantineDate = $0 }
        
        self.network.invitation(info: self.info) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let value):
                /// Get userId and invitationId from API response
                self.userId = value.userId
                self.invitationId = value.invitationId
                
                guard value.invite == true else {
                    self.surveyStatus = .none
                    self.logger.log("`invitation` false")
                    self.actualizeLocalQuarantine()
                    
                    return
                }
                
                guard let invitationURL = value.invitationUrl else {
                    // Track error (invalid URL)
                    self.surveyStatus = .none
                    self.logger.log("`invitationURL` nil")
                    
                    return
                }
                
                guard let url = URL(string: invitationURL) else {
                    // Track error (invalid URL)
                    self.surveyStatus = .none
                    self.logger.log("Can't create URL in showSurver()")
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.tryPresentSurvey(url: url)
                }
                
            case .failure(let error):
                self.surveyStatus = .none
                self.logger.log("Get invitation info Failed. Error: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    /**
     * Adds local quarantine days from settings to current date.
     */
    private func getLocalQuarantineDate() -> Date? {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = self.session.settings?.localQuarantineDays
        
        return Calendar.current.date(byAdding: dateComponent, to: currentDate)
    }
    
    /**
     *  Send 'close' quarantine reason to API
     */
    fileprivate func closeQuarantine() {
        network.setQuarantine(reason: "Close", mediaId: info.media.mediaId, invitationId: invitationId, userId: userId)
            { _ in }
    }
    
    /**
     * Downloading the page received from the server and displaying the survey in case of success.
     *
     * - parameter url: The URL of `invitationUrl`
     */
    private func tryPresentSurvey(url: URL) {
        self.surveyStatus = .loadingInvitation
        
        let surveyVC = SurveyViewController(url: url, mode: self.displayMode)
        surveyVC.logger = self.logger
        surveyVC.modalTransitionStyle = .crossDissolve
        surveyVC.modalPresentationStyle = .overCurrentContext
        surveyVC.load()
        
        surveyVC.loadDidFinish = { [weak self, weak surveyVC] in
            guard let self = self , let surveyVC = surveyVC else { return }
            
            self.surveyStatus = .surveyShown
            UIApplication.shared.keyWindow?.rootViewController?.present(surveyVC, animated: true)
        }
        
        surveyVC.loadDidFail = { [weak self] error in
            
            self?.surveyStatus = .none
            
            if let error = error {
                // Track error
                self?.logger.log("Load 'invitationUrl' did fail with error: \(error.localizedDescription)")
            } else {
                // Track nil error
                self?.logger.log("Load 'invitationUrl' did fail with empty error")
            }
        }
        
        /// Handle survey close native 'X' button
        surveyVC.handlerCloseButton = { [weak self, weak surveyVC] in
            
            self?.surveyStatus = .none
            surveyVC?.dismiss(animated: true)
            
            self?.closeQuarantine()
            self?.scheduleActualizeLocalQuarantine()
        }
        
        /// Handle survey close event by 'No' / 'Close' button
        surveyVC.handlerSurveyClosedEvent = { [weak self, weak surveyVC] in
            
            self?.surveyStatus = .none
            surveyVC?.dismiss(animated: true)
            
            self?.scheduleActualizeLocalQuarantine()
        }
    }
    
    /**
     * Schedule is needed to avoid race of close event and getting quarantine API call
     */
    @objc private func scheduleActualizeLocalQuarantine() {
        Timer.scheduledTimer(timeInterval: 3,
                             target: self,
                             selector: #selector(self.actualizeLocalQuarantine),
                             userInfo: nil,
                             repeats: false)
    }
    
    /**
     * Set correct local quarantine according to user behavior
     */
    @objc private func actualizeLocalQuarantine() -> Void {
        /// Get current local quarantine from API
        network.getQuarantineInfo(userId: userId, mediaId: info.media.mediaId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                value.inLocalTill.flatMap(self.dateFormatter.date).flatMap { self.session.localQuarantineDate = $0 }
                
            case .failure(let error):
                
                self.surveyStatus = .none
                self.logger.log("Get quarantine info Failed. Error: \(error.localizedDescription)", level: .error)
                
            }
        }
    }
}
