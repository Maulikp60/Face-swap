//
//  InAppPurchaseView.h
//  FaceSwap
//
//  Created by MAC on 17/05/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdManager.h"
#import "StoreManager.h"
#import "MyModel.h"
#import "StoreObserver.h"
#import "LoadingView.h"

@interface InAppPurchaseView : UIView
{
    NSString *Purchase_type;
    BOOL RemoveAds,UnlockSkin,UnlockAll;
    
    __weak IBOutlet UIView *innerView;
    __weak IBOutlet UIImageView *img_SkintonePrice;
    __weak IBOutlet UIImageView *img_RemoveSkincolortoneInside;
    __weak IBOutlet UIImageView *img_RemoveadsInside;
    
    __weak IBOutlet UIImageView *img_UnlockAdsPrice;
    __weak IBOutlet UIImageView *img_ProInside;
    __weak IBOutlet UIImageView *img_UnlockProPrice;
    
    __weak IBOutlet UIImageView *img_PurchaseAds;
    __weak IBOutlet UIImageView *img_PurchaseColortune;
    __weak IBOutlet UIImageView *img_PurchasePro;
}

@property(nonatomic, strong) LoadingView *myLoadingView;
-(NSString *)getType;
- (void)loadView;
@property UIViewController *delegate;
-(void)setPurchased;
-(void)setRestored :(NSString *)Type;
-(void)CancelPurchased;

@end
