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
        var sakUrl: String
        var dntSakUrl: String
        var trackUrl: String
        var doNotTrackUrl: String
        
        init() {
            let env = ProcessInfo.processInfo.environment
            api = env["USERREPORT_SERVER_URL_API"] ?? "https://api.userreport.com/collect/v1"
            sakUrl = env["USERREPORT_SERVER_URL_SAK"] ?? "https://sak.userreport.com"
            dntSakUrl = env["USERREPORT_SERVER_URL_SAK_DO_NOT_TRACK"] ?? "https://sak.dnt-userreport.com"
            trackUrl = env["USERREPORT_SERVER_URL_AUDIENCES"] ??  "https://visitanalytics.userreport.com"
            doNotTrackUrl = env["USERREPORT_SERVER_URL_DO_NOT_TRACK"] ??  "https://visitanalytics.dnt-userreport.com"
        }
    }
    
    // MARK: - Properties
    
    let logger: Logger
    var testMode: Bool
    
    private static let userAgent = WKWebView().value(forKey: "userAgent") as? String
    
    private let server = Server()
    private let session: URLSession
    
    // MARK: - Init
    
    init(logger: Logger, testMode: Bool) {
        
        // Setup session configuration with additional headers
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        // Create session with configuration
        self.session = URLSession(configuration: sessionConfiguration)
        self.logger = logger
        self.testMode = testMode
    }
    
    // MARK: API
    
    func invitation(info: Info, completion: @escaping ((Result<Invitation, Error>) -> Void)) {
        let path = testMode ? "visit+invitation/testinvite" : "invitation"
        let url = server.api/path
        let data = info.dictObject()
        send(request: Request(.POST, url, body: data), completion)
    }
    
    func getQuarantineInfo(userId: String, mediaId: String, completion: @escaping ((Result<QuarantineResponse, Error>) -> Void)) {
        let url = server.api/"quarantine"/userId/"media"/mediaId/"info"
        send(request: Request(.GET, url), completion)
    }
    
    func setQuarantine(reason: String, mediaId: String, invitationId: String, userId: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        let url = server.api/"quarantine"
        let data = ["reason": reason, "mediaId": mediaId, "invitationId": invitationId, "userId": userId]
        send(request: Request(.POST, url, body: data), completion)
    }
    
    func getConfig(media: Media, anonymousTracking: Bool, completion: @escaping ((Result<MediaSettings, Error>) -> Void)) {
        let sakUrl = anonymousTracking ? server.dntSakUrl : server.sakUrl
        let url = sakUrl/media.sakId/"media"/media.mediaId/"ios.json"
        send(request: Request(.GET, url), completion)
    }
    
    func trackScreenView(info: Info,
                         tCode: String,
                         anonymousTracking: Bool,
                         completion: @escaping ((Result<Void, Error>) -> Void))
    {
        //https://visitanalytics.userreport.com/hit.gif?t=[kitTcode]&rnd=%RANDOM%&d=IDFA&med=app_name&appver=app_ver+app_build&idfv=identifierForVendor&iab_consent=hardcodedConsent
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
        let appFullVersion = appVersion + "." + appBuild
        
        let tCode = "t=\(tCode)&"
        let random = arc4random_uniform(UInt32.max)
        
        // Do not send idfa and identifierForVendor if anonymousTracking is set
        let idfa = anonymousTracking ? "" : info.user?.idfa ?? ""
        let idForVendor = anonymousTracking ? "" : UIDevice.current.identifierForVendor!.uuidString
        
        let trackingUrl = anonymousTracking ? self.server.doNotTrackUrl : self.server.trackUrl
        var urlString = "\(trackingUrl)/hit.gif?\(tCode)rnd=\(random)&d=\(idfa)&med=\(appName)&appver=\(appFullVersion)&idfv=\(idForVendor)"
        
        if let consent = info.mediaSettings?.hardcodedConsent {
            urlString.append("&iab_consent=\(consent)")
        }
        
        let allowedCharacters = CharacterSet(charactersIn: " ").inverted
        guard let url = urlString.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return }
        
        if let userAgent = Network.userAgent {
            send(request: Request(.GET, url, ["User-Agent": userAgent]), completion)
        } else {
            send(request: Request(.GET, url), completion)
        }
    }
    
    // MARK: Network methods
    
    private func send<Value: SerializableObject>(request: Request, _ completion: @escaping ((Result<Value, Error>) -> Void)) {
        do {
            // Create request object
            let urlRequest = try request.build()
            // Create data task
            let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    completion(self.processResponse(data, response, error))
                }
            }
            // Send request
            task.resume()
        } catch {
            // Track error
            self.logger.log("Error request build: \(error.localizedDescription)", level: .error)
            completion(.failure(error))
        }
    }
    
    private func send(request: Request, _ completion: @escaping ((Result<Void, Error>) -> Void)) {
        do {
            // Create request object
            let urlRequest = try request.build()
            // Create data task
            let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    completion(self.processResponse(data, response, error))
                }
            }
            // Send request
            task.resume()
        } catch {
            // Track error
            self.logger.log("Error request build: \(error.localizedDescription)", level: .error)
            completion(.failure(error))
        }
    }
    
    private func processResponse<Value: SerializableObject>(
        _ data: Data?,
        _ response: URLResponse?,
        _ error: Error?) -> Result<Value, Error>
    {
        if let error = error {
            // Track error
            return .failure(error)
        }
        
        guard let data = data else {
            // Track error
            return .failure(URError.responseDataNilOrZeroLength(url: response?.url))
        }
        
        if let response = response as? HTTPURLResponse, response.statusCode > 299 {
            let logLevel: LogLevel = self.testMode ? .debug : .error
            self.logger.log("Incorrect response status code: \(response.statusCode.description)", level: logLevel)
            self.logger.log("Response: \(String(decoding: data, as: UTF8.self))", level: logLevel)
            return .failure(URError.responseDataNilOrZeroLength(url: response.url))
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any?]
            let value = try Value(dict: json)
            return .success(value)
        } catch {
            //Track error
            self.logger.log("Error JSON serialization: \(error.localizedDescription)", level: .error)
            return .failure(error)
        }
    }
    
    private func processResponse(
        _ data: Data?,
        _ response: URLResponse?,
        _ error: Error?) -> Result<Void, Error>
    {
        if let error = error {
            // Track error
            return .failure(error)
        } else {
            return .success(())
        }
    }
}
