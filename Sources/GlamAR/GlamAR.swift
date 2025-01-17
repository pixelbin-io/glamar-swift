//
//  GlamAR.swift
//  GlamAR
//
//  Created by Dipendra Sharma on 09/08/24.
//

import Foundation
import UIKit

public class GlamAr {
    
    let accessKey: String
    let debug: Bool
    public let api: GlamArApi
    
    private static var instance: GlamAr?
    
    private init(accessKey: String, debug: Bool = true, previewMode: PreviewMode) {
        self.accessKey = accessKey
        self.debug = debug
        self.api = GlamArApi(accessKey: accessKey, debug: debug)
    }
    
    public static func initialize(accessKey: String, debug: Bool = true, previewMode: PreviewMode = .none) {
        if instance == nil {
            instance = GlamAr(accessKey: accessKey, debug: debug, previewMode: previewMode)
        }
        GlamArWebViewManager.shared.prepareWebView(debug: debug, previewMode: previewMode)
    }
    
    public static func getInstance() throws -> GlamAr {
        guard let instance = instance else {
            throw GlamArError.notInitialized
        }
        return instance
    }
}

// Define a custom error type
public enum GlamArError: Error {
    case notInitialized
}
