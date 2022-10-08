//
//  RemoveAdsVC.m
//  FaceSwap
//
//  Created by MAC on 06/05/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "RemoveAdsVC.h"


@interface RemoveAdsVC ()
{
    NSString *Purchase_type;
    BOOL RemoveAds,UnlockSkin,UnlockAll;
}
@end

@implementation RemoveAdsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //Be Ready for In-app purchase
    //*** InApp Purchase Method ***
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePurchasesNotification:)
                                                 name:IAPPurchaseNotification
                                               object:[StoreObserver sharedInstance]];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    RemoveAds = [self isPurchasedRemoveAds];
    UnlockAll = [self isPurchasedUnlockAll];
    UnlockSkin = [self isPurchasedUnlockSkinColor];
    if (UnlockAll  == true) {
        btn_ObjRemoveAds.hidden = true;
        btn_ObjSkinColor.hidden = true;
        btn_ObjUnlockPro.hidden  = true;
    }
    if (RemoveAds == true){
        btn_ObjRemoveAds.hidden = true;
    }
    if (UnlockSkin == true){
        btn_ObjSkinColor.hidden = true;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnClicked_UnlockPro:(id)sender {
    Purchase_type = @"All";
    [self showConfirmAlertForInapp:@"Unlock skin color tone &  Remove All Ads By Only $3.99" :2];
}
- (IBAction)btnClicked_SkinColor:(id)sender {
    Purchase_type = @"Skin";
    [self showConfirmAlertForInapp:@"Unlock skin color tone By Only $2.99" :0];
}
- (IBAction)btn_ClickedRemoveAds:(id)sender {
    Purchase_type = @"Ads";
    [self showConfirmAlertForInapp:@"Remove All Ads By Only $1.99" :1];
}
- (IBAction)btnClicked_CloseView:(id)sender {
    [self CloseView];
}
-(void)CloseView{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)buyProduct :(NSInteger)Type{
    NSArray *arr = [StoreManager sharedInstance].productRequestResponse;
    if (arr != nil && arr.count > 0){
        if (self.myLoadingView == nil)
            self.myLoadingView = [LoadingView loadingView];
        
        [self.myLoadingView startLoadingWithMessage:@"" inView:self.view];
        
        MyModel *model = arr[0];
        NSArray *productRequestResponse = model.elements;
        SKProduct *product = (SKProduct *)productRequestResponse[Type];
        
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
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)purchaseDone{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([Purchase_type  isEqual: @"All"]) {
        [userDefault setObject:@"1" forKey:KeyIsUnlockedAll];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedSkin];
        [userDefault setObject:@"1" forKey:KeyIsUnlockedPro];
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
    [self CloseView];
    
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
