//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/**
 * Model combining info about user, media, media settings, device.
 */
internal struct Info {
    
    // MARK: - Property
    
    /// Describing media on behalf of which requests made
    var media: Media!
    
    /// Describing customer of SDK
    var mediaSettings: MediaSettings?
    
    /// Information about the current user
    var user: UserReportUser!
    
    /// Information about the current device
    var device: Device
    
    // MARK: - Init
    
    /**
     * Creates an instance with the specified `media` and `user`.
     *
     * - parameter media:   Describing media on behalf of which requests made
     * - parameter user:    User information
     *
     * - returns: The new `Info` instance.
     */
    init(media: Media, user: UserReportUser) {
        self.media = media
        self.user = user
        self.device = Device()
    }
    
    // MARK: - JSON
    
    /**
     * Converting an object to a dictionary for sending to the server
     *
     * - returns: Dictionary object
     */
    func dictObject() -> [String: Any?] {
        return ["user": self.user?.dictObject(),
                "media": self.media?.dictObject(),
                "device": self.device.dictObject(),
                "customization": ["hideCloseButton": true]]
    }
    
}
