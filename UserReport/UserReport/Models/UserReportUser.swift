//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation
import AdSupport

/// Model describing user
public class UserReportUser: NSObject {
    
    // MARK: - Property
    
    internal var idfa: String
    private var _email : String?
    @objc public var email: String? {
        set {
            _email = newValue?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            emailMd5 = _email?.hashed(.md5)
            emailSha1 = _email?.hashed(.sha1)
            emailSha256 = _email?.hashed(.sha256)
        }
        get {
            return _email
        }
    }
    @objc public var emailMd5: String?
    @objc public var emailSha1: String?
    @objc public var emailSha256: String?
    @objc public var facebookId: String?
    
    // MARK: - Init
    
    /// By default iOS 13.3 simulator always returns idfa as '00000000-0000-0000-000000000000'
    /// https://forums.developer.apple.com/thread/124604
    public override init() {
        #if targetEnvironment(simulator)
        if #available(iOS 13.0, *) {
            self.idfa = UUID().uuidString
        } else {
            self.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
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
                "emailMd5": self.emailMd5,
                "emailSha1": self.emailSha1,
                "emailSha256": self.emailSha256,
                "facebookId": self.facebookId]
    }
}
