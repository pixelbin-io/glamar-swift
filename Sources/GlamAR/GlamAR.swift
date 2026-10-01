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
    
    /// Switches to VTO using the first nonblank category, subCategory, or skuId, in that order.
    public static func setExperience(experience: String, options: VtoExperienceOptions) {
        setExperienceInternal(experience: experience, options: options)
    }

    /// Switches to Skin Analysis using a nonblank appId.
    public static func setExperience(experience: String, options: SkinAnalysisExperienceOptions) {
        setExperienceInternal(experience: experience, options: options)
    }

    private static func setExperienceInternal(experience: String, options: ExperienceOptions) {
        if experience == "skinAnalysis" {
            let appId = normalizeExperienceValue((options as? SkinAnalysisExperienceOptions)?.appId)
            guard !appId.isEmpty else {
                failExperienceChange(experience: experience, error: "SkinAnalysis experience requires a valid appId")
                return
            }
            sendExperienceChange(experience: experience, options: ["appId": appId])
            return
        }

        guard experience == "vto" else {
            failExperienceChange(experience: experience, error: "Experience must be either vto or skinAnalysis")
            return
        }

        let vtoOptions = options as? VtoExperienceOptions
        for (key, value) in [
            ("category", vtoOptions?.category),
            ("subCategory", vtoOptions?.subCategory),
            ("skuId", vtoOptions?.skuId)
        ] {
            let normalizedValue = normalizeExperienceValue(value)
            if !normalizedValue.isEmpty {
                sendExperienceChange(experience: experience, options: [key: normalizedValue])
                return
            }
        }

        failExperienceChange(experience: experience, error: "VTO experience requires category, subCategory, or skuId")
    }

    private static func normalizeExperienceValue(_ value: String?) -> String {
        return value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private static func sendExperienceChange(experience: String, options: [String: String]) {
        postMessage(type: "setExperience", payload: [
            "experience": experience,
            "options": options
        ])
    }

    private static func failExperienceChange(experience: String, error: String) {
        print("GlamAr: \(error)")
        GlamArEventManager.shared.dispatchEvent(event: "experience-change-failed", payload: [
            "experience": experience,
            "error": error
        ])
    }

    public static func applySku(_ skuId: String) {
        evaluateJavascript(script: "window.parent.postMessage({ type: 'applyBySku', payload: { skuId: '\(skuId)' } }, '*');")
    }
    
    /// Applies a category with optional catalog settings.
    public static func applyByCategory(category: String, options: ApplyCatalogOptions? = nil) {
        applyCatalog(type: "applyByCategory", key: "category", value: category, options: options)
    }

    /// Applies a subcategory with optional catalog settings.
    public static func applyBySubCategory(subCategory: String, options: ApplyCatalogOptions? = nil) {
        applyCatalog(type: "applyBySubCategory", key: "subCategory", value: subCategory, options: options)
    }

    private static func applyCatalog(type: String, key: String, value: String, options: ApplyCatalogOptions?) {
        guard let options else {
            guard let jsonData = try? JSONEncoder().encode(value),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("GlamAr: Failed to serialize payload for \(type)")
                return
            }
            evaluateJavascript(script: "window.parent.postMessage({ type: '\(type)', payload: \(jsonString) }, '*');")
            return
        }

        var optionsPayload: [String: String] = [:]
        if let storeFront = options.storeFront {
            optionsPayload["storeFront"] = storeFront
        }
        postMessage(type: type, payload: [key: value, "options": optionsPayload])
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

    public static func configChange(
        type: String,
        value: Double? = nil,
        skuId: String? = nil,
        subCategory: String? = nil
    ) {
        var payload: [String: Any] = ["type": type]

        if let value {
            payload["value"] = value
        }

        if let skuId {
            payload["skuId"] = skuId
        }

        if let subCategory {
            payload["subCategory"] = subCategory
        }

        postMessage(type: "onConfigChange", payload: payload)
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

    public static func setViewportMirrored(state: Bool) {
        let option = state ? "start" : "close"
        postMessage(type: "mirrorMode", payload: ["options": option])
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
    
    public static func reset(_ value: Any? = nil) {
        sendClearSku(payload: normalizeClearSkuPayload(value))
    }

    private static func normalizeClearSkuPayload(_ value: Any?) -> [String: Any]? {
        guard let value else { return nil }

        if let subCategory = value as? String {
            return subCategory.isEmpty ? nil : ["subCategory": subCategory]
        }

        guard let options = value as? [String: Any] else { return nil }
        var payload: [String: Any] = [:]

        if let subCategory = options["subCategory"] as? String, !subCategory.isEmpty {
            payload["subCategory"] = subCategory
        }

        if let skuIds = options["skuIds"] as? [String], !skuIds.isEmpty {
            payload["skuIds"] = skuIds
        }

        return payload.isEmpty ? nil : payload
    }

    private static func sendClearSku(payload: [String: Any]?) {
        if let payload {
            postMessage(type: "clearSku", payload: payload)
        } else {
            evaluateJavascript(script: "window.parent.postMessage({ type: 'clearSku' }, '*');")
        }
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
