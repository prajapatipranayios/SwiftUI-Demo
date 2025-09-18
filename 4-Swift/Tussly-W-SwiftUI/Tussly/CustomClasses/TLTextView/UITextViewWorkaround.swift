//
//  UITextViewWorkaround.swift
//  To make TextView work on all iOS supported versions
//
//  Created by Jaimesh Patel on 14/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class UITextViewWorkaround: NSObject {
    
    // --------------------------------------------------------------------
    // MARK: Singleton
    // --------------------------------------------------------------------
    // make it a singleton
    static let unique = UITextViewWorkaround()

    // --------------------------------------------------------------------
    // MARK: executeWorkaround()
    // --------------------------------------------------------------------
    func executeWorkaround() {

        if #available(iOS 13.2, *) {

            NSLog("UITextViewWorkaround.unique.executeWorkaround(): we are on iOS 13.2+ no need for a workaround")

        } else {

            // name of the missing class stub
            let className = "_UITextLayoutView"

            // try to get the class
            var cls = objc_getClass(className)

            // check if class is available
            if cls == nil {

                // it's not available, so create a replacement and register it
                cls = objc_allocateClassPair(UIView.self, className, 0)
                objc_registerClassPair(cls as! AnyClass)

                #if DEBUG
                NSLog("UITextViewWorkaround.unique.executeWorkaround(): added \(className) dynamically")
               #endif
           }
        }
    }
}
