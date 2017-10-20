//
//  Copyright © 2017 UserReport. All rights reserved.
//

import Foundation
import UIKit
import WebKit

/// HTTP method definitions.
internal enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

internal class Network {
    
    struct Server {
        var api: String
        var sak: String
        var log: String
        var audiences: String
    }
    
    // MARK: - Properties
    
    internal var logger: Logger?
    internal var testMode: Bool = false
    private var session: URLSession?
    private let server: Server = {
        let env = ProcessInfo.processInfo.environment
        return Server(api: env["USERREPORT_SERVER_URL_API"] ?? "https://api.userreport.com/collect/v1",
                      sak: env["USERREPORT_SERVER_URL_SAK"] ?? "https://sak.userreport.com",
                      log: env["USERREPORT_SERVER_URL_LOG"] ?? "https://qa-relay.userreport.com/f/qa1-android-sdk-log/json",
                      audiences: env["USERREPORT_SERVER_URL_AUDIENCES"] ??  "https://visitanalytics.userreport.com")
    }()
    
    // MARK: - Init
    
    init() {
        
        // Setup session configuration with additional headers
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        // Create session wirh configuration
        self.session = URLSession(configuration: sessionConfiguration)
    }
    
    // MARK: API
    
    func visit(info: Info, completion: @escaping ((Result<Empty>) -> Void)) {
        let url = URL(string: "\(self.server.api)/visit")
        let data = info.dictObject()
        self.sendRequest(httpMethod: HTTPMethod.POST, url: url, body: data, emptyReponse: true, completion: completion)
    }
    
    func invitation(info: Info, completion: @escaping ((Result<Invitation>) -> Void)) {
        let path = self.testMode ? "visit+invitation/testinvite" : "invitation"
        let url = URL(string: "\(self.server.api)/\(path)")
        let data = info.dictObject()
        self.sendRequest(httpMethod: HTTPMethod.POST, url: url, body: data, completion: completion)
    }
    
    func getConfig(media: Media, completion: @escaping ((Result<MediaSettings>) -> Void)) {
        let url = URL(string: "\(self.server.sak)/\(media.sakId)/media/\(media.mediaId)/ios.json")
        self.sendRequest(httpMethod: HTTPMethod.GET, url: url, body: nil, completion: completion)
    }
    
    func audiences(info: Info, completion: @escaping ((Result<Empty>) -> Void)) {
        //https://visitanalytics.userreport.com/hit.gif?t=[kitTcode]&rnd=%RANDOM%&d=IDFA&med=app_name
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let kitTcode = info.mediaSettings?.kitTcode
        let tCode = (kitTcode != nil) ? "t=\(kitTcode!)&" : ""
        let random = arc4random_uniform(UInt32.max)
        let idfa = info.user?.idfa ?? ""
        let url = URL(string: "\(self.server.audiences)/hit.gif?\(tCode)rnd=\(random)&d=\(idfa)&med=\(appName)")
        self.userAgent { (userAgent) in
            let headers = ["User-Agent": userAgent]
            self.sendRequest(httpMethod: HTTPMethod.POST, url: url, headers: headers, body: nil, emptyReponse: true, completion: completion)
        }
    }
    
    func logMessage(info: Info, message: String, completion: @escaping ((Result<Empty>) -> Void)) {
        let url = URL(string: self.server.log)
        var data = info.dictObject()
        data["message"] = message
        self.sendRequest(httpMethod: HTTPMethod.POST, url: url, body: data, emptyReponse: true, completion: completion)
    }
    
    // MARK: Network methods
    
    private var webView: WKWebView? = WKWebView()        // Need for get default WebKit `User-Agent` header
    private var userAgentHeader: String?    // Default WebKit `User-Agent`
    
    
    private func userAgent(_ completion: @escaping (String) -> Void) {
        
        // Return cached `User-Agent`
        if let userAgentHeader = self.userAgentHeader {
            self.webView = nil
            completion(userAgentHeader)
            return
        }
        
        // Get `User-Agent` from webView
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
                guard error == nil else {
                    self.logger?.log("Can't get User-Agent for send audiences. Error: \(error?.localizedDescription ?? "")", level: .error)
                    return
                }
                guard let userAgent = result as? String else {
                    self.logger?.log("Can't get User-Agent for send audiences. Error: invalid result", level: .error)
                    return
                }
                
                // Return `User-Agent`
                self.userAgentHeader = userAgent
                completion(userAgent)
            })

        }
    }
    
    private func sendRequest<Value: Serialization>(httpMethod: HTTPMethod, url: URL?, headers: [String: String]? = nil, body: Any?, emptyReponse: Bool = false, completion: @escaping ((Result<Value>) -> Void)) {
        
        // Validate URL
        guard let url = url else {
            // Track error
            return
        }
        
        // Create request object
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        // Set headers if needed
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set body if needed
        if let data = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            } catch {
                //Track error
                self.logger?.log("Error JSON serialization: \(error.localizedDescription)", level: .error)
            }
        }
        
        // Send request
        let task = self.session?.dataTask(with: request, completionHandler: { (data, response, errorResponse) in
            guard errorResponse == nil else {
                // Track error
                let result = Result<Value>.failure(errorResponse!)
                completion(result)
                return
            }
            guard emptyReponse == false else {
                let empty = try! Value(dict: [:])
                let result = Result<Value>.success(empty)
                completion(result)
                return
            }
            guard let data = data else {
                // Track error
                let error = URError.responseDataNilOrZeroLength(url: url)
                let result = Result<Value>.failure(error)
                completion(result)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any?]
                let mediaSettings = try Value(dict: json)
                let result = Result<Value>.success(mediaSettings)
                completion(result)
                
            } catch {
                //Track error
                self.logger?.log("Error JSON serialization: \(error.localizedDescription)", level: .error)
                let result = Result<Value>.failure(error)
                completion(result)
            }
        })
        task?.resume()
        
    }
    
}
