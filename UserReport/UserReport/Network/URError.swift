//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/**
 * `URError` is the error type returned by UserReport and use only internal SDK.
 * It encompasses a few different types of errors, each with their own associated reasons.
 */
internal enum URError: Error {
    
    /// Fails to create a valid `URL`
    case invalidURL(url: URL)
    
    /// The server response contained no data or the data was zero length
    case responseDataNilOrZeroLength(url: URL)
    
    /// Cann`t find the required key in serialization data
    case responseDataNotFoundKey(String)
}
