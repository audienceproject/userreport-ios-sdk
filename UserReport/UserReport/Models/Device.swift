//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation
import UIKit

/**
 * Information about the current device
 */
internal struct Device {
    
    // MARK: - Property
    
    /// Device type "mobile" or "tablet"
    var type: String
    
    /// Device brand always "Apple"
    var brand: String
    
    /// Device manufacturer always "Apple"
    var manufacturer: String
    
    /// The model of the device (e.g. @"iPhone", @"iPod touch")
    var model: String
    
    /// Operating system name (e.g. @"iOS")
    var os: String
    
    /// Operating system version (e.g. @"9.0")
    var osVersion: String
    
    /// Default 0
    var screenDpi: Double
    
    /// Device screen height
    var screenHeight: Double
    
    /// Device screen width
    var screenWidth: Double
    
    // MARK: - Init
    
    /**
     * Creates an instance with filled all parameters.
     *
     * - returns: The new `Device` instance.
     */
    init() {
        self.type = UIDevice.current.userInterfaceIdiom == .phone ? "mobile" : "tablet"
        self.brand = "Apple"
        self.manufacturer = "Apple"
        self.model = UIDevice.current.model
        self.os = UIDevice.current.systemName
        self.osVersion = UIDevice.current.systemVersion
        self.screenDpi = 0
        self.screenHeight = Double(UIScreen.main.bounds.size.height * UIScreen.main.scale)
        self.screenWidth = Double(UIScreen.main.bounds.size.width * UIScreen.main.scale)
    }
    
    // MARK: - JSON
    
    /**
     * Converting an object to a dictionary for sending to the server
     *
     * - returns: Dictionary object
     */
    func dictObject() -> [String: Any?] {
        return ["type": self.type,
                "brand": self.brand,
                "manufacturer": self.manufacturer,
                "model": self.model,
                "os": self.os,
                "osVersion": self.osVersion,
                "screenDpi": self.screenDpi,
                "screenHeight": self.screenHeight,
                "screenWidth": self.screenWidth]
    }
    
}
