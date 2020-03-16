//
//  AppDelegate.swift
//  RecordingMVVM
//
//  Created by du on 2020/3/16.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    var coodinator: Coordinator?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = window?.rootViewController as? UISplitViewController
        splitViewController?.preferredDisplayMode = .allVisible
        splitViewController?.delegate = self
        coodinator = Coordinator(splitViewController!)
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

   


}

