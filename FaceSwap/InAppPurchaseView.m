//
//  InAppPurchaseView.m
//  FaceSwap
//
//  Created by MAC on 17/05/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "InAppPurchaseView.h"
#import "SuperViewController.h"
#import "MainControllerVC.h"
@implementation InAppPurchaseView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)loadView // This is where you put your own loading view information, and set the viewController's self.view property here.
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handlePurchasesNotification:)
//                                                 name:IAPPurchaseNotification
//                                               object:[StoreObserver sharedInstance]];
    innerView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:KeyIsUnlockedAll]  isEqual: @"1"]) {
        img_UnlockAdsPrice.image = [UIImage imageNamed:@"remove ads purchased"];
        img_SkintonePrice.image  = [UIImage imageNamed:@"SKIN COLOR TUNE Purchased"];
        img_UnlockProPrice.image  = [UIImage imageNamed:@"unlock pro purchased"];
    }else{
        
    }
    if  ([[userDefault objectForKey:KeyIsUnlockedSkin]  isEqual: @"1"]){
        img_SkintonePrice.image  = [UIImage imageNamed:@"SKIN COLOR TUNE Purchased"];
    }else{
        
    }
    if  ([[userDefault objectForKey:KeyIsUnlockedPro]  isEqual: @"1"]){
        img_UnlockAdsPrice.image  = [UIImage imageNamed:@"remove ads purchased"];
    }else{
        
    }
}
-(void)setPurchased{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if([Purchase_type isEqualToString:@"Ads"]){
        img_UnlockAdsPrice.image  = [UIImage imageNamed:@"remove ads purchased"];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedPro];
    }
    if([Purchase_type isEqualToString:@"Skin"]){
        img_SkintonePrice.image  = [UIImage imageNamed:@"SKIN COLOR TUNE Purchased"];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedSkin];
    }
    if([Purchase_type isEqualToString:@"All"]){
        img_UnlockAdsPrice.image = [UIImage imageNamed:@"remove ads purchased"];
        img_SkintonePrice.image  = [UIImage imageNamed:@"SKIN COLOR TUNE Purchased"];
        img_UnlockProPrice.image  = [UIImage imageNamed:@"unlock pro purchased"];
        
        [userDefault setObject:@"1" forKey:KeyIsUnlockedAll];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedSkin];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedPro];
    }
    [self.myLoadingView stopLoading];
}
-(void)setRestored :(NSString *)Type{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if([Type isEqualToString:@"Ads"]){
        img_UnlockAdsPrice.image  = [UIImage imageNamed:@"remove ads purchased"];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedPro];
    }
    if([Type isEqualToString:@"Skin"]){
        img_SkintonePrice.image  = [UIImage imageNamed:@"SKIN COLOR TUNE Purchased"];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedSkin];
    }
    if([Type isEqualToString:@"All"]){
        img_UnlockAdsPrice.image = [UIImage imageNamed:@"remove ads purchased"];
        img_SkintonePrice.image  = [UIImage imageNamed:@"SKIN COLOR TUNE Purchased"];
        img_UnlockProPrice.image  = [UIImage imageNamed:@"unlock pro purchased"];
        
        [userDefault setObject:@"1" forKey:KeyIsUnlockedAll];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedSkin];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedPro];
    }
    [self.myLoadingView stopLoading];
}
-(void)CancelPurchased{
     [self.myLoadingView stopLoading];
}
-(NSString *)getType;{
    return  Purchase_type;
}
- (IBAction)btnClicked_UnlockPro:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:KeyIsUnlockedAll]  isEqual: @"1"]) {
    }else{
        Purchase_type = @"All";
        [self showConfirmAlertForInapp:@"Unlock skin color tone &  Remove All Ads By Only $3.99" :2];
    }
}
- (IBAction)btnClicked_SkinColor:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if  ([[userDefault objectForKey:KeyIsUnlockedSkin]  isEqual: @"1"]){
    }else{
        Purchase_type = @"Skin";
        [self showConfirmAlertForInapp:@"Unlock skin color tone By Only $2.99" :1];
    }
}
- (IBAction)btn_ClickedRemoveAds:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if  ([[userDefault objectForKey:KeyIsUnlockedPro]  isEqual: @"1"]){
        
    }else{
        Purchase_type = @"Ads";
        [self showConfirmAlertForInapp:@"Remove All Ads By Only $1.99" :0];
    }
}
#pragma mark - Button Touch up Method
-(void)showConfirmAlertForInapp :(NSString *)Message :(NSInteger)type{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:Message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self buyProduct:type];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                         }];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self.delegate presentViewController:alert animated:YES completion:nil];
}
-(void)buyProduct :(NSInteger)Type{
    NSArray *arr = [StoreManager sharedInstance].productRequestResponse;
    if (arr != nil && arr.count > 0){
        if (self.myLoadingView == nil)
            self.myLoadingView = [LoadingView loadingView];
        
        [self.myLoadingView startLoadingWithMessage:@"" inView:self];

        NSString *path = [[NSBundle mainBundle] pathForResource:@"ProductIds" ofType:@"plist"];
        NSArray *arrProductIdentifier = [NSArray arrayWithContentsOfFile:path];
        NSString *PurchaseProductId = arrProductIdentifier[Type];
        MyModel *model = arr[0];
        NSArray *productRequestResponse = model.elements;
        SKProduct *product = (SKProduct *)productRequestResponse[Type];
        for (int i = 0; i < productRequestResponse.count; i++) {
            product = (SKProduct *)productRequestResponse[i];
            if ([product.productIdentifier  isEqual: PurchaseProductId]) {
                break;
            }
        }
        
        // Attempt to purchase the tapped product
        [[StoreObserver sharedInstance] buy:product];
        //[activityPurchase startAnimating];
    }else{
        NSLog(@"fail to get inapp purchase iteam");
    }
}
-(void)restore{
    [[StoreObserver sharedInstance] restore];
}
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
    [self.delegate presentViewController:alert animated:YES completion:nil];
    
    //    [self presentViewController:alert animated:YES completion:nil];
}

