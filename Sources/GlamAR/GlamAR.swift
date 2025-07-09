//
//  GlamAR.swift
//  GlamAR
//
//  Created by Dipendra Sharma on 09/08/24.
//

import Foundation
import UIKit
import WebKit

public class GlamAr {
    
    let accessKey: String
    let debug: Bool
    
    private static var instance: GlamAr?
    
    private init(accessKey: String,
                 debug: Bool = false,
                 bundleIdentifier: String,
                 overrides: GlamAROverrides? = nil,
                 webView: WKWebView? = nil) {
        self.accessKey = accessKey
        self.debug = debug
    }
    
    public static func initialize(accessKey: String,
                                  debug: Bool = false,
                                  bundleIdentifier: String,
                                  overrides: GlamAROverrides? = nil,
                                  webView: WKWebView? = nil) {
        if instance == nil {
            instance = GlamAr(accessKey: accessKey, debug: debug, bundleIdentifier: bundleIdentifier, overrides: overrides, webView: webView)
        }
        GlamArWebViewManager.shared.prepareWebView(debug: debug, bundleIdentifier: bundleIdentifier, overrides: overrides, providedWebView: webView)
    }
    
    public static func getInstance() throws -> GlamAr {
        guard let instance = instance else {
            throw GlamArError.notInitialized
        }
        return instance
    }
    
    // MARK: - Event Management
    public static func addEventListener(event: String, callback: @escaping (Any?) -> Void) {
        GlamArEventManager.shared.addEventListener(event: event, callback: callback)
    }
    
    public static func addEventListeners(_ listeners: [(String, (Any?) -> Void)]) {
        for (event, callback) in listeners {
            GlamArEventManager.shared.addEventListener(event: event, callback: callback)
        }
    }
    
    public static func removeEventListener(event: String) {
        GlamArEventManager.shared.removeEventListener(event: event)
    }
    
    // MARK: - JavaScript Interaction
    static func evaluateJavascript(script: String) {
        GlamArWebViewManager.shared.evaluateJavaScript(script)
    }
    
    public static func applySku(_ skuId: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'applyBySku', payload: { skuId: '\(skuId)' } }, '*');")
    }
    
    public static func applyPatternId(_ patternId: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'applyPatternByID', payload: { patternId: '\(patternId)' } }, '*');")
    }
    
    public static func open() {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'openLivePreview' }, '*');")
    }
    
    public static func openUploadMode(imgUrl: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'openLivePreview', payload: { mode: 'imgTryOn', imgURL: '\(imgUrl)' } }, '*');")
    }
    
    public static func close() {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'closePreview' }, '*');")
    }
    
    public static func snapshot() {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'snapshot' }, '*');")
    }
    
    public static func reset() {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'clearSku' }, '*');")
    }
    
    public static func isLoaded() -> Bool {
        return GlamArWebViewManager.shared.isWebViewLoaded
    }
    
    public static func comparison(option: String, value: String) {
        let script = """
            window.parent.postMessage({
                type: 'comparison',
                payload: {
                    options: '\(option)',
                    value: '\(value)'
                }
            }, '*');
            """
        evaluateJavascript(script: script)
    }
    
    public static func skinAnalysis(options: String, category: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'skin-analysis', payload: { options: '\(options)', value: '\(category)' } }, '*');")
    }
}

// Define a custom error type
public enum GlamArError: Error {
    case notInitialized
}
