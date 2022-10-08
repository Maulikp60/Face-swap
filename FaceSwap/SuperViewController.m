//
//  SuperViewController.m
//  FaceSwap
//
//  Created by MAC on 11/03/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "SuperViewController.h"
#import "RemoveAdsVC.h"
@interface SuperViewController ()

@end

@implementation SuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePurchasesNotification:)
                                                 name:IAPPurchaseNotification
                                               object:[StoreObserver sharedInstance]];
    
    if (![self isPurchasedUnlockPro]){
        // Add Admob Banner
        self.banner = [[AdManager sharedInstance] adMobBannerWithAdUnitID:AdMobBannerUnitId andOrigin:(CGPoint){0, Y_Banner}];
        [self.view addSubview:self.banner];
        self.banner.backgroundColor = [UIColor blackColor];
        CGRect rect =self.banner.frame;
        rect.size.width = self.view.frame.size.width;
        self.banner.frame = rect;
        
    }else{
        
            btnRemoveAds.hidden = true;
            
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)UpdateConstain{
    if ([self isPurchasedUnlockPro]){
        [self.banner removeFromSuperview];
    }
    if ([self isPurchasedUnlockPro]){
        
            btnRemoveAds.hidden = true;
        
        if (bottom_viewMain != nil)
            bottom_viewMain.constant = 0;
        if (bottom_viewManualSwap != nil)
            bottom_viewManualSwap.constant = 0;
        if (bottom_viewShareView != nil){
            bottom_viewShareView.constant = 0;
        }
        [self.view setNeedsUpdateConstraints];
    }else{
        float bottomMargin = 0;
        if (self.view.frame.size.height <= 400){
            bottomMargin = 32;
        }else if (self.view.frame.size.height > 400 && self.view.frame.size.height <= 720){
            bottomMargin = 50;
        }else if (self.view.frame.size.height > 720){
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                bottomMargin = 50.0f;
            else
                bottomMargin = 90;
        }
        if (bottom_viewMain != nil)
            bottom_viewMain.constant = bottomMargin;
        if (bottom_viewManualSwap != nil)
            bottom_viewManualSwap.constant = bottomMargin;
        if (bottom_viewShareView != nil){
            bottom_viewShareView.constant = bottomMargin;
        }
        if (bottom_removeAds != nil){
            bottom_removeAds.constant = 150;//bottomMargin;
        }
        [self.view setNeedsUpdateConstraints];
    }
    if ([self isPurchasedUnlockPro]){
        if (bottom_viewMain != nil)
            bottom_viewMain.constant = 0;
        if (bottom_viewManualSwap != nil)
            bottom_viewManualSwap.constant = 0;
        if (bottom_viewShareView != nil){
            bottom_viewShareView.constant = 0;
        }
        [self.view setNeedsUpdateConstraints];
    }else{
        CGRect rect =self.banner.frame;
        CGRect rectViewFrame = self.view.frame;
        rect.origin.y = rectViewFrame.size.height - rect.size.height;
        self.banner.frame = rect;
    }
    [self.view setNeedsDisplay];
    [self.view setNeedsDisplayInRect:self.view.frame];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self UpdateConstain];
}
#pragma mark - Button Touch up Method
- (IBAction)btnRemoveAdClicked:(id)sender {
    [self RemoveInAppPurchase];
    
}
-(void)RemoveInAppPurchase{
    InAppPurchaseView *myxibView;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        myxibView = [[[NSBundle mainBundle] loadNibNamed:@"InappPurchaseIpad" owner:self options:nil] objectAtIndex:0];
        /*myxibView.backgroundColor = [UIColor clearColor];
        if (self.navigationController.navigationBarHidden == true ) {
            myxibView.frame =self.view.frame;
        }else{
            myxibView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height+self.navigationController.navigationBar.frame.size.height+20);
        }
        myxibView.hidden = true;
        
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = myxibView.bounds;
        [myxibView addSubview:visualEffectView];
        
        
        myxibView .delegate= self;
        [myxibView loadView];
        
        [self.navigationController.view addSubview:myxibView];
        
        CATransition *transition = [[CATransition alloc] init];
        transition.startProgress = 0.0f;
        transition.endProgress = 1.0f;
        transition.duration = 0.4f;
        transition.type = kCATransitionPush;
        
        transition.subtype = kCATransitionFromTop;
        [myxibView.layer addAnimation:transition forKey:@"opacity"];
        myxibView.hidden = false;
        
        _myPurchase = myxibView;*/
    }else if  ([[UIScreen mainScreen] bounds].size.height == 480.0f){
        myxibView = [[[NSBundle mainBundle] loadNibNamed:@"InApppurchase4" owner:self options:nil] objectAtIndex:0];
    }
    else{
       myxibView = [[[NSBundle mainBundle] loadNibNamed:@"InAppPurchase" owner:self options:nil] objectAtIndex:0];
    }
    if (self.navigationController.navigationBarHidden == true ) {
        myxibView.frame =self.view.frame;
    }else{
        myxibView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height+self.navigationController.navigationBar.frame.size.height+20);
    }
    myxibView.hidden = true;
    
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = myxibView.bounds;
    [myxibView addSubview:visualEffectView];
    myxibView .delegate= self;
    [myxibView loadView];
    [self.navigationController.view addSubview:myxibView];
    
    
    CATransition *transition = [[CATransition alloc] init];
    transition.startProgress = 0.0f;
    transition.endProgress = 1.0f;
    transition.duration = 0.4f;
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromTop;
    [myxibView.layer addAnimation:transition forKey:@"opacity"];
    myxibView.hidden = false;
    _myPurchase = myxibView;
    
    //    [self.navigationController setNavigationBarHidden:false];
    //    RemoveAdsVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RemoveAdsVC"];
    ////    [[self navigationController] pushViewController:VC animated:YES];
    //    [self presentViewController:VC animated:YES completion:nil];
    //    [self showConfirmAlertForInapp];
}
//-(void)showConfirmAlertForInapp{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
//                                                                   message:@"Remove All Ads By Only $0.99"
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
//                                                            style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              [self buyProduct];
//                                                          }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
//                                                            style:UIAlertActionStyleCancel
//                                                          handler:^(UIAlertAction * action) {
//
//                                                          }];
//    [alert addAction:defaultAction];
//    [alert addAction:cancelAction];
//
//    [self presentViewController:alert animated:YES completion:nil];
//}
//
//-(void)buyProduct{
//    NSArray *arr = [StoreManager sharedInstance].productRequestResponse;
//    if (arr != nil && arr.count > 0){
//        if (self.myLoadingView == nil)
//            self.myLoadingView = [LoadingView loadingView];
//
//        [self.myLoadingView startLoadingWithMessage:@"" inView:self.view];
//
//        MyModel *model = arr[0];
//        NSArray *productRequestResponse = model.elements;
//        SKProduct *product = (SKProduct *)productRequestResponse[0];
//
//        // Attempt to purchase the tapped product
//        [[StoreObserver sharedInstance] buy:product];
//        //[activityPurchase startAnimating];
//    }else{
//        NSLog(@"fail to get inapp purchase iteam");
//    }
//}
//-(void)buyColorTune{
//    NSArray *arr = [StoreManager sharedInstance].productRequestResponse;
//    if (arr != nil && arr.count > 0){
//        if (self.myLoadingView == nil)
//            self.myLoadingView = [LoadingView loadingView];
//
//        [self.myLoadingView startLoadingWithMessage:@"" inView:self.view];
//
//        MyModel *model = arr[0];
//        NSArray *productRequestResponse = model.elements;
//        SKProduct *product = (SKProduct *)productRequestResponse[0];
//
//        // Attempt to purchase the tapped product
//        [[StoreObserver sharedInstance] buy:product];
//        //[activityPurchase startAnimating];
//    }else{
//        NSLog(@"fail to get inapp purchase iteam");
//    }
//}
//- (IBAction)btnGetColorTune:(id)sender {
//    NSArray *arr = [StoreManager sharedInstance].productRequestResponse;
//    if (arr != nil && arr.count > 0){
//        if (self.myLoadingView == nil)
//            self.myLoadingView = [LoadingView loadingView];
//
//        [self.myLoadingView startLoadingWithMessage:@"" inView:self.view];
//
//        MyModel *model = arr[1];
//        NSArray *productRequestResponse = model.elements;
//        SKProduct *product = (SKProduct *)productRequestResponse[0];
//
//        // Attempt to purchase the tapped product
//        [[StoreObserver sharedInstance] buy:product];
//        //[activityPurchase startAnimating];
//    }else{
//        NSLog(@"fail to get inapp purchase iteam");
//    }
//
//}
//-(void)restore{
//    [[StoreObserver sharedInstance] restore];
//}
#pragma mark Display message

