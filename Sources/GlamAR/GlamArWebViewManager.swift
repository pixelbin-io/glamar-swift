//
//  File.swift
//  GlamAR
//
//  Created by Anitha Sangu on 02/01/25.
//

import Foundation
import WebKit

public class GlamArWebViewManager: NSObject {
    
    static let shared = GlamArWebViewManager();
    
    private override init() {}
    
    private let prodUrl = "https://glamarz0.de/sdk/"
    private let stagingUrl = "https://glamarz0.de/sdk/"
    
    private var webView: WKWebView?
    public var previewMode: PreviewMode = .none
    public weak var defaultCallback: GlamArViewCallback?
    
    func prepareWebView(debug: Bool = true, previewMode: PreviewMode = .none) {
        
        print("prepare webview")
        
        clearPreparedWebView()
        self.previewMode = previewMode
        
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        config.allowsInlineMediaPlayback = true
        config.userContentController.add(self, name: "onLog")
        config.mediaTypesRequiringUserActionForPlayback = []
        
        webView = WKWebView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1), configuration: config)
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        
        // Disable zoom
        webView?.scrollView.delegate = self
        webView?.scrollView.bounces = false
        webView?.scrollView.bouncesZoom = false
        
        // Inject meta viewport tag to prevent zooming
        let script = WKUserScript(
            source: "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);",
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(script)
                
        let glamArHostURL = debug ? stagingUrl : prodUrl
        
        if let url = URL(string: glamArHostURL) {
            print("web url \(glamArHostURL)")
            webView?.load(URLRequest(url: url))
            print("webview initiated \(String(describing: webView!.url))")
        }
    }
        
    func getPreparedWebView() -> WKWebView? {
        return webView
    }
    
    func clearPreparedWebView() {
        webView?.evaluateJavaScript("document.body.innerHTML = ''", completionHandler: nil)
        webView?.removeFromSuperview()
        webView = nil
        HTTPCookieStorage.shared.cookies?.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
    }
    
    func setGlamArCallback(callback: GlamArViewCallback) {
        self.defaultCallback = callback
    }
    
    func evaluateJavaScript(_ script: String) {
        print("Script \(script)")
        webView?.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("Error evaluating JavaScript: \(error)")
            } else if let result = result {
                print("JavaScript evaluation result: \(result)")
            }
        }
    }
    
    public func initPreview() {
        print("inti preview")
        do {
            let accessKey = try GlamAr.getInstance().accessKey
            
            let script: String
            switch previewMode {
            case .none:
                script = "window.parent.postMessage({ type: 'initialize', payload: {mode:'private', platform: 'ios', apiKey:'\(accessKey)', disableCrossIcon: true, disablePrevIcon: true} }, '*');"
            case .image(let imageUrl):
                script = "window.parent.postMessage({ type: 'initialize', payload: {mode :'private', platform: 'ios', apiKey:'\(accessKey)', disableCrossIcon: true, disablePrevIcon: true, openImageOnInit : '\(imageUrl)'} }, '*');"
            case .camera:
                script = "window.parent.postMessage({ type: 'initialize', payload: {mode :'private', platform: 'ios', apiKey:'\(accessKey)', disableCrossIcon: true, disablePrevIcon: true, openLiveOnInit : true} }, '*');"
            case .faceAnalysis:
                script = "window.parent.postMessage({ type: 'initialize', payload: { mode: 'private', platform: 'ios', apiKey: '\(accessKey)', category: 'faceanalysis', disableCrossIcon: true, disablePrevIcon: true, openLiveOnInit: true } }, '*');"
            }
            evaluateJavaScript(script)
        } catch {
            defaultCallback?.onError(message: "Failed to initialize: \(error.localizedDescription)")
        }
    }
}

extension GlamArWebViewManager: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let args = message.body as? String else { return }
        do {
            let argsData = Data(args.utf8)
            if let argsJson = try JSONSerialization.jsonObject(with: argsData, options: []) as? [String: Any],
               let type = argsJson["type"] as? String {
                handleJavaScriptMessage(type: type, argsJson: argsJson)
            }
        } catch {
            print("Error processing JavaScript message: \(error)")
            defaultCallback?.onError(message: "Error processing JavaScript message: \(error.localizedDescription)")
        }
    }

    private func handleJavaScriptMessage(type: String, argsJson: [String: Any]) {
        print("js type \(type) message \(argsJson)")
        switch type {
        case "init-complete":
            defaultCallback?.onInitComplete()
        case "loading":
            defaultCallback?.onLoading()
        case "sku-applied":
            defaultCallback?.onSkuApplied()
        case "sku-failed":
            defaultCallback?.onSkuFailed()
        case "photo-loaded":
            if let payload = argsJson["payload"] as? [String: Any] {
                defaultCallback?.onPhotoLoaded(payload: payload)
            }
        case "loaded":
            defaultCallback?.onLoaded(mode: previewMode)
        case "error":
            let errorMessage = argsJson["message"] as? String ?? "Unknown error occurred"
            defaultCallback?.onError(message: errorMessage)
        case "face-analysis":
            if let payload = argsJson["payload"] as? [String: Any] {
                defaultCallback?.onFaceAnalysisCompleted(payload: payload)
            }
        default:
            break
        }
    }
}

extension GlamArWebViewManager: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView finished loading")
        initPreview()
    }
    
    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
        
        return origin.host == "www.glamarz0.de" ? .grant : .deny
    }
}

extension GlamArWebViewManager: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil // This disables zooming
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
