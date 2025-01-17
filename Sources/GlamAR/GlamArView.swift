import Foundation
import UIKit
import WebKit
import AVFoundation

public class GlamArView: UIView {
    
    private var skuApplied: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeWebView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeWebView()
    }
    
    func initializeWebView() {
        do {
            let glamAr = try GlamAr.getInstance()
            if (GlamArWebViewManager.shared.getPreparedWebView() == nil) {
                GlamArWebViewManager.shared.prepareWebView(debug: glamAr.debug)
            }
            
            
            startPreview(previewMode: GlamArWebViewManager.shared.previewMode)
        } catch {
            print("Error: GlamAr is not initialized. \(error.localizedDescription)")
        }
    }
    
    public func startPreview(previewMode: PreviewMode? = nil) {
        
        if case .camera = previewMode {
            checkCameraPermission()
        } else {
            reloadPage()
        }
    }
    
    func reloadPage() {
        
        if let webview = GlamArWebViewManager.shared.getPreparedWebView() {
            self.addSubview(webview)
            webview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                webview.topAnchor.constraint(equalTo: topAnchor),
                webview.leadingAnchor.constraint(equalTo: leadingAnchor),
                webview.trailingAnchor.constraint(equalTo: trailingAnchor),
                webview.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            print("webview added as subview")
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            reloadPage()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.reloadPage()
                    }
                } else {
                    DispatchQueue.main.async {
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
        GlamArWebViewManager.shared.defaultCallback?.onError(message: "Camera permission is required for this feature.")
    }
    
    
    private func evaluateJavaScript(_ script: String) {
        GlamArWebViewManager.shared.evaluateJavaScript(script)
    }
    
    public func setCallback(_ callback: GlamArViewCallback) {
        GlamArWebViewManager.shared.setGlamArCallback(callback: callback)
    }
    
    public func changeFaceAnalysisCategory(category: String) {
        evaluateJavaScript("window.parent.postMessage({ type: 'faceAnalysis' , payload: { options: 'changeCategory', value:'$category' }  }, '*');")
    }
    
    public func applySku(skuId: String, category: String) {
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
}

public protocol GlamArViewCallback: AnyObject {
    func onInitComplete()
    func onLoading()
    func onSkuApplied()
    func onSkuFailed()
    func onPhotoLoaded(payload: [String: Any])
    func onLoaded(mode: PreviewMode)
    func onOpened()
    func onError(message: String)
    func onFaceAnalysisCompleted(payload: [String: Any])
}

public enum PreviewMode {
    case none
    case image(String)
    case camera
    case faceAnalysis
}
