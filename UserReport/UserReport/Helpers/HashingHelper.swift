//
//  HashingHelper.swift
//  UserReportSDK
//
//  Created by Maksym Binkovskyi on 27.02.2020.
//  Copyright © 2020 UserReport. All rights reserved.
//
import Foundation
import CommonCrypto

// Defines types of hash string outputs available
public enum HashOutputType {
    // standard hex string output
    case hex
    // base 64 encoded string output
    case base64
}

// Defines types of hash algorithms available
public enum HashType {
    case md5
    case sha1
    case sha256
    
    var length: Int32 {
        switch self {
        case .md5: return CC_MD5_DIGEST_LENGTH
        case .sha1: return CC_SHA1_DIGEST_LENGTH
        case .sha256: return CC_SHA256_DIGEST_LENGTH
        }
    }
}

internal extension String {

    /// Hashing algorithm for hashing a string instance.
    ///
    /// - Parameters:
    ///   - type: The type of hash to use.
    ///   - output: The type of output desired, defaults to .hex.
    /// - Returns: The requested hash output or nil if failure.
    func hashed(_ type: HashType, output: HashOutputType = .hex) -> String? {

        // convert string to utf8 encoded data
        guard let message = data(using: .utf8) else { return nil }
        return message.hashed(type, output: output)
    }
}

internal extension Data {

    /// Hashing algorithm for hashing a Data instance.
     ///
     /// - Parameters:
     ///   - type: The type of hash to use.
     ///   - output: The type of hash output desired, defaults to .hex.
     ///   - Returns: The requested hash output or nil if failure.
     func hashed(_ type: HashType, output: HashOutputType = .hex) -> String? {

         // setup data variable to hold hashed value
         var digest = Data(count: Int(type.length))

         _ = digest.withUnsafeMutableBytes{ digestBytes -> UInt8 in
             self.withUnsafeBytes { messageBytes -> UInt8 in
                 if let mb = messageBytes.baseAddress, let db = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                     let length = CC_LONG(self.count)
                     switch type {
                     case .md5: CC_MD5(mb, length, db)
                     case .sha1: CC_SHA1(mb, length, db)
                     case .sha256: CC_SHA256(mb, length, db)
                     }
                 }
                 return 0
             }
         }

         // return the value based on the specified output type.
         switch output {
         case .hex: return digest.map { String(format: "%02hhx", $0) }.joined()
         case .base64: return digest.base64EncodedString()
         }
     }
}
