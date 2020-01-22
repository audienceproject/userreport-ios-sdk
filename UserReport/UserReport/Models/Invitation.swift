//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/**
 * Invitation response from server
 */
internal struct Invitation {
    
    /// Will be true if user should be invited to survey.
    var invite: Bool = false
    
    /// Url with survey which need to be loaded
    var invitationUrl: String?
    
    /// ID of user
    var userId: String?
    
    /// ID of invitation
    var invitationId: String?
}

/**
 * An extension to initialize an object through a dictionary
 */
extension Invitation: Serialization {
    
    // MARK: - Init
    
    init(dict: [String: Any?]) throws {
        
        guard let invite = dict["invite"] as? Bool else {
            throw URError.responseDataNotFoundKey("invite")
        }
        
        self.invite = invite
        
        if let invitationUrl = dict["invitationUrl"] as? String {
            self.invitationUrl = invitationUrl
        }
        
        if let userId = dict["userId"] as? String {
            self.userId = userId
        }
        
        if let invitationId = dict["invitationId"] as? String {
            self.invitationId = invitationId
        }
    }
    
}
