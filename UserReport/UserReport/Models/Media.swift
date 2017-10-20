//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/**
 * Model describing media on behalf of which requests made
 */
internal struct Media {
    
    // MARK: - Property
    
    /// ID of media created in UserReport account
    var mediaId: String
    
    /// UserReport account SAK ID
    var sakId: String
    
    /// Company id (use internal SDK)
    var companyId: String?
    
    /// Bundle ID current application
    var bundleId: String?
    
    // MARK: - Init
    
    /**
     * Creates an instance with the specified `sakId` and `mediaId`.
     *
     * - parameter sakId:   UserReport account SAK ID
     * - parameter mediaId: ID of media created in UserReport account
     *
     * - returns: The new `Media` instance.
     */
    init(sakId: String, mediaId: String) {
        self.sakId = sakId
        self.mediaId = mediaId
        self.bundleId = Bundle.main.bundleIdentifier
    }

    // MARK: - JSON
    
    /**
     * Converting an object to a dictionary for sending to the server
     *
     * - returns: Dictionary object
     */
    func dictObject() -> [String: Any?] {
        return [ "mediaId": self.mediaId,
                 "networkId": self.companyId,
                 "bundleId": self.bundleId]
    }
    
}
