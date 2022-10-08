//
//  SuperViewController.h
//  FaceSwap
//
//  Created by MAC on 11/03/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdManager.h"
#import "StoreManager.h"
#import "MyModel.h"
#import "StoreObserver.h"
#import "LoadingView.h"
#import "InAppPurchaseView.h"
@class InAppPurchaseView;

@interface SuperViewController : UIViewController{
    __weak IBOutlet UIButton *btnRemoveAds;
    
    __weak IBOutlet NSLayoutConstraint *bottom_viewMain;
    __weak IBOutlet NSLayoutConstraint *bottom_viewManualSwap;
    __weak IBOutlet NSLayoutConstraint *bottom_viewShareView;
    __weak IBOutlet NSLayoutConstraint *bottom_removeAds;
    __weak IBOutlet UIButton *btn_ColorTune;

    __weak IBOutlet UIButton *btn_ObjColorTuneMainView;

}

@property(nonatomic, strong) GADBannerView *banner;
@property(nonatomic, strong) LoadingView *myLoadingView;
@property(nonatomic, strong) InAppPurchaseView *myPurchase;

-(void)RemoveInAppPurchase;
-(BOOL)isPurchasedUnlockPro;
-(void)alertWithTitle:(NSString *)title message:(NSString *)message;
- (IBAction)btnRemoveAdClicked:(id)sender;
-(void)restore;
-(void)ColorTunePurchase;
-(void)UpdateConstain;
-(void)buyProduct :(NSInteger)Type;
@end
