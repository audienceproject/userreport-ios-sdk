//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/// Protocol use for generic in Networking for serialization models
protocol SerializableObject {
    
    init(dict: [String: Any?]) throws
}

/// Use this struct when you expect empty response
struct Empty: SerializableObject {
    
    init(dict: [String: Any?]) throws {}
}