-(void)purchaseDone{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([Purchase_type  isEqual: @"All"]) {
        [userDefault setObject:@"1" forKey:KeyIsUnlockedAll];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedSkin];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedPro];
        img_UnlockAdsPrice.image = [UIImage imageNamed:@"remove ads purchased"];
        img_SkintonePrice.image  = [UIImage imageNamed:@"SKIN COLOR TUNE Purchased"];
        img_UnlockProPrice.image  = [UIImage imageNamed:@"unlock pro purchased"];
    }else if ([Purchase_type  isEqual: @"Skin"]){
        [userDefault setObject:@"1" forKey:KeyIsUnlockedSkin];
        if ([userDefault valueForKey:KeyIsUnlockedPro] != nil){
            [userDefault setObject:@"1" forKey:KeyIsUnlockedAll];
        }else{
        }
    }else if ([Purchase_type  isEqual: @"Ads"]){
        [userDefault setObject:@"1" forKey:KeyIsUnlockedPro];
        if ([userDefault valueForKey:KeyIsUnlockedSkin] != nil){
            [userDefault setObject:@"1" forKey:KeyIsUnlockedAll];
        }else{
            
        }
    }else{
    }
    [userDefault synchronize];
    [self loadView];
    [self.myLoadingView stopLoading];
    
    
    //SuperViewController *Obj_Super  =[[ SuperViewController alloc] init];
    
    
//    MainControllerVC *Obj_main  =[[MainControllerVC alloc] init];
//    [Obj_Super.view setNeedsDisplay];
//    [Obj_main.view setNeedsDisplay];
//    [Obj_main UPdateImage];
//    [Obj_Super.view setNeedsDisplay];
//    [Obj_main.view setNeedsDisplay];
    [self removeFromSuperview];
  
    //    if ([self isPurchasedUnlockPro]){
    //        if (bottom_viewMain != nil)
    //            bottom_viewMain.constant = 0;
    //        if (bottom_viewManualSwap != nil)
    //            bottom_viewManualSwap.constant = 0;
    //        if (bottom_viewShareView != nil)
    //            bottom_viewShareView.constant = 0;
    //        [self.view setNeedsUpdateConstraints];
    //    }
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
            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            break;
            // Switch to the iOSPurchasesList view controller when receiving a successful restore notification
        case IAPPurchaseSucceeded:
        {
            [self purchaseDone];
            if ([Purchase_type  isEqual: @"All"]) {
                [self alertWithTitle:@"Purchase Status" message:@"You successfully Unlock Pro."];
            }else if ([Purchase_type  isEqual: @"Skin"]){
                [self alertWithTitle:@"Purchase Status" message:@"You successfully Skin Color Tone."];
            }else if ([Purchase_type  isEqual: @"Ads"]){
                [self alertWithTitle:@"Purchase Status" message:@"You successfully Remove Ads."];
            }else{
                
            }
        }
        case IAPRestoredSucceeded:
        {
            NSLog(@"IAPRestoredSucceeded");
            [self purchaseDone];
            [self alertWithTitle:@"Purchase Status" message:@"You successfully restore purchase."];
        }
            break;
        case IAPRestoredFailed:
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
-(BOOL)isPurchasedUnlockAll{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedAll] != nil){
        return true;
    }else{
        return false;
    }
}
-(BOOL)isPurchasedRemoveAds{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedPro] != nil){
        return true;
    }else{
        return false;
    }
}

-(BOOL)isPurchasedUnlockSkinColor{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedSkin] != nil){
        return true;
    }else{
        return false;
    }
}

- (IBAction)btnCloseView:(id)sender {
    [self removeFromSuperview];
}

@end
