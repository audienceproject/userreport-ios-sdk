//
//  Copyright © 2017 UserReport. All rights reserved.
//

import UIKit

class VerticalButton: UIButton {
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.centerTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.centerTitleLabel()
    }
    
    // MARK: Rects
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        let imageRect = super.imageRect(forContentRect: contentRect)
        return CGRect(x: 0, y: imageRect.maxY + 10, width: contentRect.width, height: rect.height)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)
        return CGRect(x: contentRect.width/2.0 - rect.width/2.0, y: (contentRect.height - titleRect.height)/2.0 - rect.height/2.0, width: rect.width, height: rect.height)
    }
    
    // MARK: Private methods
    
    private func centerTitleLabel() {
        self.titleLabel?.textAlignment = .center
    }
}
