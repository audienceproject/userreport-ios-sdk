//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit

/**
 * ViewController for automatic tracking screen views.
 *
 * Sample code:
 * ```
 * class ViewController: UserReportViewController {
 *  ...
 * }
 * ```
 */
open class UserReportViewController: UIViewController {
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Tracking screen view
        UserReport.trackScreenView()
    }

}
