//
//  UserAgent.swift
//  UserReportSDK
//
//  Created by Dmitriy on 15.09.2021.
//  Copyright © 2021 UserReport. All rights reserved.
//

import WebKit

final class UserAgent: NSObject {
    
    // MARK: - Properties
    
    private let webView = WKWebView(frame: .zero)
    
    // MARK: public Methods

    func fetch(_ completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("navigator.userAgent") { response, error in
                if let error = error {
                    // Error fetching `User-Agent`
                    completion(.failure(error))
                    return
                }
                
                guard let userAgent = response as? String else {
                    // Error fetching `User-Agent`
                    completion(.failure(URError.cantGetUserAgent))
                    return
                }
                
                // Return `User-Agent`
                completion(.success(userAgent))
            }
        }
    }
}
