//
//  RemoveAdsVC.h
//  FaceSwap
//
//  Created by MAC on 06/05/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdManager.h"
#import "StoreManager.h"
#import "MyModel.h"
#import "StoreObserver.h"
#import "LoadingView.h"

@interface RemoveAdsVC : UIViewController{
    
    __weak IBOutlet UIButton *btn_ObjUnlockPro;
    __weak IBOutlet UIButton *btn_ObjRemoveAds;
    __weak IBOutlet UIButton *btn_ObjSkinColor;
}
@property(nonatomic, strong) LoadingView *myLoadingView;

@end
