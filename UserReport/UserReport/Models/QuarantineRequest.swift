//
//  QuarantineRequest.swift
//  UserReport
//
//  Created by Maksym Binkovskyi on 20.01.2020.
//  Copyright © 2020 UserReport. All rights reserved.
//

import Foundation

internal struct QuarantineRequest {
    
    var userId: String!
    
    var mediaId: String!
    
    init(userId: String, mediaId: String) {
        self.userId = userId
        self.mediaId = mediaId
    }
}
