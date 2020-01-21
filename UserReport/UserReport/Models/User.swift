//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation
import AdSupport

/// Model describing user
public class User: NSObject {
    
    // MARK: - Property
    
    internal var idfa: String
    @objc public var email: String?
    @objc public var emailMd5: String?
    @objc public var emailSha1: String?
    @objc public var emailSha256: String?
    @objc public var facebookId: String?
    
    // MARK: - Init
    
    /// By default iOS 13.3 simulator always returns idfa as '00000000-0000-0000-000000000000'
    /// https://forums.developer.apple.com/thread/124604
    public override init() {
        #if targetEnvironment(simulator)
        self.idfa = UUID().uuidString
        #else
        self.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        #endif
    }
    
    // MARK: - JSON
    
    /**
     * Converting an object to a dictionary for sending to the server
     *
     * - returns: Dictionary object
     */
    internal func dictObject() -> [String: Any?] {
        return ["idfa": self.idfa,
                "email": self.email,
                "emailMd5": self.emailMd5,
                "emailSha1": self.emailSha1,
                "emailSha256": self.emailSha256,
                "facebookId": self.facebookId]
    }
}
