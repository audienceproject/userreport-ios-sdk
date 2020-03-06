//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit
import UserReportSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let settings = Settings()
        settings.sessionScreensView = 14
        
        // Initialize UserReport SDK
        let user = User()
        user.email = "example@email.com"
        UserReport.configure(sakId: "audienceproject", mediaId: "3402b774-b7a8-448c-997a-ef6cd59efc41", user: user, settings: settings)
        
        return true
    }

}

