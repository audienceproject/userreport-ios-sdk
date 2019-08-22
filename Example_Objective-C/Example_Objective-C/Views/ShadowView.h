//
//  ShadowView.h
//  Example_Objective-C
//
//  Created by Babchenko Alexander on 8/22/19.
//  Copyright © 2019 UserReport. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface ShadowView : UIView

@property (weak, nonatomic) IBInspectable UIColor *shadowColor;
@property (nonatomic) IBInspectable CGFloat shadowOpacity;
@property (nonatomic) IBInspectable CGPoint shadowOffset;
@property (nonatomic) IBInspectable CGFloat shadowRadius;
@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end

NS_ASSUME_NONNULL_END
