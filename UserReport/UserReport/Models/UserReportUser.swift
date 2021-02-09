//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation
import AdSupport
import AppTrackingTransparency

/// Model describing user
public class UserReportUser: NSObject {
    
    // MARK: - Property
    
    @objc public var idfa: String {
        get {
            return getAdvertisingId()
        }
    }
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
    
    public override init() {
    }
    
    @objc private func getAdvertisingId() -> String {
        var advertisingId: String = ""
        
        if UserReport.shared?.anonymousTracking == true {
            return advertisingId
        }
        
        isTrackingEnabled(){(isTrackingAllowed: Bool) -> Void in
            if (isTrackingAllowed) {
                /// By default iOS 13.3 simulator always returns idfa as '00000000-0000-0000-000000000000'
                /// https://forums.developer.apple.com/thread/124604
                #if targetEnvironment(simulator)
                if #available(iOS 13.0, *) {
                    advertisingId = UUID().uuidString
                }
                else {
                    advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                }
                #else
                advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                #endif
            }
        }
        
        return advertisingId
    }
    
    @objc private func isTrackingEnabled( result: @escaping (_ isTrackingAllowed: Bool) -> Void){
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                if (status == .authorized){
                    result(true);
                }
                else {
                    result(false);
                }
            }
        }
        else {
            result(ASIdentifierManager.shared().isAdvertisingTrackingEnabled);
        }
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
