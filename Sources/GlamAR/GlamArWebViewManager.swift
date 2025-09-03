//
//  File.swift
//  GlamAR
//
//  Created by Anitha Sangu on 02/01/25.
//

import Foundation
import WebKit

public class GlamArWebViewManager: NSObject {
    
    public static let shared = GlamArWebViewManager();
    
    private override init() {}
    
    private let prodUrl = "https://cdn.glamar.io/sdk"
    private let stagingUrl = "https://cdn.glamarz0.de/sdk"
    
    private let apiurl = "https://api.pixelbin.io"
    
    private var webView: WKWebView?
    private var overrides: GlamAROverrides?
    private var applicationId: String?
    var isWebViewLoaded: Bool = false
    
    func prepareWebView(debug: Bool = false,
                        bundleIdentifier: String,
                        overrides: GlamAROverrides? = nil,
                        providedWebView: WKWebView? = nil) {
        
        print("prepare webview")
        
        clearPreparedWebView()
        
        self.overrides = overrides
        self.applicationId = bundleIdentifier
        
        
        
        // Inject meta viewport tag to prevent zooming
        let script = WKUserScript(
            source: "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);",
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        if(providedWebView != nil) {
            
            webView = providedWebView
            let config = WKWebViewConfiguration()
            webView?.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            webView?.configuration.allowsInlineMediaPlayback = true
            webView?.configuration.userContentController.add(self, name: "onLog")
            webView?.configuration.mediaTypesRequiringUserActionForPlayback = []
            webView?.configuration.userContentController.addUserScript(script)
        } else {
            
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            let config = WKWebViewConfiguration()
            config.defaultWebpagePreferences = prefs
            config.allowsInlineMediaPlayback = true
            config.userContentController.add(self, name: "onLog")
            config.mediaTypesRequiringUserActionForPlayback = []
            
            // Required for camera & mic access via JS (getUserMedia)
            config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            
            webView = WKWebView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1), configuration: config)
            config.userContentController.addUserScript(script)
        }
        
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        
        // Disable zoom
        webView?.scrollView.delegate = self
        webView?.scrollView.bounces = false
        webView?.scrollView.bouncesZoom = false
        
        
        let glamArHostURL = debug ? stagingUrl : prodUrl
        
        let sdkMetaVersion = (overrides?.meta as? [String: Any])?["sdkVersion"] as? String
        var finalUrl = "\(glamArHostURL)/v1.0.0?"
        
