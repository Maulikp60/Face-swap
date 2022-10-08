//
//  AdManager.h
//  iEditMyPhoto
//
//  Created by redoan on 2/16/14.
//  Copyright (c) 2014 AAPBD-REDOAN. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>
#import <GoogleMobileAds/GADBannerView.h>


//#define admob_bottom_banner @"ca-app-pub-6924646314674301/"
#define admob_interstitial @"ca-app-pub-6924646314674301/"



#define FlurryKey @""


@interface AdManager : NSObject<GADInterstitialDelegate>

+ (id)sharedInstance;

-(void)showAdmobFullscreen;
-(void)showAdmobSplahAd;
-(GADBannerView*)adMobBannerWithAdUnitID:(NSString*)adUnitID andOrigin:(CGPoint)origin;
- (GADRequest *)adMobrequest;


@property(nonatomic, strong) GADInterstitial *interstitial;
@end
