//
//  AppDelegate.swift
//  Mario
//
//  Created by Jan Sebastian on 03/06/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window?.rootViewController = BasicStageViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }

}

