//
//  HUD.swift
//  Countries
//
//  Created by Syft on 05/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//


import UIKit
import MBProgressHUD


// A class to display a full screen view that blocks UI interaction when we're waiting on receiving something,
// a network request for example.
//
// HUD.show(in: view) to bring it up.
// HUD.dismiss(from: view) to take it down.
//
// 'view' would typically be the main window.
// So, something like HUD.show(to: view.window) or HUD.dismiss(from: view.window) when called from a view controler.

class HUD {
    
    @discardableResult
    class func show( in view: UIView, image: UIImage? = nil, message: String? = nil, animated: Bool = true, hideAfterDelay: TimeInterval? = nil ) -> MBProgressHUD {
        guard Thread.isMainThread else {
            var progressHUD: MBProgressHUD? = nil
            DispatchQueue.main.sync {
                progressHUD = HUD.show(in: view, image: image, message: message, animated: animated)
            }
            return progressHUD!
        }
        
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: animated)
        progressHUD.label.text = message
        progressHUD.removeFromSuperViewOnHide = true
        
        if let image = image {
            progressHUD.mode       = .customView
            progressHUD.customView = UIImageView(image: image)
            progressHUD.isSquare   = message == nil
        }
        
        if let hideAfterDelay = hideAfterDelay {
            progressHUD.hide(animated: animated, afterDelay: hideAfterDelay)
        }
        
        return progressHUD
    }
    
    class func dismiss( from view: UIView, animated: Bool = true, showingCheckmark: Bool = false ) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                HUD.dismiss(from: view, animated: animated, showingCheckmark: showingCheckmark)
            }
            return
        }

        MBProgressHUD.hide(for: view, animated: animated)
        
        if showingCheckmark {
            HUD.show(in: view, image: UIImage(named: "Checkmark"), animated: animated, hideAfterDelay: 1.0)
        }
    }
    
}
