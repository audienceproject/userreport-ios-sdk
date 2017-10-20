//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/// Display style of the survey view on the screen
public enum DisplayMode {
    
    /// Show survey in full screen mode, like the modal view controller
    case fullscreen
    
    /// Show survey like an alert view (Default)
    case alert
}

/// Singleton instance
private var sharedInstance: UserReport?

public class UserReport {
    
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
    public class var shared: UserReport? {
        return sharedInstance
    }
    
    /// Current version of UserReport iOS SDK
    public static let sdkVersion = Bundle(for: UserReport.self).infoDictionary?["CFBundleShortVersionString"] as! String
    
    /// Survey view display style. Default `.alert`
    public var displayMode: DisplayMode = .alert
    
    /// Level of messages printing to the console. Default `.debug`
    public var logLevel: LogLevel {
        set { self.logger.level = newValue }
        get { return self.logger.level }
    }
    
    /**
     * Flag for testing the display of the survey view.
     * The server will return data about the survey each time, otherwise they will set up the default settings.
     * Default `false`
     */
    public var testMode: Bool = false {
        didSet {
            self.network.testMode = self.testMode
            self.logger.log("Test mode: \(self.testMode ? "On" : "Off")", level: .debug)
        }
    }
    
    /**
     * Mute display of the survey.
     * In order for the survey not to be appear on important screens.
     * Default `false`
     *
     * - Note: Don't forget to return back to `false`
     */
    public var mute: Bool = false
    
    /// Returns whether the survey is displayed on the screen
    public var isSurveyShown: Bool {
        get { return self.surveyStatus == .surveyShown }
    }
    
    /// Session data about count of screens viewed and the time the application is used
    public var session: Session!
    
    // MARK: private
    private var logger: Logger
    private var info: Info
    private var network: Network = Network()
    private var surveyStatus: SurveyStatus = .none
    
    //==========================================================================================================
    // MARK: - Public methods -
    //==========================================================================================================
    
    /**
     * Create userReport shared instance. Download config from backend and log visit.
     *
     * - parameter sakId:   UserReport account SAK ID. (You can find these value on media setting page)
     * - parameter mediaId: ID of media created in UserReport account. (You can find these value on media setting page)
     * - parameter user:    User information
     */
    public class func configure(sakId: String, mediaId: String, user: User) {
        sharedInstance = UserReport(sakId: sakId, mediaId: mediaId, user: user)
    }
    
    /**
     * Tracking screen view
     */
    public func trackScreen() {
        
        // Track audience every screen view instead first scren view because we already tracked audience when initialize SDK
        if self.session.screenView != 0 {
            self.trackAudience()
        }
        
        // Update session `screenView` and `totalScreenView` values
        self.session.trackScreenView()
        
        // Add info to logger
        self.logger.log("Viewed screen", level: .info)
    }
    
    /**
     * Force show survey on screen.
     * Will send invitation request to backend. Depending on response will invite to take survey or not.
     */
    public func tryInvite() {
        self.tryInvite(force: true)
    }
    
    /**
     * Provide possibility to extend data about user sent to backend.
     *
     * - parameter user: User with new data
     */
    public func updateUser(_ user: User) {
        self.info.user = user
    }
    
    /**
     * Change rules for shown Survey
     *
     * - parameter settings: New settings
     */
    public func updateSettings(_ settings: Settings) {
        self.session.updateSettings(settings)
    }
    
    //==========================================================================================================
    // MARK: - Private methods -
    //==========================================================================================================
    
