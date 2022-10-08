//
//  AdManager.m
//  iEditMyPhoto
//
//  Created by redoan on 2/16/14.
//  Copyright (c) 2014 AAPBD-REDOAN. All rights reserved.
//


#import "AdManager.h"

@interface AdManager ()
@end

@implementation AdManager



- (GADRequest *)adMobrequest
{
    GADRequest *request = [GADRequest request];
    request.testDevices = @[
                            kGADSimulatorID,
                            @"9481d65c607d68c867a51229a3c61340",
                            @"875ad2675fada537a4127ad98e24bf79",
                            @"9038FD057960843FD05D38EF2B979B91E77A55B5"
                            ];
    return request;
}

-(void)showAdmobFullscreen{
    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.delegate = self;
    self.interstitial.adUnitID = admob_interstitial;
    [self.interstitial loadRequest:[self adMobrequest]];
}

-(void)showAdmobSplahAd{
    GADInterstitial *splashInterstitial_ = [[GADInterstitial alloc] init];
    splashInterstitial_.adUnitID = admob_interstitial;
    [splashInterstitial_ loadRequest:[self adMobrequest]];
}

-(GADBannerView*)adMobBannerWithAdUnitID:(NSString*)adUnitID andOrigin:(CGPoint)origin
{
    //    GADAdSize custom = GADAdSizeFromCGSize(CGSizeMake(320, 200));// = GADAdSizeFullWidthPortraitWithHeight(60);
    
    
    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?kGADAdSizeLeaderboard:kGADAdSizeBanner origin:origin];
    
    bannerView.adUnitID = adUnitID;
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    //    NSLog(@"Stack = %@", [array objectAtIndex:0]);
    //    NSLog(@"Framework = %@", [array objectAtIndex:1]);
    //    NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    //    NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    //    NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    //    NSLog(@"Line caller = %@", [array objectAtIndex:5]);
    
    bannerView.rootViewController = [array objectAtIndex:3];
    
    [bannerView loadRequest:[[AdManager sharedInstance] adMobrequest]];
    
    return bannerView;
}

#pragma mark GADInterstitialDelegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    
    if ([self topViewController].isBeingPresented || [self topViewController].isBeingDismissed) {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self interstitialDidReceiveAd:interstitial];
        });
    }
    else {
        [self.interstitial presentFromRootViewController:[self topViewController]];
    }
    
}


- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    
    
    
}


+ (id)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    
    return _sharedObject;
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
@end
