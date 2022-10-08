//
//  HomeVC.m
//  FaceSwap
//
//  Created by MAC on 09/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "HomeVC.h"
#import "MainControllerVC.h"
#import "SPUserResizableView.h"
#import "StoreManager.h"
#import "StoreObserver.h"
#import "AdManager.h"
#import "MyModel.h"
#import "RemoveAdsVC.h"
#import <AVFoundation/AVFoundation.h>
@interface HomeVC ()<GADInterstitialDelegate, GADBannerViewDelegate,AVAudioPlayerDelegate>
/// The interstitial ad.
@property(nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //    [self createAndLoadInterstitial];
    /*
    bannerView.adUnitID = @"ca-app-pub-6924646314674301/3926931476";
    bannerView.rootViewController = self;
    
    GADRequest *request =[GADRequest request];
    request.testDevices = @[kGADSimulatorID, @"165767c342277a5f982cc97daa66d946"];
    
    [bannerView loadRequest:request];
     bannerView.hidden = true;
    */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductRequestNotification:)
                                                 name:IAPProductRequestNotification
                                               object:[StoreManager sharedInstance]];
    
    // Fetch information about our products from the App Store
    [self fetchProductInformation];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true];
    [btnObj_Camera setImage:[UIImage imageNamed:@"camera roll icon"] forState:UIControlStateNormal];
    [btnObj_Library setImage:[UIImage imageNamed:@"from library icon"] forState:UIControlStateNormal];

    self.navigationController.navigationBarHidden = true;
    [btnObj_Camera setImage:[UIImage imageNamed:@"camera roll Selected"] forState:UIControlStateHighlighted];
    [btnObj_Library setImage:[UIImage imageNamed:@"from library Selected"] forState:UIControlStateHighlighted];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"NewFile"
                                         ofType:@"mp3"]];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:url
                   error:nil];
    audioPlayer.volume = 100.0f;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //   [audioPlayer play];
}


#pragma mark Fetch product information

// Retrieve product information from the App Store
-(void)fetchProductInformation
{
    // Query the App Store for product information if the user is is allowed to make purchases.
    // Display an alert, otherwise.
    if([SKPaymentQueue canMakePayments])
    {
        // Load the product identifiers fron ProductIds.plist
        NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"ProductIds" withExtension:@"plist"];
        NSArray *productIds = [NSArray arrayWithContentsOfURL:plistURL];
        
        [[StoreManager sharedInstance] fetchProductInformationForIds:productIds];
    }
    else
    {
        // Warn the user that they are not allowed to make purchases.
//        [self alertWithTitle:@"Warning" message:@"Purchases are disabled on this device."];
    }
}


#pragma mark Handle product request notification

// Update the UI according to the product request notification result
-(void)handleProductRequestNotification:(NSNotification *)notification
{
    StoreManager *productRequestNotification = (StoreManager*)notification.object;
    IAPProductRequestStatus result = (IAPProductRequestStatus)productRequestNotification.status;
    
    if (result == IAPProductRequestResponse)
    {
        // Switch to the iOSProductsList view controller and display its view
        //        [self cycleFromViewController:self.currentViewController toViewController:self.productsList];
        
        // Set the data source for the Products view
        //        [self.productsList reloadUIWithData:productRequestNotification.productRequestResponse];
        
        NSLog(@"IAPProductRequestResponse");
    }
}

#pragma mark - Ad Mob
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView;{
    NSLog(@"%s", __FUNCTION__);
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error;
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Button Touch Method
//- (IBAction)btnRemoveAdClicked:(id)sender {
//    [self.view addSubview:]
////    [self.navigationController setNavigationBarHidden:false];
////    RemoveAdsVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RemoveAdsVC"];
//////    [[self navigationController] pushViewController:VC animated:YES];
////    [self presentViewController:VC animated:YES completion:nil];
//    //    [self showConfirmAlertForInapp];
//}
- (IBAction)btnCameraClicked:(id)sender{
    //[self performSegueWithIdentifier:@"segueMainController" sender:nil];
//    [btnObj_Camera setImage:[UIImage imageNamed:@"camera roll Selected"] forState:UIControlStateNormal];
    if (picker == nil){
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
    }
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:true completion:nil];
    
}
- (IBAction)galleryClicked:(id)sender {
//    [btnObj_Library setImage:[UIImage imageNamed:@"from library Selected"] forState:UIControlStateNormal];
    if (picker == nil){
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.editing = true;
    }
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:true completion:nil];
}
- (IBAction)btnUnlockProClicked:(id)sender {
    NSArray *arr = [StoreManager sharedInstance].productRequestResponse;
    if (arr != nil && arr.count > 0){
        MyModel *model = arr[0];
        NSArray *productRequestResponse = model.elements;
        SKProduct *product = (SKProduct *)productRequestResponse[0];
        
        // Attempt to purchase the tapped product
        [[StoreObserver sharedInstance] buy:product];
        //[activityPurchase startAnimating];
    }else{
        NSLog(@"fail to get inapp purchase iteam");
    }
}
- (IBAction)panMain:(UISlider *)sender {
    NSLog(@"value %f",sender.value);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueMainController"]){
        MainControllerVC *mainVC = (MainControllerVC *)segue.destinationViewController;
        mainVC.myImage = myImage;
    }
}

#pragma mark - UIImagePickerViewController Delegate
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:true completion:^{
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        myImage = img;
        [self performSegueWithIdentifier:@"segueMainController" sender:nil];
    }];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1{
    [picker dismissViewControllerAnimated:true completion:nil];
}
#pragma Interstitial button actions

- (IBAction)playAgain:(id)sender {
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:self];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Interstitial not ready"
                                    message:@"The interstitial didn't finish loading or failed to load"
                                   delegate:self
                          cancelButtonTitle:@"Drat"
                          otherButtonTitles:nil] show];
    }
}

- (void)createAndLoadInterstitial {
    // ADMOB TEST UNIT ID = ca-app-pub-3940256099942544/4411468910
    // CLIENTS UNIT ID = ca-app-pub-6924646314674301/6880397873
    self.interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-6924646314674301/6880397873"];
    self.interstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADInterstitial automatically returns test ads when running on a
    // simulator.@"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
    
    request.testDevices = @[kGADSimulatorID,
                            @"165767c342277a5f982cc97daa66d946"
                            ];
    [self.interstitial loadRequest:request];
    
}

#pragma mark UIAlertViewDelegate implementation

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

#pragma mark GADInterstitialDelegate implementation

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidDismissScreen");
}
@end
