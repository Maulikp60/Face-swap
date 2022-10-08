//
//  AppDelegate.m
//  FaceSwap
//
//  Created by MAC on 09/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "AppDelegate.h"
#import "StoreObserver.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Attach an observer to the payment queue
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[StoreObserver sharedInstance]];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Navigation"]
                                       forBarMetrics:UIBarMetricsDefault];

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    // COMMENT THESE LINES TO LOCK ADS AND SKIN COLOR
//    [userDefault setObject:@"1" forKey:KeyIsUnlockedAll];
//    [userDefault setObject:@"1" forKey:KeyIsUnlockedSkin];
//    [userDefault setObject:@"1" forKey:KeyIsUnlockedPro];
    //*****

    
    [self addLocalNotification];
    return YES;
}
-(void)addLocalNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:259200];//259200 Sec= 72 hours
    [localNotification setFireDate:now];
    [localNotification setTimeZone:[NSTimeZone localTimeZone]];
    [localNotification setAlertTitle:@"Faceswap: Hey, We are missing you!"];
    [localNotification setAlertBody:@"New photo editing tool is waiting for you!"];

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [self addLocalNotification];
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
   // NSLog(@"%@",__func__);
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
