//
//  Copyright © 2017 UserReport. All rights reserved.
//

#import "ViewController.h"
#import <UserReport/UserReport-Swift.h>

@interface ViewController ()
@property (nullable ,strong, nonatomic) NSTimer *timer;
@end

@implementation ViewController

// MARK: View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update navigationBar style and add logo
    [self setupNavigationBar];
    
    // Setup base state for testMode switch
    UserReport.shared.testMode = YES;
    self.testModeSwitch.on = UserReport.shared.testMode;
    
    
    // Setup base state for Display mode buttons
    BOOL isAlertMode = UserReport.shared.displayMode == DisplayModeAlert;
    self.alertDisplayModeButton.selected = isAlertMode;
    self.fullscreenDisplayModeButton.selected = !isAlertMode;
    
    [self updateSessionInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSessionInfo) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

// MARK: Setup views

- (void)setupNavigationBar {
    // Add logo
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_navigation_bar"]];
    self.navigationItem.titleView = logo;

    // Update style
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_white"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.3] CGColor];
    self.navigationController.navigationBar.layer.shadowRadius = 5.0;
    self.navigationController.navigationBar.layer.shadowOpacity = 1.0;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
}

// MARK: Update

- (void)updateSessionInfo {
    // Session information about the running time of the application and screen views
    Session *session = [[UserReport shared] session];
    if (session) {
        self.totalScreensLabel.text = [NSString stringWithFormat:@"%li screens", session.totalScreenView];
        self.sessionScreensLabel.text = [NSString stringWithFormat:@"%li screens", session.screenView];
        self.totalTimeLabel.text = [self stringFromTimeInterval:session.totalSecondsInApp];
        self.sessionTimeLabel.text = [self stringFromTimeInterval:session.sessionSeconds];
        self.quarantineTimeLabel.text = [NSString stringWithFormat:@"%li days", session.localQuarantineDays];
    }
    
    // Get current settings for appear survey
    Settings *settings = session.settings;
    if (settings) {
        self.expectedTotalScreensLabel.text = [NSString stringWithFormat:@"%li screens", settings.inviteAfterTotalScreensViewed];
        self.expectedSessionScreensLabel.text = [NSString stringWithFormat:@"%li screens", settings.sessionScreensView];
        self.expectedTotalTimeLabel.text = [self stringFromTimeInterval:settings.inviteAfterNSecondsInApp];
        self.expectedSessionTimeLabel.text = [self stringFromTimeInterval:settings.sessionNSecondsLength];
        self.expectedQuarantineTimeLabel.text = [NSString stringWithFormat:@"%li days", settings.localQuarantineDays];
    }
}

// MARK: Actions

- (IBAction)showUserReport:(id)sender {
    // Display manually
    [[UserReport shared] tryInvite];
}

- (IBAction)changeTestMode:(id)sender {
    [UserReport shared].testMode = self.testModeSwitch.isOn;
}

- (IBAction)selectAlertDisplayMode:(id)sender {
    NSLog(@"[CLICK]");

    // Change display mode survey in UserReport SDK
    UserReport.shared.displayMode = DisplayModeAlert;

    // Update buttons
    self.alertDisplayModeButton.selected = YES;
    self.fullscreenDisplayModeButton.selected = NO;
}

- (IBAction)selectFullscreenDisplayMode:(id)sender {

    // Change display mode survey in UserReport SDK
    UserReport.shared.displayMode = DisplayModeFullscreen;

    // Update buttons
    self.alertDisplayModeButton.selected = NO;
    self.fullscreenDisplayModeButton.selected = YES;
}

- (IBAction)trackScreen:(id)sender {
    [[UserReport shared] trackScreen];
    [self updateSessionInfo];
}

// MARK: Helpers

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}


@end