-(void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)purchaseDone :(NSString *)Purchase_Type{
    if ([Purchase_Type   isEqual: @"Purchase"]) {
        NSLog(@"Mypurchase value : %@", [_myPurchase getType]);
        [_myPurchase setPurchased];
        if ([[_myPurchase getType] isEqualToString:@"Ads"] || [[_myPurchase getType] isEqualToString:@"All"] ){
            btnRemoveAds.hidden = true;
            [self.banner removeFromSuperview];
            
            if (bottom_viewMain != nil)
                bottom_viewMain.constant = 0;
            if (bottom_viewManualSwap != nil)
                bottom_viewManualSwap.constant = 0;
            if (bottom_viewShareView != nil)
                bottom_viewShareView.constant = 0;
            [self.view setNeedsUpdateConstraints];
            if ([[_myPurchase getType] isEqualToString:@"All"]) {
                [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
                [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
                
                [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];
                [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];        }
            
        }else if([[_myPurchase getType] isEqualToString:@"Ads"]|| [[_myPurchase getType] isEqualToString:@"Skin"])
        {
            [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
            [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
            
            [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];
            [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];
        }

    }else{
        NSString *Restore_Type;
        NSLog(@"Mypurchase value : %@", Purchase_Type);
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ProductIds" ofType:@"plist"];
        NSArray *arrProductIdentifier = [NSArray arrayWithContentsOfFile:path];
        
        for (int i = 0; i < arrProductIdentifier.count; i++) {
            if ([arrProductIdentifier[i]  isEqual: Purchase_Type]) {
                if (i == 0) {
                    Restore_Type = @"Ads";
                }else if (i == 1){
                    Restore_Type = @"Skin";
                }else if (i == 2){
                    Restore_Type = @"All";
                }else{
                    
                }
                [_myPurchase setRestored:Restore_Type];
                break;
            }else{
                
            }
        }
        
        if ([Restore_Type isEqualToString:@"Ads"] || [Restore_Type isEqualToString:@"All"] ){
            btnRemoveAds.hidden = true;
            [self.banner removeFromSuperview];
            
            if (bottom_viewMain != nil)
                bottom_viewMain.constant = 0;
            if (bottom_viewManualSwap != nil)
                bottom_viewManualSwap.constant = 0;
            if (bottom_viewShareView != nil)
                bottom_viewShareView.constant = 0;
            [self.view setNeedsUpdateConstraints];
            if ([Restore_Type isEqualToString:@"All"]) {
                [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
                [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
                
                [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];
                [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];        }
            
        }else if([Restore_Type isEqualToString:@"Ads"]|| [Restore_Type isEqualToString:@"Skin"])
        {
            [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
            [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
            
            [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];
            [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];    }

    }
    
}
#pragma mark Handle purchase request notification

// Update the UI according to the purchase request notification result
-(void)handlePurchasesNotification:(NSNotification *)notification
{
    StoreObserver *purchasesNotification = (StoreObserver *)notification.object;
    
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus)purchasesNotification.status;
    
    [self.myLoadingView stopLoading];
    switch (status)
    {
        case IAPPurchaseFailed:
             [_myPurchase CancelPurchased];
            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            
            break;
            // Switch to the iOSPurchasesList view controller when receiving a successful restore notification
        case IAPPurchaseSucceeded:
        {
            [self purchaseDone : @"Purchase"];
            [self alertWithTitle:@"Purchase Status" message:@"You successfully Purchase."];
        }
        case IAPRestoredSucceeded:
        {
            NSLog(@"IAPRestoredSucceeded %@",purchasesNotification.purchasedID);
            
            [self purchaseDone :purchasesNotification.purchasedID];
            [self alertWithTitle:@"Purchase Status" message:@"You successfully restore purchase."];
        }
            break;
        case IAPRestoredFailed:
            [_myPurchase CancelPurchased];

            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            break;
            // Notify the user that downloading is about to start when receiving a download started notification
        case IAPDownloadStarted:
            break;
            // Display a status message showing the download progress
        case IAPDownloadInProgress:
            break;
            // Downloading is done, remove the status message
        case IAPDownloadSucceeded:
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)isPurchasedUnlockPro{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedPro] != nil){
        return true;
    }else{
        return false;
    }
}

-(BOOL)isPurchasedUnlockAll{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedAll] != nil){
        return true;
    }else{
        return false;
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
