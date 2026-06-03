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
    public let api: GlamArApi
    
    private static var instance: GlamAr?
    
    private init(accessKey: String,
                 debug: Bool = false,
                 bundleIdentifier: String,
                 overrides: GlamAROverrides? = nil,
                 webView: WKWebView? = nil) {
        self.accessKey = accessKey
        self.debug = debug
        self.api = GlamArApi(accessKey: accessKey, debug: debug)
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

    private static func postMessage(type: String, payload: [String: Any]) {
        guard JSONSerialization.isValidJSONObject(payload),
              let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("GlamAr: Failed to serialize payload for \(type)")
            return
        }

        evaluateJavascript(script: "window.parent.postMessage({ type: '\(type)', payload: \(jsonString) }, '*');")
    }
    
    public static func applySku(_ skuId: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'applyBySku', payload: { skuId: '\(skuId)' } }, '*');")
    }
    
    public static func applyByCategory(category: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'applyByCategory' , payload: '\(category)'  }, '*');")
    }
    
    public static func applyByMultipleConfigData(config: Any) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'applyByMultipleConfigData' , payload: '\(config)'  }, '*');")
    }
    
    public static func onAddedToCart(skuId: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'addedToCart',payload:$skuId } , '*');")
    }
    
    public static func onAddedToWishlist(skuId: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'addedToWishlist',payload:$skuId } , '*');")
    }
    
    public static func applyPatternId(_ patternId: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'applyPatternByID', payload: { patternId: '\(patternId)' } }, '*');")
    }

    public static func comparison(state: String, skus: [String]) {
        postMessage(type: "comparison", payload: [
            "state": state,
            "skus": skus
        ])
    }

    public static func onNailColorEvents(options: String? = nil, value: Any? = nil) {
        var payload: [String: Any] = [:]

        if let options {
            payload["options"] = options
        }

        if let value {
            payload["value"] = value
        }

        postMessage(type: "nailColor", payload: payload)
    }
    
    public static func open(mode: String? = nil, imgURL: String? = nil) {
        if(mode != nil) {
            evaluateJavascript(script: "window.parent.postMessage({ type: 'openLivePreview' , payload: { mode:'\(mode)', imgURL: '\(imgURL)' } }, '*');")
        } else {
            evaluateJavascript(script: "window.parent.postMessage({ type: 'openLivePreview' }, '*');")
        }
    }
    
    public static func close() {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'closePreview' }, '*');")
    }
    
    public static func back() {
        evaluateJavascript(script:  "window.parent.postMessage({ type: 'backPreview'}, '*');")
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
    
    public static func skinAnalysis(options: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'skinAnalysis' , payload: { options: '\(options)' }  }, '*');")
    }
    
    public static func eyePD(options: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'eyePD' , payload: { options: '\(options)' }  }, '*');")
    }
    
    public static func openUI(name: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'openUi' , payload: { name: '\(name)' }  }, '*');")
    }
}

// Define a custom error type
public enum GlamArError: Error {
    case notInitialized
}
