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
            category: "sunglasses",
            configuration: Configuration(global: GlobalConfig(disableClose: true, disableBack: false))
        )
        GlamAr.init(accessKey: "c1c91c71-b644-4df3-b660-7352ea13b80b", debug: false, bundleIdentifier: Bundle.main.bundleIdentifier ?? "", overrides: overrides)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

