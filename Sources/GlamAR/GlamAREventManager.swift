//
//  File.swift
//  GlamAR
//
//  Created by Anitha Sangu on 30/06/25.
//

import Foundation

public typealias GlamArEventCallback = (Any?) -> Void

public class GlamArEventManager {
    
    // MARK: - Singleton
    public static let shared = GlamArEventManager()
    private init() {}
    
    // MARK: - Listener Storage
    private var eventListeners: [String: GlamArEventCallback] = [:]

    /// Register a single event listener
    public func addEventListener(event: String, callback: @escaping GlamArEventCallback) {
        eventListeners[event] = callback
    }

    /// Register multiple event listeners at once
    public func addEventListeners(_ listeners: [(String, GlamArEventCallback)]) {
        for (event, callback) in listeners {
            eventListeners[event] = callback
        }
    }

    /// Remove a listener for a specific event
    public func removeEventListener(event: String) {
        eventListeners.removeValue(forKey: event)
    }

    /// Clear all listeners (e.g., when WebView is destroyed)
    public func clearAllListeners() {
        eventListeners.removeAll()
    }

    /// Internal: Dispatch an event to the registered listener
    public func dispatchEvent(event: String, payload: Any?) {
        if let listener = eventListeners[event] {
            listener(payload)
        } else {
            
        }
    }
}
