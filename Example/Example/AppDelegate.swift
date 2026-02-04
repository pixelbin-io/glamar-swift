//
//  AppDelegate.swift
//  Example
//
//  Created by Dipendra Sharma on 29/08/24.
//

import UIKit
import GlamAR

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("application did finish loaing")
        let overrides = GlamAROverrides(
            category: "skinanalysis",
            configuration: Configuration(skinAnalysis: SkinAnalysisConfig(appId: "38eec760-b8e2-4ef9-9dd1-67a89a678ff5")),
            meta: ["sdkVersion" : "2.0.0"]
        )
        GlamAr.initialize(accessKey: "c64b8d91-bdbb-4571-8585-16831f53d552", debug: true, bundleIdentifier: Bundle.main.bundleIdentifier ?? "", overrides: overrides)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

