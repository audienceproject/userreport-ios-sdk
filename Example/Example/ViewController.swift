//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit
import UserReportSDK

class ViewController: UserReportViewController {
    
    // MARK: Property
    
    @IBOutlet weak var testModeSwitch: UISwitch!
    
    // Display mode buttons
    @IBOutlet weak var alertDisplayModeButton: UIButton!
    @IBOutlet weak var fullscreenDisplayModeButton: UIButton!
    
    // Display session info
    @IBOutlet weak var totalScreensLabel: UILabel!
    @IBOutlet weak var expectedTotalScreensLabel: UILabel!
    @IBOutlet weak var sessionScreensLabel: UILabel!
    @IBOutlet weak var expectedSessionScreensLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var expectedTotalTimeLabel: UILabel!
    @IBOutlet weak var sessionTimeLabel: UILabel!
    @IBOutlet weak var expectedSessionTimeLabel: UILabel!
    @IBOutlet weak var quarantineTimeLabel: UILabel!
    @IBOutlet weak var expectedQuarantineTimeLabel: UILabel!
    
    // Timer for update session info
    private var timer: Timer?
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update navigationBar style and add logo
        self.setupNavigationBar()
        
        // Setup base state for testMode switch
        UserReport.testMode = true
        self.testModeSwitch.isOn = UserReport.testMode
        
        
        // Setup base state for Display mode buttons
        let isAlertMode = UserReport.shared?.displayMode == .alert
        self.alertDisplayModeButton.isSelected = isAlertMode
        self.fullscreenDisplayModeButton.isSelected = !isAlertMode
        
        self.updateSessionInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateSessionInfo), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    // MARK: Setup views
    
    private func setupNavigationBar() {
        // Add logo
        let logo = UIImageView(image: UIImage(named: "logo_navigation_bar"))
        self.navigationItem.titleView = logo
        
        // Update style
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bg_white"), for: .any, barMetrics: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.navigationController?.navigationBar.layer.shadowRadius = 5.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    // MARK: Update
    
    @objc private func updateSessionInfo() {
        
        // Session information about the running time of the application and screen views
        guard let session = UserReport.session else { return }
        self.totalScreensLabel.text = "\(session.totalScreenView) screens"
        self.sessionScreensLabel.text = "\(session.screenView) screens"
        self.totalTimeLabel.text = session.totalSecondsInApp.stringTime()
        self.sessionTimeLabel.text = session.sessionSeconds.stringTime()
        self.quarantineTimeLabel.text = Date().description
        
        // Get current settings for appear survey
        guard let settings = session.settings else { return }
        self.expectedTotalScreensLabel.text = "\(settings.inviteAfterTotalScreensViewed) screens"
        self.expectedSessionScreensLabel.text = "\(settings.sessionScreensView) screens"
        self.expectedTotalTimeLabel.text = settings.inviteAfterNSecondsInApp.stringTime()
        self.expectedSessionTimeLabel.text = settings.sessionNSecondsLength.stringTime()
        self.expectedQuarantineTimeLabel.text = session.localQuarantineDate.description
    }
    
    // MARK: Actions
    
    @IBAction func showUserReport(_ sender: Any) {
        // Display manually
        UserReport.tryInvite()
    }
    
    @IBAction func changeTestMode(_ sender: Any) {
        UserReport.testMode = self.testModeSwitch.isOn
        
        // Uncomment this line to test anonymous tracking
        // UserReport.setAnonymousTracking(self.testModeSwitch.isOn)
    }
    
    @IBAction func selectAlertDisplayMode(_ sender: Any) {
        
        // Change display mode survey in UserReport SDK
        UserReport.setDisplayMode(.alert)
        
        // Update buttons
        self.alertDisplayModeButton.isSelected = true
        self.fullscreenDisplayModeButton.isSelected = false
    }
    
    @IBAction func selectFullscreenDisplayMode(_ sender: Any) {
        
        // Change display mode survey in UserReport SDK
        UserReport.setDisplayMode(.fullscreen)
        
        // Update buttons
        self.alertDisplayModeButton.isSelected = false
        self.fullscreenDisplayModeButton.isSelected = true
    }
    
    @IBAction func trackScreen(_ sender: Any) {
        UserReport.trackScreenView()
        self.updateSessionInfo()
    }

    @IBAction func trackSessionScreen(_ sender: Any) {
         UserReport.trackSectionScreenView("b556da9f-9443-44ab-aa48-63d579318b69")
         self.updateSessionInfo()
     }
}

