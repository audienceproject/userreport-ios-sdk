//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit
import UserReport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let settings = Settings()
        settings.sessionScreensView = 14
        
        // Initialize UserReport SDK
        let user = User()
        user.email = "example@email.com"
        UserReport.configure(sakId: "ios-playground", mediaId: "df5be674-b6a8-4bb8-8f44-4c8229a01bc2", user: user, userSettings: settings)

        
        return true
    }

}

