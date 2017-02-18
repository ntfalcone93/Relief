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
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UINavigationBar.appearance().tintColor = UIColor.yellow
        UINavigationBar.appearance().barTintColor = UIColor.reliefBlack()
        UITableViewCell.appearance().backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    }
    
}
