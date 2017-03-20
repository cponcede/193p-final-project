//
//  StyleConstants.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/12/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import UIKit

// Static style constants used by a variety of view controllers.
class StyleConstants {
    static let headerColor = UIColor.init(red: 147.0/255, green: 215.0/255, blue: 188.0/255, alpha: 0.8)
    static let headerBackgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
    static let cellBackgroundColor = UIColor.darkGray
    static let cellTextColor = UIColor.lightText
    static let labelStyleAttributes : [String: Any] = [NSStrokeColorAttributeName : UIColor.black,
                                       NSForegroundColorAttributeName : UIColor.white,
                                       NSStrokeWidthAttributeName : -5.0]
}
