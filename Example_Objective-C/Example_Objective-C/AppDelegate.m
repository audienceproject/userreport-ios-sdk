//
//  Copyright © 2017 UserReport. All rights reserved.
//

#import "AppDelegate.h"
#import <UserReportSDK/UserReportSDK-Swift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize UserReport SDK
    User *user = [[User alloc] init];
    [user setEmail:@"example@email.com"];
    [UserReport  configureWithSakId:@"audienceproject" mediaId:@"3402b774-b7a8-448c-997a-ef6cd59efc41" user:user settings:nil];
    return YES;
}

@end
