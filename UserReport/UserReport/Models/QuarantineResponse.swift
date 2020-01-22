//
//  QuarantineResponse.swift
//  UserReport
//
//  Created by Maksym Binkovskyi on 20.01.2020.
//  Copyright © 2020 UserReport. All rights reserved.
//

import Foundation

/**
 * Quarantine response from the server
 */
internal struct QuarantineResponse {
    
    var inGlobalTill: String
    
    var inLocalTill: String?
    
    var isInGlobal: Bool!
    
    var isInLocal: Bool!
}

extension QuarantineResponse: Serialization {
    
        init(dict: [String: Any?]) throws {
            
            guard let inGlobalTill = dict["inGlobalTill"] as? String else {
                throw URError.responseDataNotFoundKey("inGlobalTill")
            }
            self.inGlobalTill = inGlobalTill
            
            if let isInGlobal = dict["isInGlobal"] as? Bool {
                self.isInGlobal = isInGlobal
            }
            
            if let isInLocal = dict["isInLocal"] as? Bool {
                self.isInLocal = isInLocal
                
                if isInLocal {
                    self.inLocalTill = dict["inLocalTill"] as? String
                }
            }
    }
}
