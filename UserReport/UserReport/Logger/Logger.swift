//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation

/// Enum defining our log levels
public enum LogLevel: Int {
    case debug
    case info
    case warning
    case error
    case fatal
}

/**
 * Class of logging information and error of SDK for display in the console and sending to the server
 */
internal class Logger {
    
    // MARK: Properties
    
    /// The log level of this logger, any logs received at this level or higher will be output to the destinations. Default `.debug`
    internal var level: LogLevel = .debug
    
    /// DI `info` instance for set details to request
    internal var info: Info
    
    /// DI `network` instance for sending error messages to server
    internal var network: Network?
    
    // MARK: Init
    
    /**
     * Creates an instance with the specified `info` and `network`
     *
     * - parameter message: Message text
     * - parameter level:   Specified log level. Default `.debug`
     *
     * - returns: The new `Logger` instance.
     */
    init(info: Info, network: Network) {
        self.info = info
        self.network = network
    }
    
    // MARK: Log function
    
    /**
     * Displaying messages in the console and sending them to the server for the level .error and .fatal
     *
     * - parameter message: Message text
     * - parameter level:   Specified log level. Default `.debug`
     */
    internal func log(_ message: String, level: LogLevel = .debug) {
        
        // Print to console
        if self.level.rawValue <= level.rawValue {
            print("[UserReport] \(message)")
        }
        
        // Send error to server
        switch level {
        case .error, .fatal:
            self.systemLog(message)
        default:
            break
        }
    }
    
    /**
     * Sending messages to the server
     *
     * - parameter message: Message text
     */
    internal func systemLog(_ message: String) {
        self.network?.logMessage(info: self.info, message: message) { (result) in }
    }
    
}
