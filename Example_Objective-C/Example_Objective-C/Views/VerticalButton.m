//
//  Copyright © 2017 UserReport. All rights reserved.
//

#import "VerticalButton.h"

@implementation VerticalButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self centerTitleLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self centerTitleLabel];
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super titleRectForContentRect:contentRect];
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    return CGRectMake(0, CGRectGetMaxY(imageRect) + 10, contentRect.size.width, rect.size.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super imageRectForContentRect:contentRect];
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    return CGRectMake(contentRect.size.width/2.0 - rect.size.width/2.0, (contentRect.size.height - titleRect.size.height)/2.0 - rect.size.height/2.0, rect.size.width, rect.size.height);
}

- (void)centerTitleLabel {
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end
