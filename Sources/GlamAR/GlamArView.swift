import Foundation
import UIKit
import WebKit
import AVFoundation

public class GlamArView: UIView, WKNavigationDelegate, WKScriptMessageHandler {
    private let prodBeautyHost = "https://websdk.glamar.io/"
    private let stagingBeautyHost = "https://websdk.glamarz0.de/"
    private let prodStyleHost = "https://fyndstyleweb.glamar.io/"
    private let stagingStyleHost = "https://fyndstyleweb.glamarz0.de/internal/index.html"
    
    private weak var defaultCallback: GlamArViewCallback?
    private var previewMode: PreviewMode = .none
    private var isBeauty: Bool = false
    private var skuApplied: String = ""
    
    private lazy var webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        config.allowsInlineMediaPlayback = true
        config.userContentController.add(self, name: "onLog")
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: bounds, configuration: config)
        webView.navigationDelegate = self
        return webView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        reloadPage()
    }
    
    public func startPreview(previewMode: PreviewMode? = nil, isBeauty: Bool? = nil) {
        if let newPreviewMode = previewMode {
            self.previewMode = newPreviewMode
        }
        
        let newIsBeauty = isBeauty ?? self.isBeauty
        if self.isBeauty != newIsBeauty {
            reloadPage(isBeauty: newIsBeauty)
        }
        self.isBeauty = newIsBeauty
        
        if case .camera = self.previewMode {
            checkCameraPermission()
        } else {
            reloadPage(isBeauty: newIsBeauty)
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            reloadPage(isBeauty: self.isBeauty)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.reloadPage(isBeauty: self?.isBeauty ?? false)
                    } else {
                        self?.handleCameraPermissionDenied()
                    }
                }
            }
        case .denied, .restricted:
            handleCameraPermissionDenied()
        @unknown default:
            handleCameraPermissionDenied()
        }
    }
    
    private func handleCameraPermissionDenied() {
        defaultCallback?.onError(message: "Camera permission is required for this feature.")
        // Optionally, show an alert to the user explaining why the camera is needed
        // and provide instructions on how to enable it in the device settings
    }
    
    public func reloadPage(isBeauty: Bool = false) {
        self.isBeauty = isBeauty
        let host: String
        
        do {
            let glamAr = try GlamAr.getInstance()
            if glamAr.development && self.isBeauty {
                host = stagingBeautyHost
            } else if glamAr.development && !self.isBeauty {
                host = stagingStyleHost
            } else if !glamAr.development && self.isBeauty {
                host = prodBeautyHost
            } else {
                host = prodStyleHost
            }
            
            if let url = URL(string: host) {
                webView.load(URLRequest(url: url))
            }
        } catch {
            print("Error: GlamAr is not initialized. \(error.localizedDescription)")
            host = prodStyleHost
            if let url = URL(string: host) {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    public func applySku(skuId: String, category: String) {
        if category.contains("beauty") != isBeauty {
            reloadPage(isBeauty: category.contains("beauty"))
        }
        self.skuApplied = skuId
        evaluateJavaScript("window.parent.postMessage({ type: 'applyBySku' , payload: { skuId: '\(skuId)' } }, '*');")
    }
    
    public func clear() {
        evaluateJavaScript("window.parent.postMessage({ type: 'clearSku'} , '*');")
    }
    
    public func configChange(options: String, value: Double? = nil) {
        let script: String
        if let value = value {
            script = "window.parent.postMessage({ type: 'configChange', payload: { options: '\(options)', value: '\(value)' }}, '*');"
        } else {
            script = "window.parent.postMessage({ type: 'configChange', payload: { options: '\(options)' }}, '*');"
        }
        evaluateJavaScript(script)
    }
    
    public func snapshot() {
        evaluateJavaScript("window.parent.postMessage({ type: 'snapshot'} , '*');")
    }
    
    public func toggle(showOriginal: Bool) {
        let script = showOriginal ?
        "window.parent.postMessage({type:'comparison', payload: {options: 'touch',value:'show'} }, '*');" :
        "window.parent.postMessage({type:'comparison', payload: {options: 'touch',value:'hide'} }, '*');"
        evaluateJavaScript(script)
    }
    
    private func evaluateJavaScript(_ script: String) {
        print(script)
        webView.evaluateJavaScript(script) { (result, error) in
            if let error = error {
                print("JavaScript evaluation error: \(error)")
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        initializeWebView()
    }
    
    private func initializeWebView() {
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
            }
            evaluateJavaScript(script)
        } catch {
            defaultCallback?.onError(message: "Failed to initialize: \(error.localizedDescription)")
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? String else { return }
        do {
            if let jsonData = body.data(using: .utf8),
               let dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let type = dict["type"] as? String {
                print(type)
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
                    if let payload = dict["payload"] as? [String: Any] {
                        defaultCallback?.onPhotoLoaded(payload: payload)
                    }
                case "loaded":
                    if !skuApplied.isEmpty {
                        evaluateJavaScript("window.parent.postMessage({ type: 'applyBySku' , payload: { skuId: '\(skuApplied)' } }, '*');")
                    }
                    defaultCallback?.onLoaded()
                case "error":
                    let errorMessage = (dict["message"] as? String) ?? "Unknown error occurred"
                    defaultCallback?.onError(message: errorMessage)
                default:
                    break
                }
            }
        } catch {
            print("Error processing JavaScript message: \(error)")
            defaultCallback?.onError(message: "Error processing JavaScript message: \(error.localizedDescription)")
        }
    }
    
    public func setCallback(_ callback: GlamArViewCallback) {
        self.defaultCallback = callback
    }
}

public protocol GlamArViewCallback: AnyObject {
    func onInitComplete()
    func onLoading()
    func onSkuApplied()
    func onSkuFailed()
    func onPhotoLoaded(payload: [String: Any])
    func onLoaded()
    func onOpened()
    func onError(message: String)
}

public enum PreviewMode {
    case none
    case image(String)
    case camera
}
