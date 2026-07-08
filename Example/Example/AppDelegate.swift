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
//            category: "skinanalysis",
//            configuration: Configuration(skinAnalysis: SkinAnalysisConfig(appId: "38eec760-b8e2-4ef9-9dd1-67a89a678ff5")),
            meta: ["sdkVersion" : "2.0.0", "vto": [
              "multiTryon": true
          ]]
        )
        GlamAr.initialize(accessKey: "25cd4d7a-fe7d-4fc4-af1b-608414bf0c99", debug: true, bundleIdentifier: Bundle.main.bundleIdentifier ?? "", overrides: overrides)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

