//
//  Copyright © 2017 UserReport. All rights reserved.
//

#import "AppDelegate.h"
#import <UserReport/UserReport-Swift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize UserReport SDK
    User *user = [[User alloc] init];
    [user setEmail:@"example@email.com"];
    [UserReport configureWithSakId:@"ios-playground" mediaId:@"df5be674-b6a8-4bb8-8f44-4c8229a01bc2" user:user];
    
    return YES;
}

@end
