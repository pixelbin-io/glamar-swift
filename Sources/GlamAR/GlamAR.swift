//
//  GlamAR.swift
//  GlamAR
//
//  Created by Dipendra Sharma on 09/08/24.
//

import Foundation

public class GlamAr {
    let accessKey: String
    let development: Bool
    public let api: GlamArApi
    
    private static var instance: GlamAr?
    
    private init(accessKey: String, development: Bool = true) {
        self.accessKey = accessKey
        self.development = development
        self.api = GlamArApi(accessKey: accessKey, development: development)
    }
    
    public static func initialize(accessKey: String, development: Bool = true) -> GlamAr {
        if instance == nil {
            instance = GlamAr(accessKey: accessKey, development: development)
        }
        return instance!
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
