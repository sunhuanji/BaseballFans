//
//  CustomizableButton.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit

@IBDesignable class CustomizableButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        
        didSet {
            
            layer.cornerRadius = cornerRadius
            
        }
        
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        
        didSet {
            
            layer.borderWidth = borderWidth
        }
        
    }
    
    @IBInspectable var borderColor: CGColor? = UIColor.white.cgColor {
        
        didSet {
            
            layer.borderColor = borderColor
        }
        
    }

}