    /**
     * Creates an instance with the specified `sakId`, `mediaId` and `user`.
     * Download config from backend and log visit.
     *
     * - parameter sakId:   UserReport account SAK ID. (You can find these value on media setting page)
     * - parameter mediaId: ID of media created in UserReport account. (You can find these value on media setting page)
     * - parameter user:    User information
     *
     * - returns: The new `UserReport` instance.
     */
    private init(sakId: String, mediaId: String, user: User) {
        
        // Create info
        let media = Media(sakId: sakId, mediaId: mediaId)
        self.info = Info(media: media, user: user)
        
        // Create logger
        self.logger = Logger(info: self.info, network: self.network)
        self.logger.log("Initialize SDK version: \(UserReport.sdkVersion) (sakID:\(sakId) mediaID:\(mediaId))", level: .info)
        
        self.session = Session(rulesPassed: {
            self.tryInvite(force: false)
        })
        
        // DI logger
        self.network.logger = self.logger
        
        self.network.getConfig(media: media) { (result) in
            switch (result) {
            case .success:
                guard let mediaSettings = result.value else {
                    self.logger.log("Can't create new session. Error: config is nil.", level: .error)
                    return
                }
                self.info.mediaSettings = mediaSettings
                self.info.media.companyId = mediaSettings.companyId
                
                // Set settings
                let settings = mediaSettings.settings
                Settings.defaultInstance = settings
                self.session.updateSettings(settings)
                self.logger.log("Settings: \(result.value!)", level: .debug)
            case .failure(let error):
                self.logger.log("Failed get config. Error: \(error.localizedDescription)", level: .error)
            }
            
            self.logVisit()
            self.trackAudience()
        }
    }
    
    /**
     * This method sends visit request to backend and user for sure will not be invited to take survey.
     */
    private func logVisit() {
        self.network.visit(info: self.info) { (result) in
            switch (result) {
            case .success:
                self.logger.log("Log visit", level: .info)
            case .failure(let error):
                self.logger.log("Log visit Failed. Error: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    /**
     * Tracking audience measurement for Kits
     */
    private func trackAudience() {
        self.network.audiences(info: self.info) { (result) in
            switch (result) {
            case .success:
                break
            case .failure(let error):
                self.logger.log("Can't track audience. Error: \(error.localizedDescription)", level: .error)
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
        
        // Validate of `surverStatus` is .none
        guard self.surveyStatus == .none else {
            switch self.surveyStatus {
            case .none:
                break
            case .requestInvite, .loadingInvitation:
                self.logger.log("tryInvite() already in progress", level: .warning)
                break
            case .surveyShown:
                self.logger.log("Survey is already shown on the screen", level: .warning)
                break
            }
            return
        }

        self.surveyStatus = .requestInvite
        self.session.updateLocalQuarantineDate()
        self.network.invitation(info: self.info) { (result) in
            switch (result) {
            case .success:
                guard result.value?.invite == true else {
                    self.surveyStatus = .none
                    self.logger.log("`invitation` false")
                    return
                }
                guard let invitationURL = result.value?.invitationUrl else {
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
                self.tryPresentSurvey(url: url)
            case .failure(let error):
                self.surveyStatus = .none
                self.logger.log("Get invitation info Failed. Error: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    /**
     * Downloading the page received from the server and displaying the survey in case of success.
     *
     * - parameter url: The URL of `invitationUrl`
     */
    private func tryPresentSurvey(url: URL) {
        self.surveyStatus = .loadingInvitation
        DispatchQueue.main.async {
            let surveyVC = SurveyViewController(url: url, mode: self.displayMode)
            surveyVC.logger = self.logger
            surveyVC.modalTransitionStyle = .crossDissolve
            surveyVC.modalPresentationStyle = .overCurrentContext
            surveyVC.load()
            surveyVC.loadDidFinish = {
                self.surveyStatus = .surveyShown
                UIApplication.shared.keyWindow?.rootViewController?.present(surveyVC, animated: true, completion: nil)
            }
            surveyVC.loadDidFail = { (error) in
                self.surveyStatus = .none
                guard error != nil else {
                    // Track nil error
                    self.logger.log("Load 'invitationUrl' did fail with empty error")
                    return
                }
                // Track error
                self.logger.log("Load 'invitationUrl' did fail with error: \(error!.localizedDescription)")
            }
            surveyVC.handlerCloseButton = {
                self.surveyStatus = .none
                surveyVC.dismiss(animated: true, completion: nil)
            }
        }
    }
}
