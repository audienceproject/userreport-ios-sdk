//
//  ShadowView.m
//  Example_Objective-C
//
//  Created by Babchenko Alexander on 8/22/19.
//  Copyright © 2019 UserReport. All rights reserved.
//

#import "ShadowView.h"

@implementation ShadowView

- (UIColor *)shadowColor {
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}
- (void)setShadowColor:(UIColor *)shadowColor {
    self.layer.shadowColor = [shadowColor CGColor];
}

- (CGFloat)shadowOpacity {
    return self.layer.shadowOpacity;
}
- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    self.layer.shadowOpacity = shadowOpacity;
}

- (CGPoint)shadowOffset {
    return CGPointMake(self.layer.shadowOffset.width, self.layer.shadowOffset.height);
}
- (void)setShadowOffset:(CGPoint)shadowOffset {
    self.layer.shadowOffset = CGSizeMake(shadowOffset.x, shadowOffset.y);
}

- (CGFloat)shadowRadius {
    return self.layer.shadowRadius;
}
- (void)setShadowRadius:(CGFloat)shadowRadius {
    self.layer.shadowRadius = shadowRadius;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}
- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}


@end
