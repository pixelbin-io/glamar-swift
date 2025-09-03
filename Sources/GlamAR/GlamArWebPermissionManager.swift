//
//  GlamArWebPermissionManager.swift
//  GlamAR
//
//  Created by Anitha Sangu on 03/09/25.
//

import WebKit
import AVFoundation

class GlamArWebPermissionManager {
    
    private init() {}
    
    static let instance = GlamArWebPermissionManager()
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            completion(true)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }

        default:
            completion(false)
        }
    }
}
