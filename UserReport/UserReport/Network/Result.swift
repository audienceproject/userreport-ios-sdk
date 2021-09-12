//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/**
 * Used to represent whether a request was successful or encountered an error.
 *
 * - success: The request and all post processing operations were successful resulting in the serialization of the provided associated value.
 * - failure: The request encountered an error resulting in a failure. The associated values are the original data provided by the server as well as the error that caused the failure.
 */
internal enum Result<Value> {
    case success(Value)
    case failure(Error)
}
