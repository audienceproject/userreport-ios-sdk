//
//  Copyright © 2017 UserReport. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// MARK: Property

@property (weak, nonatomic) IBOutlet UISwitch *testModeSwitch;

// Display mode buttons
@property (weak, nonatomic) IBOutlet UIButton *alertDisplayModeButton;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenDisplayModeButton;

// Display session info
@property (weak, nonatomic) IBOutlet UILabel *totalScreensLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedTotalScreensLabel;
@property (weak, nonatomic) IBOutlet UILabel *sessionScreensLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedSessionScreensLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedTotalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sessionTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedSessionTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *quarantineTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedQuarantineTimeLabel;

@end

