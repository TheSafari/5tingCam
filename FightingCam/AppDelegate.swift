//
//  AppDelegate.swift
//  FightingCam
//
//  Created by Phuong Thao Tran on 3/15/17.
//  Copyright © 2017 TheSafari. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        var navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = uicolorFromHex(rgbValue: 0xffffff)
        navigationBarAppearace.barTintColor = uicolorFromHex(rgbValue: 0x000000)
        // change navigation item title color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        //color of status bar
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        setupRealm()
        migrateRealm()
        return true
    }
    
    private func setupRealm() {
        
        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!
        let bundleReamPath = Bundle.main.path(forResource: "default", ofType:"realm")

        
        do
        {
            try FileManager.default.copyItem(atPath: bundleReamPath!, toPath: defaultRealmPath.path)
        }
        catch let error as NSError {
            // Catch fires here, with an NSError being thrown
            print("error occurred, here are the details:\n \(error)")
        }
        
        //        if !FileManager.default.fileExists(atPath: defaultRealmPath.path) {
        //
        //        }
    }
    
    private func migrateRealm(){
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

}

