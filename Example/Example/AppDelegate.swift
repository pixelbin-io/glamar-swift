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
        GlamAr.initialize(accessKey: "ff4146c9-386a-463d-9b7d-4191bfa35c7f", debug: true, previewMode: PreviewMode.image("https://cdn.pixelbin.io/v2/glamar-fynd-835885/original/glamar-custom-data/models/makeup/2.jpg"))
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