        do {
            let api = try GlamAr.getInstance().api
            
            api.getVersion { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let sdkVersion):
                        print("GlamArWebViewManager", "Version API done (success: \(sdkVersion ?? "nil")). Proceeding to loadUrl.")
                        
                        if let version = sdkVersion, !version.isEmpty {
                            finalUrl = "\(glamArHostURL)/v\(version)?"
                        } else if let sdkMeta = sdkMetaVersion {
                            finalUrl = "\(glamArHostURL)/v\(sdkMeta)?"
                        }
                        
                        self?.loadWebView(url: finalUrl)
                    case .failure(let error):
                        print("GlamArWebViewManager", "Version API failed: \(error.localizedDescription). Using fallback.")
                        
                        if let sdkMeta = sdkMetaVersion {
                            finalUrl = "\(glamArHostURL)/v\(sdkMeta)?"
                        }
                        
                        self?.loadWebView(url: finalUrl)
                    }
                }
            }
        } catch {
            print("GlamArWebViewManager", "GlamArApi init failed: \(error.localizedDescription). Using fallback.")
            if let sdkMeta = sdkMetaVersion {
                finalUrl = "\(glamArHostURL)/v\(sdkMeta)?"
            }
            
            loadWebView(url: finalUrl)
        }
    }
    
    private func loadWebView(url: String) {
        
        GlamArWebPermissionManager.instance.requestCameraPermission { [weak self] granted in
            if let url = URL(string: url) {
                
                print("web url \(url)")
                self?.webView?.load(URLRequest(url: url))
                print("webview initiated \(String(describing: self?.webView?.url))")
            }
        }
    }
    
    public func getPreparedWebView() -> WKWebView? {
        return webView
    }
    
    func reloadWebView() {
        webView?.reload()
    }
    
    func clearPreparedWebView() {
        webView?.evaluateJavaScript("document.body.innerHTML = ''", completionHandler: nil)
        webView?.removeFromSuperview()
        webView = nil
        GlamArEventManager.shared.clearAllListeners()
        HTTPCookieStorage.shared.cookies?.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
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
        
        guard webView != nil else {
            print("GlamArWebViewManager: WebView is nil")
            return
        }
        
        do {
            let accessKey = try GlamAr.getInstance().accessKey
            
            if(overrides == nil) {
                let script = """
                            window.parent.postMessage({
                                type: 'initialize',
                                payload: {
                                    platform: 'ios',
                                    apiKey: '\(accessKey)'
                                }
                            }, '*');
                            """
                evaluateJavaScript(script)
                return
            }
            
            let platform = "ios";
            
            var payload: [String: Any] = [
                "apiKey": accessKey,
                "platform": platform,
                "parentDomain": applicationId ?? ""
            ]
            
            if let category = overrides?.category {
                payload["category"] = category
            }
            
            if let config = overrides?.configuration {
                var configMap: [String: Any] = [:]
                
                if let global = config.global {
                    var globalMap: [String: Any] = [:]
                    if let openLive = global.openLiveOnInit { globalMap["openLiveOnInit"] = openLive }
                    if let disableClose = global.disableClose { globalMap["disableClose"] = disableClose }
                    if let disableBack = global.disableBack { globalMap["disableBack"] = disableBack }
                    if !globalMap.isEmpty { configMap["global"] = globalMap }
                }
                
                if let skin = config.skinAnalysis {
                    var skinMap: [String: Any] = [:]
                    if let start = skin.appId { skinMap["appId"] = start }
                    if !skinMap.isEmpty { configMap["skinAnalysis"] = skinMap }
                }
                
                if let ui = config.ui {
                    var uiMap: [String: Any] = [:]
                    
                    if let loader = ui.loader {
                        var loaderMap: [String: Any] = [:]
                        if let disable = loader.disable { loaderMap["disable"] = disable }
                        if let jsonData = loader.jsonData { loaderMap["jsonData"] = jsonData }
                        if let backgroundColor = loader.backgroundColor { loaderMap["backgroundColor"] = backgroundColor }
                        if !loaderMap.isEmpty { uiMap["loader"] = loaderMap }
                    }
                    
                    if let watermark = ui.watermark {
                        var watermarkMap: [String: Any] = [:]
                        if let text = watermark.text { watermarkMap["text"] = text }
                        if let fontColor = watermark.fontColor { watermarkMap["fontColor"] = fontColor }
                        if let logo = watermark.logo { watermarkMap["logo"] = logo }
                        if !watermarkMap.isEmpty { uiMap["watermark"] = watermarkMap }
                    }
                    
                    if let ar = ui.ar {
                        var arMap: [String: Any] = [:]
                        if let disable3DUI = ar.disable3DUI { arMap["disable3DUI"] = disable3DUI }
                        if !arMap.isEmpty { uiMap["ar"] = arMap }
                    }
                    
                    if !uiMap.isEmpty {
                        configMap["ui"] = uiMap
                    }
                }
                
                if !configMap.isEmpty {
                    payload["configuration"] = configMap
                }
            }
                
                // Convert payload to JSON
                guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
                      let jsonString = String(data: jsonData, encoding: .utf8) else {
                    print("GlamArWebViewManager: Failed to serialize payload")
                    return
                }
                
                print("GlamArWebViewManager jsonPayload: \(jsonString)")
                
                let script = """
                        window.parent.postMessage({
                            type: 'initialize',
                            payload: \(jsonString)
                        }, '*');
                        """
                evaluateJavaScript(script)
        } catch {
            //defaultCallback?.onError(message: "Failed to initialize: \(error.localizedDescription)")
        }
    }
}

extension GlamArWebViewManager: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let args = message.body as? String else { return }
        print("web message: \(args)")
        
        do {
            if let data = args.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let type = json["type"] as? String {
                
                print("tag: WebView message Event received: \(type)")
                GlamArEventManager.shared.dispatchEvent(event: type, payload: json)
            }
        } catch {
            print("tag: WebView message: Error processing JS message: \(error)")
        }
    }
}

extension GlamArWebViewManager: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView finished loading")
        initPreview()
        isWebViewLoaded = true
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
