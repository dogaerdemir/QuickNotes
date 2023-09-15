//
//  UIViewController + Extension.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 9.09.2023.
//

import Foundation
import UIKit

extension UIViewController
{
    enum toastDisplayTime: Double {
        case short = 1.5
        case long = 3.0
    }
    
    func showToast(message : String, duration: toastDisplayTime)
    {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height - 200, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 12)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: duration.rawValue, options: .curveEaseOut, animations:{
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
