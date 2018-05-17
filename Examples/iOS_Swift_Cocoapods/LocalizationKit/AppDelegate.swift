//
//  AppDelegate.swift
//  LocalizationKit
//
//  Created by Will Powell on 11/08/2016.
//  Copyright (c) 2016 Will Powell. All rights reserved.
//

import UIKit
import LocalizationKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // DEFINING APP SETTINGS DEFAULTS
        var appDefaults = Dictionary<String, AnyObject>()
        appDefaults["live_localization"] = true as AnyObject?;
        UserDefaults.standard.register(defaults: appDefaults)
        UserDefaults.standard.synchronize()
        
        
        let str = Localization.parse(str:"Name*")
        let str2 = Localization.parse(str:"Hello how are you !?>")
        print("\(str)")
        print("\(str2)")
        // LOCALIZATION KIT START DEFINED HERE
        Localization.ifEmptyShowKey = true
        Localization.start(appKey: "0509b42d-d783-4084-8f91-aeaf0c94595a", useSettings:true)
        Localization.availableLanguages { (languages) in
            print("Languages");
        }
        //
        // Other options
        // Localization.start(appKey: "407f3581-648e-4099-b761-e94136a6628d", live:true) - to run live mode regardless
        //
        // LOCALIZATION KIT END DEFINED
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

