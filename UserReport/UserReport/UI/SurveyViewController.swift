//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit
import WebKit

/**
 * ViewController for displaying the survey page
 */
internal class SurveyViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    // MARK: - Properties
    
    /// The URL of `invitationUrl`
    private var url: URL!
    
    /// Display style of the survey view on the screen
    private var displayMode: DisplayMode!
    
    /// UI element for display web page
    private var webView: WKWebView!
    
    /// UI element for close survey
    private var closeButton: UIButton!
    
    /// DI `logger` instance
    internal var logger: Logger?
    
    /// A closure executed when page successfully loaded
    internal var loadDidFinish: (() -> Void)?
    
    /// A closure executed when page fails to load
    internal var loadDidFail: ((Error?) -> Void)?
    
    /// A closure executed when user tap on close button
    internal var handlerCloseButton: (() -> Void)?
    
    internal var handlerSurveyClosedEvent: (() -> Void)?
    
    // MARK: Init
    
    /**
     * Creates an instance with the specified `url` and `mode`.
     *
     * - parameter url:     The URL of `invitationUrl`
     * - parameter mode:    Display style of the survey view on the screen
     *
     * - returns: The new `SurveyViewController` instance.
     */
    convenience init(url: URL, mode: DisplayMode) {
        self.init()
        
        self.url = url
        self.displayMode = mode
        
        // Setup views
        self.setupWebView()
        self.setupCloseButton()
        self.changeFrame(rect: self.view.bounds)
        
        // Add views and layouting
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(self.webView)
        self.view.addSubview(self.closeButton)
    }
    
    // MARK: - Setup
    
    /// Create and setup `webView`. Subscribe for JS notifications
    private func setupWebView() {
        let controller = WKUserContentController()
        controller.add(self, name: "notification")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        
        // WebView for load survey url
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.webView.layer.cornerRadius = 5
        self.webView.clipsToBounds = true
        self.webView.navigationDelegate = self
    }
    
    /// Create and setup `closeButton`
    private func setupCloseButton() {
        self.closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30 ))
        self.closeButton.setTitle("X", for: .normal)
        self.closeButton.backgroundColor = UIColor.white
        self.closeButton.setTitleColor(UIColor.black, for: .normal)
        self.closeButton.layer.cornerRadius = self.closeButton.bounds.width / 2
        self.closeButton.layer.borderWidth = 1
        self.closeButton.layer.borderColor = UIColor.black.cgColor
        self.closeButton.addTarget(self, action: #selector(invokeSurveyClosedButton(_:)), for: .touchUpInside)
    }
    
    /**
     * Recalculate views size and position
     *
     * - parameter rect: New rect for recalculation
     */
    private func changeFrame(rect: CGRect) {
        switch self.displayMode as DisplayMode {
        case .alert:
            self.webView.frame = rect.insetBy(dx: 20, dy: 30).offsetBy(dx: 0, dy: 10)
            self.closeButton.center = CGPoint(x: self.webView.frame.maxX, y: self.webView.frame.minY)
        case .fullscreen:
            self.webView.frame = rect
            self.closeButton.center = CGPoint(x: self.webView.frame.maxX - 30, y: self.webView.frame.minY + 40)
        }
    }
    
    /// Subscribe for window rotates or is resized
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.changeFrame(rect: rect)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.logger?.log("Start loading page", level: .debug)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.logger?.log("Finish loading page", level: .debug)
        self.loadDidFinish?()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.logger?.log("Fail load page with error: \(error.localizedDescription)", level: .error)
        self.loadDidFail?(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            if let url = navigationAction.request.url {
                let shared = UIApplication.shared
                if shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        shared.openURL(url)
                    }
                }
            }
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: String] else {
            // Track error
            return
        }
        guard let event = body["body"] else {
            // Track error
            return
        }
        switch event {
            case "invitation-rendered":
                break
            case "survey-close":
                self.invokeSurveyClosedEvent(nil)
            default:
                // Track error: unknow event
                break
        }
    }

    
    // MARK: Actions
    
    /// Start load page for `url`
    func load() {
        let request = URLRequest(url: self.url)
        self.webView.load(request)
    }
    
    /// 'Close' / 'No' button action
    @objc func invokeSurveyClosedEvent(_ sender: UIButton?) {
        self.logger?.log("Hide SurveyViewController", level: .debug)
        self.handlerSurveyClosedEvent?()
    }

    /// Native cancel button action
    @objc func invokeSurveyClosedButton(_ sender: UIButton?) {
        self.logger?.log("Hide SurveyViewController", level: .debug)
        self.handlerCloseButton?()
    }
}
