//
//  String+Request.swift
//  UserReportSDK
//
//  Created by Dmitriy on 15.09.2021.
//  Copyright © 2021 UserReport. All rights reserved.
//

import Foundation

public extension String  {
    
    @inlinable static func / (lhs: String, rhs: String) -> String {
         lhs + "/" + rhs
    }
}
