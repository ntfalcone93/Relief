//
//  AppearanceController.swift
//  Relief
//
//  Created by Dylan Slade on 4/20/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation

class AppearanceController {
    static func configureAppearance() {
        // set the default appearance of all view objets in the app
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UINavigationBar.appearance().tintColor = UIColor.yellowColor()
        UINavigationBar.appearance().barTintColor = UIColor.reliefBlack()
        UIButton.appearance().backgroundColor = UIColor.reliefYellow()
        UIButton.appearance().tintColor = UIColor.reliefBlack()
    }
}