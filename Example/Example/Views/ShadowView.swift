//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit

@IBDesignable class ShadowView: UIView {
    
    @IBInspectable var shadowColor: UIColor? {
        set { layer.shadowColor = newValue!.cgColor }
        get { return layer.shadowColor?.uiColor }
    }

    @IBInspectable var shadowOpacity: Float {
        set { layer.shadowOpacity = newValue }
        get { return layer.shadowOpacity }
    }
    
    @IBInspectable var shadowOffset: CGPoint {
        set { layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y) }
        get { return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height) }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set { layer.shadowRadius = newValue }
        get { return layer.shadowRadius }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { return layer.cornerRadius  }
    }
}

fileprivate extension CGColor {
    var uiColor: UIKit.UIColor {
        return UIColor(cgColor: self)
    }
}
