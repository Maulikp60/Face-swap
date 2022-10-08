//
//  MainControllerVC.m
//  FaceSwap
//
//  Created by MAC on 09/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "MainControllerVC.h"
#import "ShareVC.h"
#import <ImageIO/ImageIO.h>
#import "SPUserResizableView.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "AVFoundation/AVAudioPlayer.h"
#import <AudioToolbox/AudioServices.h>
#import "EAGLView.h"
#import "ImageFilter.h"
#import "RemoveAdsVC.h"
@import GoogleMobileAds;

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@interface MainControllerVC ()<UIGestureRecognizerDelegate, UIScrollViewDelegate,GADInterstitialDelegate,MFMailComposeViewControllerDelegate,AVAudioPlayerDelegate>
/// The interstitial ad.
{
    AVAudioPlayer *audioPlayer;
    NSInteger Tag_MaskDetail,DeleteFaceTag;
    UIPanGestureRecognizer *panGesture_Face;
    NSString *ManualSwapX;
    NSMutableArray *arr_FaceWidth,*arr_FaceHeight,*arr_FaceX,*arr_FaceY,*arr_Rotation;
    UIView *borderView;
    CAShapeLayer *shapeLayer;
    UIButton *button_Cancel,*buttonCopy;
    BOOL IS_FlipedImage;
}
@property(nonatomic, strong) GADInterstitial *interstitial;

@end


@implementation MainControllerVC{
    CGFloat firstX,firstXMain;
    CGFloat firstY,firstYMain;
    NSMutableArray *faces;
    UIImage *finalImage;
    UIImage *sharableImage;
    CGFloat fixWidth;
    CGFloat aspectHeight;
    
    // For Manual Control
    NSMutableArray *arrManualSwappedFaces;
    NSMutableArray *arrFacesOriginal;
    
    NSMutableArray *arrFeatures,*arr_FaceColor,*arr_sliderValue_Brightness,*arr_FaceAutoSwap,*arr_FaceManualSwap,*arr_SliderValue_Brightness_Manual,*arr_sliderValue_Color,*arr_sliderValue_Color_Manual;
    UIImage *selectedMaskImage;
    UIImage *maskToApply;
    
    UIPanGestureRecognizer *panMain;
    CGRect preImageRect;
    
    NSMutableArray *faceImages;
    UIImage *rotatedImage;
    NSMutableArray *arrMirroredface;
    
    BOOL isSideFace;
    BOOL isLeftSide;
    CGFloat xScale;
    CGFloat yScale;
    
    CGRect preRect;
    CGRect lastRect;
    
    BOOL isSameOrientation,isfirstTime;
    UITapGestureRecognizer *tapForSetting;
    int SwipeAutomaticCount;
    NSMutableArray *arr_Red,*arr_Blue,*arr_Green;
    UIPinchGestureRecognizer *pinchGestureImg;
    UIRotationGestureRecognizer *rotateGestureImg;
    UITapGestureRecognizer *tapGestureMask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:false];
    fixWidth = 1000;
    
    //Refresh Bar button
    UIImage *barRefreshImage = [UIImage imageNamed:@"refresh"];
    UIBarButtonItem *refreshBar = [[UIBarButtonItem alloc] initWithImage:barRefreshImage style:UIBarButtonItemStylePlain target:self action:@selector(barRefreshClicked:)];
    //Share Bar Button
    UIImage *barShareImage = [UIImage imageNamed:@"share"];
    UIBarButtonItem *shareBar = [[UIBarButtonItem alloc] initWithImage:barShareImage style:UIBarButtonItemStylePlain target:self action:@selector(barShareClicked:)];
    
    self.navigationItem.rightBarButtonItems = @[shareBar,refreshBar];
    SwipeAutomaticCount = 0;
    typeView = Main;
    viewManualSwap.hidden = true;
    btn_ColorTune.hidden = true;
    viewColorOptions.hidden = true;
    viewMainOptions.hidden = false;
    
    //imgMyImage.image = self.myImage;
    faces = [[NSMutableArray alloc] init];
    
    [self generateImage];
    
    scrMain.minimumZoomScale = 1.0f;
    scrMain.maximumZoomScale = 2.5f;
    scrMain.delegate = self;
    
    btnMask1.layer.borderColor = borderColor.CGColor;// [UIColor redColor].CGColor;
    btnMask2.layer.borderColor = borderColor.CGColor;//[UIColor redColor].CGColor;
    btnMask3.layer.borderColor = borderColor.CGColor;//[UIColor redColor].CGColor;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(RemoveOldMaskFrame)];
    [imgMyImage addGestureRecognizer:tapGesture];
    
    imgMyImage.userInteractionEnabled = YES;
    
    //    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchMain:)];
    //    [scrMain addGestureRecognizer:pinch];
    //
    //    panMain = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetectedMain:)];
    //    panMain.minimumNumberOfTouches = 1;
    //    panMain.maximumNumberOfTouches = 1;
    //    panMain.delegate = self;
    //
    //    [imgMyImage addGestureRecognizer:panMain];
    //    //        panMain.enabled = false;
    //    [scrMain.panGestureRecognizer requireGestureRecognizerToFail:panMain];
    //
    
    
    //UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(btnBackClicked)];
    
    UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBackClicked)];
    
    
    UIBarButtonItem *barSetting = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingClicked)];
    self.navigationItem.leftBarButtonItems = @[barBack,barSetting];
    
    tapForSetting = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapForSetting:)];
    [scrMain addGestureRecognizer:tapForSetting];
    tapForSetting.enabled = false;
    viewSetting.hidden = true;
    
    scrTutorial.hidden = true;
    pageControlTutorial.hidden = true;
    //245,223, 177
    
    arr_Red = [[NSMutableArray alloc] initWithObjects:@"255",@"231", @"208",@"202",@"205",@"188",@"180",@"170",@"160",@"143",@"133",@"123",@"105",@"97",@"81",@"63",@"47",nil];
    
    arr_Green = [[NSMutableArray alloc] initWithObjects:@"255",@"199",@"177",@"168",@"155",@"143",@"134",@"121",@"112",@"96",@"86",@"79",@"71",@"68",@"57",@"45",@"31", nil];
    arr_Blue = [[NSMutableArray alloc] initWithObjects:@"255",@"161",@"136",@"123",@"105",@"103",@"93",@"84",@"68",@"63",@"59",@"55",@"49",@"47",@"40",@"38",@"13", nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [sliderColored setContinuous: NO];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    [self UpdateImage];
    [btn_ObjAutoSwapColorTuneView setImage:[UIImage imageNamed:@"swap after click"] forState:UIControlStateHighlighted];
    [btn_ObjAutoSwapMainView setImage:[UIImage imageNamed:@"swap after click"] forState:UIControlStateHighlighted];
    [btn_ObjManualSwapMainView setImage:[UIImage imageNamed:@"manual swap after click"] forState:UIControlStateHighlighted];
    [btn_ObjSwipeInManualView setImage:[UIImage imageNamed:@"SwapInManualSwapClick"] forState:UIControlStateHighlighted];
    
    sliderColored.selectedBarColor = [UIColor colorWithRed:230.0/255.0 green:205/255.0 blue:175/255.0 alpha:1.0];
    sliderColored.unselectedBarColor = [UIColor colorWithRed:47/255.0 green:31/255.0 blue:13/255.0 alpha:1.0];
    sliderColored.handlerImage = [UIImage imageNamed:@"sliderHandle"];

    if ([userDefault valueForKey:@"isManualSwappedPressed"] == nil){
        TapGestureManaulTutorial.enabled = true;
    }else{
        TapGestureManaulTutorial.enabled = false;        
    }
}
-(void)UpdateImage{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedAll] != nil || [userDefault valueForKey:KeyIsUnlockedSkin] != nil){
        [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
        [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock after click"] forState:UIControlStateHighlighted];
        
        [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];
        [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone without lock"] forState:UIControlStateNormal];
        
    }else{
        [btn_ObjColorTuneMainView setImage:[UIImage imageNamed:@"skin tone  after click"] forState:UIControlStateHighlighted];
        [btn_ColorTune setImage:[UIImage imageNamed:@"skin tone  after click"] forState:UIControlStateHighlighted];
    }
    [self.view setNeedsDisplay];
    [self.view setNeedsDisplayInRect:self.view.frame];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (isfirstTime == false) {
        isfirstTime = true;
        [self fitImage];
        imgMyImage.image = finalImage;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChangedOrientations) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        int topspace = (scrMain.frame.size.height/2 - height_imgview.constant/2);
        if (topspace < 0){
            topspace = 0;
        }
        //    else if (topspace > 40){
        //        topspace = topspace - 40;
        //    }
        bottom_imgview.constant = topspace;
        top_imgview.constant = topspace;
        //    preImageRect = imgMyImage.bounds;
        NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector:@selector(AutoSwapeMethod)userInfo: nil repeats:NO];
    }else{
        
    }
    
}
-(void)btnBackClicked{
    [self showConfirmAlertForGoBack];
}
-(void)showConfirmAlertForGoBack{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Oh! You haven’t saved the photo! Do you want to import a new one?                               All the change will lost"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"YES"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self.navigationController popViewControllerAnimated:true];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                         }];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)btnSettingClicked{
    CATransition *transition = [[CATransition alloc] init];
    transition.startProgress = 0.0f;
    transition.endProgress = 1.0f;
    transition.duration = 0.4f;
    transition.type = kCATransitionPush;
    if (viewSetting.hidden == true){
        transition.subtype = kCATransitionFromLeft;
        [scrMain addGestureRecognizer:tapForSetting];
        tapForSetting.enabled = true;
        
        if (self.banner != nil)
            [self.banner setHidden:true];
    }
    else{
        transition.subtype = kCATransitionFromRight;
        [scrMain removeGestureRecognizer:tapForSetting];
        if (self.banner != nil)
            [self.banner setHidden:false];
    }
    
    [viewSetting.layer addAnimation:transition forKey:@"opacity"];
    viewSetting.hidden = !viewSetting.hidden;
}
-(void)handleTapForSetting:(UIGestureRecognizer *)recognizer{
    [self btnSettingClicked];
}

- (IBAction)tapped:(id)sender {
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
        
        UIView *animView;
        switch (typeView) {
            case Main:
                animView = viewMainOptions;
                break;
            case ManualSwap:
                animView = viewManualSwap;
                break;
            case ColorTune:
                animView = viewColorOptions;
                break;
            default:
                break;
        }
        animView.hidden = !animView.hidden;
    }else{
        UIView *animView;
        switch (typeView) {
            case Main:
                animView = viewMainOptions;
                break;
            case ManualSwap:
                animView = viewManualSwap;
                break;
            case ColorTune:
                animView = viewColorOptions;
                break;
            default:
                break;
        }
        animView.hidden = false;
    }
}


-(void)deviceChangedOrientations{
    isSameOrientation = false;
    //    [self justResetImage];
    
    //    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(resetUI) userInfo:nil repeats:NO];
}
-(void)justResetImage{
    
    for (UIView *face in faces) {
        face.hidden = true;
    }
    scrMain.zoomScale = 1.0f;
    [self fitImage];
    int topspace = (scrMain.frame.size.height/2 - height_imgview.constant/2);
    if (topspace < 0){
        topspace = 0;
    }
    //    else if (topspace > 40){
    //        topspace = topspace - 40;
    //    }
    bottom_imgview.constant = topspace;
    top_imgview.constant = topspace;
    [self.view setNeedsUpdateConstraints];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(resetUI) userInfo:nil repeats:NO];
}
-(IBAction)resetUI{
    
    //    CGFloat widthScale = (preImageRect.size.height/preImageRect.size.width) * imgMyImage.frame.size.width;
    //    CGFloat heightScale = (preImageRect.size.width/preImageRect.size.height) * imgMyImage.frame.size.height;
    //    [self.view setNeedsUpdateConstraints];
    
    if(faces.count > 0){
        NSLog(@"[preImageRect]: %@",NSStringFromCGRect(preImageRect));
        NSLog(@"[Image Frame]: %@",NSStringFromCGRect(imgMyImage.frame));
        NSLog(@"[Image Bounds]: %@",NSStringFromCGRect(imgMyImage.bounds));
        
        CGRect rectImageView = imgMyImage.bounds;
        for(int i = 0; i < faces.count; i++){
            UIView *sub = faces[i];
            
            NSLog(@"[%d] : %@",i, NSStringFromCGRect(sub.frame));
            
            CGPoint centerPre = sub.center;
            CGPoint centerNew;
            centerNew.x = (rectImageView.size.width * centerPre.x)/preImageRect.size.width;
            centerNew.y = (rectImageView.size.height * centerPre.y)/preImageRect.size.height;
            //             sub.center = centerNew;
            
            CGRect rect = sub.bounds;
            //            rect = CGRectApplyAffineTransform(rect, sub.transform);
            CGRect newRect = rect;
            
            newRect.origin.x = (rectImageView.size.width * rect.origin.x)/preImageRect.size.width;
            newRect.origin.y = (rectImageView.size.height * rect.origin.y)/preImageRect.size.height;
            
            newRect.size.width = (rectImageView.size.height * rect.size.width)/preImageRect.size.height;
            newRect.size.height = (rectImageView.size.width * rect.size.height)/preImageRect.size.width;
            
            CGRect oldRect = sub.frame;
            CGAffineTransform t = sub.transform;
            
            sub.transform = CGAffineTransformIdentity;
            sub.frame = newRect;
            sub.center = centerNew;
            sub.transform = t;
            
            if (swapType == ManualSwap){
                [(MaskView *)sub resetControl];
            }
            
            //            newRect = CGRectApplyAffineTransform(newRect, sub.transform);
            
            //            newRect.origin.y = rectImageView.size.height - newRect.origin.y;
            
            //            float width =  (imgMyImage.frame.size.width * rect.size.width)/preImageRect.size.width;
            //            newRect.size.width = width;//(imgMyImage.frame.size.width * rect.size.width)/preImageRect.size.width;
            //            newRect.size.height = (width * rect.size.height)/(rect.size.width); //(imgMyImage.frame.size.height * rect.size.height)/preImageRect.size.height;
            
            NSLog(@"[%d] : %@",i, NSStringFromCGRect(sub.frame));
            sub.hidden = false;
        }
        BOOL isSwapped = false;
        
        for (MaskView *sub in arrManualSwappedFaces){
            isSwapped = true;
            CGPoint centerPre = sub.center;
            CGPoint centerNew;
            centerNew.x = (rectImageView.size.width * centerPre.x)/preImageRect.size.width;
            centerNew.y = (rectImageView.size.height * centerPre.y)/preImageRect.size.height;
            //             sub.center = centerNew;
            
            CGRect rect = sub.bounds;
            //            rect = CGRectApplyAffineTransform(rect, sub.transform);
            CGRect newRect = rect;
            
            newRect.origin.x = (rectImageView.size.width * rect.origin.x)/preImageRect.size.width;
            newRect.origin.y = (rectImageView.size.height * rect.origin.y)/preImageRect.size.height;
            
            newRect.size.width = (rectImageView.size.height * rect.size.width)/preImageRect.size.height;
            newRect.size.height = (rectImageView.size.width * rect.size.height)/preImageRect.size.width;
            
            CGRect oldRect = sub.frame;
            CGAffineTransform t = sub.transform;
            
            sub.transform = CGAffineTransformIdentity;
            sub.frame = newRect;
            sub.center = centerNew;
            sub.transform = t;
            
            if (swapType == ManualSwap){
                [(MaskView *)sub resetControl];
            }
        }
        if(isSwapped){
            for(int i = 0; i < faces.count; i++){
                UIView *sub = faces[i];
                sub.hidden = true;
            }
        }
        
    }
    preImageRect = imgMyImage.bounds;
    isSameOrientation = true;
}

-(void)fitImage{
    //    NSLog(@"ImageSize: %@", NSStringFromCGSize(finalImage.size));
    CGRect rect = imgMyImage.frame;
    CGFloat height =  (finalImage.size.height * rect.size.width )/ finalImage.size.width;
    //    if (height > scrMain.frame.size.height)
    //        height = scrMain.frame.size.height;
    height_imgview.constant = height;
    //    width_imgview.constant = scrMain.frame.size.width;
    [self.view setNeedsUpdateConstraints];
}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    NSLog(@"gestureRecognizerShouldBegin");
    return YES;
}
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView;{
    NSLog(@"%s",__FUNCTION__);
    scrMain.scrollEnabled = false;
    panMain.enabled = false;
}

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return YES;
//}
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView;{
    NSLog(@"%s",__FUNCTION__);
    panMain.enabled = true;
    //scrMain.scrollEnabled = true;
    [NSTimer scheduledTimerWithTimeInterval:0.4f target:scrMain selector:@selector(setScrollEnabled:) userInfo:[NSNumber numberWithBool:true] repeats:NO];
}

#pragma mark - UIScrollViewDelegate Method
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == scrTutorial){
        int x = scrTutorial.contentOffset.x;
        
        if(x >= scrTutorial.bounds.size.width/2){
            pageControlTutorial.currentPage = 1;
        }else{
            pageControlTutorial.currentPage = 0;
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == scrTutorial){
        int x = scrTutorial.contentOffset.x;
        
        if(x >= scrTutorial.bounds.size.width){
            pageControlTutorial.currentPage = 1;
        }else{
            pageControlTutorial.currentPage = 0;
        }
    }
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
//    if (Tag_MaskDetail == 0 || faces.count == 0) {
        //        for (int i = 0; i <faces.count; i++) {
        //            UIImageView *img = faces[i];
        //            img.transform = CGAffineTransformScale(img.transform, scrMain.zoomScale, scrMain.zoomScale);
        //        }
        return imgMyImage;
//    }else{
//        
//        UIImageView *img;
//        //        for (UIView *ImgTemp in scrMain.subviews) {
//        //            if (ImgTemp.tag == Tag_MaskDetail) {
//        //                img = (UIImageView *)ImgTemp;
//        //                break;
//        //            }
//        //        }
//        return imgMyImage;
//    }
}

#pragma mark - MaskViewDelegate Method
-(void)maskResizingStart:(MaskView *)maskView{
    scrMain.scrollEnabled = false;
    xScale = maskView.transform.a;
    yScale = maskView.transform.d;
    preRect = maskView.frame;
    lastRect = maskView.bounds;
    
    //    for (UIView *subview in self.view.subviews){
    for (UIView *subview in imgMyImage.subviews){
        //        if (subview.tag == 1001){
        if ([subview isKindOfClass:[MaskView class]] && subview != maskView){
            [(MaskView *)subview fixClicked];
        }
        //        }
    }
    ManualSwapX = maskView.Name;
    //    NSLog(@"mask tag %@",ManualSwapX);
    if ([ManualSwapX  isEqual: @"Mask 2"]) {
        [sliderBW setValue:[arr_SliderValue_Brightness_Manual[1]floatValue] animated:YES];
        [sliderColored setValue:[arr_sliderValue_Color_Manual[1]floatValue] animated:YES];
        
    }else{
        [sliderBW setValue:[arr_SliderValue_Brightness_Manual[0]floatValue] animated:YES];
        [sliderColored setValue:[arr_sliderValue_Color_Manual[0]floatValue] animated:YES];
    }
    [maskView showMaskControls];
    [maskView hideFlip];
    if (maskView.tag == 1002)
        [maskView showFlip];
    [imgMyImage bringSubviewToFront:maskView];
}
-(void)maskResizingInProgress:(MaskView *)maskView{
}
-(void)maskResizingStop:(MaskView *)maskView{
    scrMain.scrollEnabled = true;
}
-(void)maskRotationStart:(MaskView *)maskView{
    scrMain.scrollEnabled = false;
}
-(void)maskRotationInProgress:(MaskView *)maskView{
    
}
-(void)maskRotationStop:(MaskView *)maskView{
    scrMain.scrollEnabled = true;
}
-(void)maskWillRemove:(MaskView *)maskView{
    [faces removeObject:maskView];
    [maskView removeFromSuperview];
}
#pragma mark - Setting Control Touch Method
- (IBAction)btnInstagramClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:Instagram_Link];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)btnStartOverClicked:(id)sender {
    viewColorOptions.hidden = YES;
    scrMain.zoomScale = 1.0;
    SwipeAutomaticCount = 0;
    [scrMain removeGestureRecognizer:pinchGestureImg];
    [scrMain removeGestureRecognizer:rotateGestureImg];
    NSLog(@"Frame: %@", NSStringFromCGRect(imgMyImage.frame));
    //    imgMyImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [self RemoveOldMaskFrame];
    [self clearFaces];
}

- (IBAction)btnRestoreClicked:(id)sender {
    [[StoreObserver sharedInstance] restore];
}
- (IBAction)btnSettingTutorialClicked:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [scrTutorial setHidden:false];
    [scrTutorial setContentOffset:CGPointMake(0, 0)];
    [self.view bringSubviewToFront:scrTutorial];
    pageControlTutorial.hidden = false;
    [self.view bringSubviewToFront:pageControlTutorial];
    
    [self btnSettingClicked];
    if (self.banner != nil)
        [self.banner setHidden:true];
    
}
- (IBAction)btnShowSomeLoveClicked:(id)sender {
    //    [self alertWithTitle:@"Show Some Love clicked." message:@""];
    NSURL *url = [NSURL URLWithString:AppLink];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)btnLikeUsOnFacebook:(id)sender {
    //    [self alertWithTitle:@"Like Us On Facebook clicked." message:@""];
    NSURL *url = [NSURL URLWithString:FacebookPage_Link];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)btnFollowOnTwitter:(id)sender {
    //    [self alertWithTitle:@"Follow On Twitter clicked." message:@""];
    NSURL *url = [NSURL URLWithString:TwitterPage_Link];
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)postToTwitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Create funny photo using Faceswap app.Download FaceSwap iOS App now!"];
        UIImage *imgPhoto = [UIImage imageNamed:@"icon.jpg"];
        [tweetSheet addImage:imgPhoto];
        [tweetSheet addURL:[NSURL URLWithString:AppiTunes_Link]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}
- (IBAction)postToFacebook:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        UIImage *imgPhoto = [UIImage imageNamed:@"icon.jpg"];
        [controller setInitialText:@"Create funny photo using Faceswap app.Download FaceSwap iOS App now!"];
        [controller addImage:imgPhoto];
        [controller addURL:[NSURL URLWithString:AppiTunes_Link]];
        
        [self presentViewController:controller animated:YES completion:Nil];
    }
}
- (IBAction)btnContactUsClicked:(id)sender {
    //    [self alertWithTitle:@"Contact Us clicked." message:@""];
    //free.new.apps.4u@gmail.com
    [self showEmail];
}
- (void)showEmail {
    
    NSString *emailTitle = @"Feedback for FaceSwap app";
    NSString *messageBody = @"";
    NSArray *toRecipents = [NSArray arrayWithObject:@"free.new.apps.4u@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)btnMoreClicked:(id)sender {
    [self performSegueWithIdentifier:@"segueMoreApps" sender:nil];
}
- (IBAction)tapTutorialAutoSwap:(id)sender {
    [imgTutorialAutoSwap setHidden:true];
    if (self.banner != nil && [self isPurchasedUnlockPro] == false){
        [self.banner setHidden:false];
    }
}
- (IBAction)tapTutorialManualSwap:(id)sender {
    [imgTutorialManualSwap setHidden:true];
    TapGestureManaulTutorial.enabled = false;
    if (self.banner != nil && [self isPurchasedUnlockPro] == false){
        [self.banner setHidden:false];
    }
}
- (IBAction)tapTutorialScrollview:(id)sender {
    [scrTutorial setHidden:true];
    [pageControlTutorial setHidden:true];
    if (self.banner != nil && [self isPurchasedUnlockPro] == false)
        [self.banner setHidden:false];
}

#pragma mark - Button Touch Method
//- (IBAction)btnRemoveAdClicked:(id)sender {
//    [self.navigationController setNavigationBarHidden:false];
//    RemoveAdsVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RemoveAdsVC"];
//    [[self navigationController] pushViewController:VC animated:YES];
//    //    [self showConfirmAlertForInapp];
//}
- (IBAction)btnColorTuneManualSwapClicked:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedAll] != nil || [userDefault valueForKey:KeyIsUnlockedSkin] != nil){
        viewColorOptions.hidden = false;
        btn_ObjAutoSwapColorTuneView.hidden = true;
    }else{
        [self ColorTunePurchase];
    }
}

- (IBAction)btnSwapFaceClicked:(id)sender {
    ManualSwapX = @"";
    scrMain.zoomScale = 1;
    btn_ColorTune.hidden = false;
    //    [self resetImage];
    [self swapFacesForManual_V_2];
}

- (IBAction)btnFaceMaskSelect:(UIButton *)sender {
    btnMask1.layer.borderWidth = 0.0f;
    btnMask2.layer.borderWidth = 0.0f;
    btnMask3.layer.borderWidth = 0.0f;
    
    sender.layer.borderWidth = 1.0f;
    
    scrMain.zoomScale = 1;
    //[self resetImage];
    
    if (sender == btnMask1){
        selectedMaskImage = [UIImage imageNamed:@"face_mask_type_3"];
        maskToApply = [UIImage imageNamed:@"facemask3"];
    } else if (sender == btnMask2){
        selectedMaskImage = [UIImage imageNamed:@"face_mask_type_2"];
        maskToApply = [UIImage imageNamed:@"facemask2"];
    } else if (sender == btnMask3){
        selectedMaskImage = [UIImage imageNamed:@"face_mask_type_1"];
        maskToApply = [UIImage imageNamed:@"facemask1"];
    }
    /*
     if (sender == btnMask1){
     selectedMaskImage = [UIImage imageNamed:@"facemask3"];
     } else if (sender == btnMask2){
     selectedMaskImage = [UIImage imageNamed:@"facemask2"];
     } else if (sender == btnMask3){
     selectedMaskImage = [UIImage imageNamed:@"facemask1"];
     }*/
    
    if (swapType != Manual || faces.count == 0){
        swapType = Manual;
        [self clearFaces];
        [self showMasks:selectedMaskImage];
    }else{
        if (isManualFaceSwaped == true){
            scrMain.zoomScale = 1;
            [self swapFacesForManual_V_2];
        } else {
            for (MaskView *mask in faces) {
                mask.faceView.image = selectedMaskImage;
                mask.hidden = false;
            }
            while ([imgMyImage viewWithTag:1002]) {
                MaskView *temp = [imgMyImage viewWithTag:1002];
                [temp removeFromSuperview];
            }
        }
    }
}
-(void)resetImage{
    scrMain.transform = CGAffineTransformMakeScale(1.0, 1.0);
    CGRect rect = CGRectMake(preImageRect.origin.x, preImageRect.origin.y, imgMyImage.frame.size.width, imgMyImage.frame.size.height);
    //    CGRect rect = CGRectMake(preImageRect.origin.x, (scrMain.frame.size.height/2 - height_imgview.constant/2) - 60.0 , imgMyImage.frame.size.width, imgMyImage.frame.size.height);
    imgMyImage.frame = rect;
}

-(void)barRefreshClicked:(id)sender{
    viewColorOptions.hidden = YES;
    scrMain.zoomScale = 1.0;
    SwipeAutomaticCount = 0;
    [scrMain removeGestureRecognizer:pinchGestureImg];
    [scrMain removeGestureRecognizer:rotateGestureImg];
    NSLog(@"Frame: %@", NSStringFromCGRect(imgMyImage.frame));
    //    imgMyImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [self RemoveOldMaskFrame];
    [self clearFaces];
    //[self resetImage];
    
}
-(void)barShareClicked:(id)sender{
    //    [self resetImage];
    [self RemoveOldMaskFrame];
    
    scrMain.zoomScale = 1.0;
    
    [self generateSharableImage];
    [self performSegueWithIdentifier:@"segueShare" sender:nil];
}

-(IBAction)btnAutoSwapClicked:(id)sender{
    [self RemoveOldMaskFrame];
    [self AutoSwapeMethod];
}

-(void)AutoSwapeMethod{
    Tag_MaskDetail = 0;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  /*  if ([userDefault valueForKey:@"isAutoSwappedPressed"] == nil){
        imgTutorialAutoSwap.hidden = false;
        if (self.banner != nil && [self isPurchasedUnlockPro] == false){
            [self.banner setHidden:true];
        }
        [self.view bringSubviewToFront:imgTutorialAutoSwap];
        [userDefault setObject:@"1" forKey:@"isAutoSwappedPressed"];
        [userDefault synchronize];
        return;
    }*/
    
    //    typeView = ManualSwap;
    //    [self showController];
    
    //imgMyImage.transform = CGAffineTransformIdentity;
    scrMain.zoomScale = 1;
    [self fitImage];
    SwipeAutomaticCount++;
    //[self resetImage];
    //    [self fitImage];
    [self clearFaces];
    swapType = Auto;
    [self createFaceDetector_V_2];
    if(faces == nil || faces.count == 0){
        [self alertWithTitle:@"" message:@"No Faces detected!!  Please Import A Image With Two or More Faces"];
        [audioPlayer stop];
    }else if (faces.count < 2){
        [self clearFaces];
        [self alertWithTitle:@"" message:@"The Faces Could Not Detected for Technical Limitations. Please Try With \"Manual Face Swap\""];
        [audioPlayer stop];
    }else{
        
        [self swapFaces_My];
    }
    preImageRect = imgMyImage.bounds;
}
-(IBAction)btnManualSwapClicked:(id)sender{
    [self RemoveOldMaskFrame];
    typeView = ManualSwap;
    Tag_MaskDetail = 0;
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    if ([userDefault valueForKey:@"isManualSwappedPressed"] == nil){
//        TapGestureManaulTutorial.enabled = true;
//        imgTutorialManualSwap.hidden = false;
//        if (self.banner != nil && [self isPurchasedUnlockPro] == false){
//            [self.banner setHidden:true];
//        }
//        [self.view bringSubviewToFront:imgTutorialManualSwap];
//        [userDefault setObject:@"1" forKey:@"isManualSwappedPressed"];
//        [userDefault synchronize];
//        return;
//    }
    TapGestureManaulTutorial.enabled = false;
    [self showController];
    [self clearFaces];
    
    btnMask1.layer.borderWidth = 0.0f;
    btnMask2.layer.borderWidth = 0.0f;
    btnMask3.layer.borderWidth = 0.0f;
    
    //    [self createFaceDetector];
    [self btnFaceMaskSelect:btnMask1];
    preImageRect = imgMyImage.bounds;
}
-(IBAction)btnCloseManualSwapClicked:(id)sender{
    typeView = Main;
    [self showController];
    [self clearFaces];
}
-(IBAction)btnColorTuneClicked:(id)sender{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedAll] != nil || [userDefault valueForKey:KeyIsUnlockedSkin] != nil){
        UIView *animView;
        CATransition *transition = [[CATransition alloc] init];
        transition.startProgress = 0.0f;
        transition.endProgress = 1.0f;
        transition.duration = 0.4f;
        transition.type = kCATransitionPush;
        animView = viewColorOptions;
        transition.subtype = kCATransitionFromTop;
        [animView.layer addAnimation:transition forKey:@"opacity"];
        animView.hidden = false;
        btn_ObjAutoSwapColorTuneView.hidden = false;
    }else{
        [self ColorTunePurchase];
    }
    
}
-(IBAction)btnCloseColorTuneClicked:(id)sender{
    viewColorOptions.hidden = true;
    //    typeView = ManualSwap;
    //    [self showController];
}
-(void)showController{
    UIView *animView;
    CATransition *transition = [[CATransition alloc] init];
    transition.startProgress = 0.0f;
    transition.endProgress = 1.0f;
    transition.duration = 0.4f;
    transition.type = kCATransitionPush;
    
    switch (typeView) {
        case Main:
            viewManualSwap.hidden = true;
            btn_ColorTune.hidden = true;
            animView = viewMainOptions;
            transition.subtype = kCATransitionFromTop;
            break;
        case ManualSwap:
            viewColorOptions.hidden = true;
            viewMainOptions.hidden = true;
            animView = viewManualSwap;
            transition.subtype = kCATransitionFromTop;
            break;
        case ColorTune:
            viewManualSwap.hidden = true;
            btn_ColorTune.hidden = true;
            animView = viewColorOptions;
            transition.subtype = kCATransitionFromTop;
            break;
        default:
            break;
    }
    [animView.layer addAnimation:transition forKey:@"opacity"];
    animView.hidden = false;
}
#pragma mark - Manual Control Method
-(void)clearFaces{
    isManualFaceSwaped = false;
    if (faces.count > 0){
        for (UIView *f in faces) {
            [f removeFromSuperview];
        }
        [faces removeAllObjects];
    }
    while ([imgMyImage viewWithTag:1002]) {
        MaskView *temp = [imgMyImage viewWithTag:1002];
        [temp removeFromSuperview];
    }
}
-(void)showMasks:(UIImage *)maskImage{
    float width = imgMyImage.frame.size.width/3;
    float height = width;
    NSLog(@"%@", NSStringFromCGPoint(imgMyImage.center));
    float x = imgMyImage.center.x - width;
    float y = imgMyImage.center.y - height;
    arr_SliderValue_Brightness_Manual = [[NSMutableArray alloc] init];
    arr_sliderValue_Color_Manual = [[NSMutableArray alloc] init];
    arr_FaceManualSwap = [@[]mutableCopy];
    for (int i=0; i<2; i++) {
        if ((x+width) > self.view.frame.size.width){
            y += height + 20;
            x = 0;
        }
        CGRect rect = CGRectMake(x, y, width, height);
        x += width + 20.0;
        
        MaskView *mask = [[MaskView alloc] initWithFrame:rect withMaskImage:selectedMaskImage];
        [imgMyImage addSubview:mask];
        mask.mainView = imgMyImage;
        mask.faceView.image = maskImage;
        mask.delegate = self;
        mask.tag = 1001;
        mask.Name = [NSString stringWithFormat:@"Mask%d",i+1];
        [faces addObject:mask];
        [arr_SliderValue_Brightness_Manual addObject:@"0.5"];
        [arr_sliderValue_Color_Manual addObject:@"0.5"];
        [mask hideFlip];
    }
}
-(void)swapFacesForManual_V_2{
    isManualFaceSwaped = true;
    scrMain.zoomScale = 1.0f;
    
    if (arrManualSwappedFaces == nil)
        arrManualSwappedFaces = [@[] mutableCopy];
    
    // Clear faces
    while ([imgMyImage viewWithTag:1002]) {
        MaskView *temp = [imgMyImage viewWithTag:1002];
        [temp removeFromSuperview];
    }
    [arrManualSwappedFaces removeAllObjects];
    arr_FaceManualSwap = [@[]mutableCopy];
    NSMutableArray *arrTempMask = [@[] mutableCopy];
    int i = 0;
    for (MaskView *mask in faces) {
        i++;
        //** UNCOMMENT FOLLOWING LINE IF FACEVIEW HAS SAME FRAME AS MASK
        //CGRect rect = [mask.faceView convertRect:mask.faceView.frame toView:imgMyImage];
        
        CGRect rect = [mask convertRect:mask.faceView.frame toView:imgMyImage];
        rect = [self convertOriginRectToImageRect:rect];
        CGImageRef imgRef = CGImageCreateWithImageInRect(finalImage.CGImage, rect);
        UIImage *imgCropped = [UIImage imageWithCGImage:imgRef];
        //maulik Chnage
        
        UIImage *imgMask = maskToApply;//[UIImage imageNamed:@"Black mask_image"];
        
        // Detect rotation.
        CGFloat radians = atan2f(mask.transform.b, mask.transform.a);
        CGFloat degrees = radians * (180 / M_PI);
        
        // Resize mask as per cropped image.
        CGRect rectMask = [self convertOriginRectToImageRect:(CGRect){0,0,mask.faceView.frame.size}];
        imgMask = [self resizedFaceMaskImageToSize:rectMask.size withImage:imgMask];
        if (degrees != 0)
            imgMask = [self imageRotatedByDegrees2:degrees src:imgMask];
        
        rectMask.size.height -= 2.0f;
        rectMask.size.width -= 2.0f;
        
        // Apply Mask on cropped face image.
        UIImage *imgResult = [self maskImage:imgCropped withMask:imgMask];
        
        mask.faceView.alpha = 1.0f;
        
        //        CGRect rectOld = [mask.faceView convertRect:mask.faceView toView:imgMyImage];
        MaskView *temp = [[MaskView alloc] initWithFrame:mask.frame];
        temp.faceView.image = imgResult;
        temp.tag = 1002;
        temp.delegate = self;
        temp.faceView.alpha = 1.0f;
        temp.faceImage = imgCropped;
        temp.maskImage = imgMask;
        temp.Name = [NSString stringWithFormat:@"Mask %d",i];
        
        [imgMyImage addSubview:temp];
        [arrTempMask addObject:temp];
        [temp showFlip];
        
        mask.hidden = true;
        mask.tag = 1001;
        [arrManualSwappedFaces addObject:temp];
        [arr_FaceManualSwap addObject:imgResult];
    }
    if (arrTempMask.count > 1){
        MaskView *mask1 = arrTempMask[0];
        MaskView *mask2 = arrTempMask[1];
        
        CGPoint center1 = mask1.center;
        mask1.center = mask2.center;
        mask2.center = center1;
    }
    [arrTempMask removeAllObjects];
    arrTempMask = nil;
}

#pragma mark - UIImage processing Methods
-(void)generateImage{
    /** OLD
     CGFloat height_imgView =  (self.myImage.size.height * fixWidth)/self.myImage.size.width;
     aspectHeight = height_imgView;
     
     UIGraphicsBeginImageContext(CGSizeMake(fixWidth, height_imgView));
     //    [imgMyImage.layer renderInContext:UIGraphicsGetCurrentContext()];
     [self.myImage drawInRect:CGRectMake(0, 0, fixWidth, height_imgView)];
     UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
     finalImage = img;
     UIGraphicsEndImageContext();
     */
    UIImage *rotatedImage1 = [self rotate:_myImage orientation:_myImage.imageOrientation];
    CGFloat height_imgView =  (rotatedImage1.size.height * fixWidth)/rotatedImage1.size.width;
    aspectHeight = height_imgView;
    
    UIGraphicsBeginImageContext(CGSizeMake(fixWidth, height_imgView));
    //    [imgMyImage.layer renderInContext:UIGraphicsGetCurrentContext()];
    [rotatedImage1 drawInRect:CGRectMake(0, 0, fixWidth, height_imgView)];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    finalImage = img;
    UIGraphicsEndImageContext();
}
- (UIImage*)createNewImageFrom:(UIImage*)image withSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

-(void)generateSharableImage{
    CGRect rectImageview = imgMyImage.frame;
    
    CGRect rectForFullImage = CGRectMake(0,0, fixWidth, aspectHeight);
    UIGraphicsBeginImageContext(rectForFullImage.size);
    
    //[imgMyImage.layer renderInContext:UIGraphicsGetCurrentContext()];
    [finalImage drawInRect:rectForFullImage];
    
    if (swapType == Auto){
        //        for (UIImageView *face in faces){
        for(int i=0; i<faces.count ;i++){
            
            UIImageView *face = faces[i];
            CGRect frameTemp = face.frame;
            CGRect newRect;
            newRect.origin.x = (rectForFullImage.size.width * frameTemp.origin.x) / rectImageview.size.width;
            newRect.origin.y = (rectForFullImage.size.height * frameTemp.origin.y) / rectImageview.size.height;
            newRect.size.height = (rectForFullImage.size.height * frameTemp.size.height) / rectImageview.size.height;
            newRect.size.width = (rectForFullImage.size.width * frameTemp.size.width) / rectImageview.size.width;
            
            CGFloat radians = atan2f(face.transform.b, face.transform.a);
            CGFloat degrees = radians * (180 / M_PI);
            NSLog(@"degrees: %f",degrees);
            
            // degrees = degrees * -1.0;
            //            UIImage *img = faceImages[i];
            int value = [arr_sliderValue_Color[i]floatValue] *100 / 6.25;
            float value1 = value *6.25;
            float value2 = [arr_sliderValue_Color[i]floatValue] * 100 -value1;
            float red = 0.0,green = 0.0;
            float blue1 = 0.0;
            red = [arr_Red[value]floatValue] + value2;
            green = [arr_Green[value]floatValue] + value2;
            blue1 = [arr_Blue[value]floatValue] + value2;
            //                ImgNew.image = [ImgOld adjust:red/255.0 g:green/255.0 b:blue1/255.0];
            
            
            UIImage *img;
            if ([arr_sliderValue_Color[i]  isEqual: @"0.5"] && [arr_sliderValue_Brightness[i] isEqual:@"0.5"]) {
                img = arr_FaceAutoSwap[i];
            }else{
                UIImage*ImgOld =  arr_FaceAutoSwap[i];
                /* UIGraphicsBeginImageContext(ImgOld.size);
                 
                 // get a reference to that context we created
                 CGContextRef context = UIGraphicsGetCurrentContext();
                 
                 // set the fill color
                 [[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue1/255.0 alpha:0.5] setFill];
                 
                 // translate/flip the graphics context (for transforming from CG* coords to UI* coords
                 CGContextTranslateCTM(context, 0, ImgOld.size.height);
                 CGContextScaleCTM(context, 1.0, -1.0);
                 
                 // set the blend mode to color burn, and the original image
                 CGContextSetBlendMode(context, kCGBlendModeColorBurn);
                 CGRect rect = CGRectMake(0, 0, ImgOld.size.width, ImgOld.size.height);
                 CGContextDrawImage(context, rect, ImgOld.CGImage);
                 
                 // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
                 CGContextClipToMask(context, rect, ImgOld.CGImage);
                 CGContextAddRect(context, rect);
                 CGContextDrawPath(context,kCGPathFill);
                 
                 // generate a new UIImage from the graphics context we drew onto
                 UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
                 
                 //return the color-burned image
                 img =  coloredImg;
                 */
                if ([arr_sliderValue_Color[i]  isEqual: @"0.5"]) {
                    img = ImgOld;
                }else{
                    CGRect rect = CGRectMake(0, 0, ImgOld.size.width, ImgOld.size.height);
                    UIGraphicsBeginImageContext(rect.size);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, rect, ImgOld.CGImage);
                    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue1/255.0 alpha:0.4] CGColor]);
                    CGContextFillRect(context, rect);
                    UIImage *imgGraphic = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    UIImage *flippedImage = [UIImage imageWithCGImage:imgGraphic.CGImage
                                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
                    
                    UIImage *imgMain = [self imageByCombiningImage:ImgOld withImage:flippedImage];
                    img = imgMain;
                    
                }
                if ([arr_sliderValue_Brightness[i]  isEqual: @"0.5"]) {
                    
                }else{
                    img = [img brightness:(1+[arr_sliderValue_Brightness[i]floatValue]-0.5)];
                }
                
                //                img = [arr_FaceAutoSwap[i] adjust:red/255.0 g:green/255.0 b:blue1/255.0] ;
                
            }
            if ([arrMirroredface containsObject:[NSNumber numberWithInt:(int)face.tag]]){
                UIImage *sourceImage = img;
                img = [self flipImage:sourceImage];
            }
            if (degrees != 0){
                img = [self imageTransparentRotatedByDegrees:radians src:img];
                //                img = [self rotate:img angle:radians];
            }
            //            [face.image drawInRect:newRect];
            [img drawInRect:newRect];
        }
        
    }else{
        //        for (MaskView *view in faces){
        
        for (UIView *tempView in imgMyImage.subviews){
            //          for (UIView *tempView in self.view.subviews){
            if (tempView.tag  != 1002)
                continue;
            
            MaskView *view = (MaskView *)tempView;
            
            
            UIImageView *face = (UIImageView *)view.faceView;
            
            //            CGRect rectToImageView = [view convertRect:view.faceView.frame toView:imgMyImage];
            
            CGRect frameTemp = [view convertRect:view.faceView.frame toView:imgMyImage]; //view.frame;
            
            CGRect newRect;
            newRect.origin.x = (rectForFullImage.size.width * frameTemp.origin.x) / rectImageview.size.width;
            newRect.origin.y = (rectForFullImage.size.height * frameTemp.origin.y) / rectImageview.size.height;
            newRect.size.height = (rectForFullImage.size.height * frameTemp.size.height) / rectImageview.size.height;
            newRect.size.width = (rectForFullImage.size.width * frameTemp.size.width) / rectImageview.size.width;
            
            CGFloat radians = atan2f(view.transform.b, view.transform.a);
            CGFloat degrees = radians * (360 / M_PI);
            degrees *= -1;
            NSLog(@"degrees: %f",degrees);
            
            UIImage *img = face.image;
            if (degrees != 0){
                img = [self imageTransparentRotatedByDegrees:radians src:img];
            }
            [img drawInRect:newRect];
            
            
        }
        /*
         for (SPUserResizableView *view in faces){
         UIImageView *face = (UIImageView *)view.contentView;
         CGRect frameTemp = view.frame;
         CGRect newRect;
         newRect.origin.x = (rectForFullImage.size.width * frameTemp.origin.x) / rectImageview.size.width;
         newRect.origin.y = (rectForFullImage.size.height * frameTemp.origin.y) / rectImageview.size.height;
         newRect.size.height = (rectForFullImage.size.height * frameTemp.size.height) / rectImageview.size.height;
         newRect.size.width = (rectForFullImage.size.width * frameTemp.size.width) / rectImageview.size.width;
         [face.image drawInRect:newRect];
         }*/
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    sharableImage = img;
    
    UIGraphicsEndImageContext();
}
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
    
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
-(UIImage*) rotate:(UIImage*)src orientation:(UIImageOrientation )orientation
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [src drawAtPoint:CGPointMake(0, 0)];
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees src:(UIImage *)src {
    CGFloat radians = degrees;
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, src.size.width, src.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //new
    [[UIColor whiteColor] setFill];
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    CGContextFillRect(bitmap,CGRectMake(-500,-500, src.size.width+500 , src.size.height+500));
    
    CGContextRotateCTM(bitmap, radians);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    //new
    //    CGContextFillRect(bitmap,CGRectMake(-1 * src.size.width/2,-1 * src.size.height/2, src.size.width+50 , src.size.height+50));
    
    CGContextDrawImage(bitmap, CGRectMake(-src.size.width / 2, -src.size.height / 2 , src.size.width, src.size.height),src.CGImage );
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage *)imageRotatedByDegrees2:(CGFloat)degrees src:(UIImage *)oldImage {
    
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    
    //Girish
    [[UIColor whiteColor] setFill];
    CGContextFillRect(bitmap,CGRectMake(-500,-500, rotatedSize.width+500 , rotatedSize.height+500));
    //**End
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
- (UIImage *)imageTransparentRotatedByDegrees:(CGFloat)degrees src:(UIImage *)src {
    CGFloat radians = degrees;
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, src.size.width, src.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    //    CGContextFillRect(bitmap,CGRectMake(-70,-70, src.size.width+50 , src.size.height+50));
    
    CGContextRotateCTM(bitmap, radians);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    //new
    //    CGContextFillRect(bitmap,CGRectMake(-1 * src.size.width/2,-1 * src.size.height/2, src.size.width+50 , src.size.height+50));
    
    CGContextDrawImage(bitmap, CGRectMake(-src.size.width / 2, -src.size.height / 2 , src.size.width, src.size.height),src.CGImage );
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)rotate:(UIImage *)src angle:(CGFloat)angle{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGFloat size = MIN(src.size.width, src.size.height);
    
    CGContextTranslateCTM(context, size / 2, size / 2);
    CGContextRotateCTM(context, M_PI_4);
    CGContextTranslateCTM(context, -size / 2, -size / 2);
    
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context,CGRectMake(-20,-20, src.size.width+50 , src.size.height+50));
    [src drawAtPoint:CGPointMake(0, 0)];
    CGContextRotateCTM (context, radians(angle));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i)
    {
        CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
        CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / alpha;
        CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / alpha;
        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / alpha;
        byteIndex += bytesPerPixel;
        
        UIColor *acolor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}
+ (NSArray*)getRGBAsFromImage_My:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i)
    {
        CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
        CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / alpha;
        CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / alpha;
        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / alpha;
        byteIndex += bytesPerPixel;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}
- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle{
    return [self CGImageRotatedByAngle:imgRef angle:angle color:[UIColor blackColor]];
}
- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle color: (UIColor *)backGroundcolor
{
    CGFloat angleInRadians = angle * (M_PI / 180);
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGRect imgRect = CGRectMake(0, 0, width, height);
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                   rotatedRect.size.width,
                                                   rotatedRect.size.height,
                                                   8,
                                                   0,
                                                   colorSpace,
                                                   kCGImageAlphaPremultipliedFirst);
    
    CGContextSetAllowsAntialiasing(bmContext, YES);
    CGContextSetShouldAntialias(bmContext, YES);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    CGColorSpaceRelease(colorSpace);
    CGContextTranslateCTM(bmContext,
                          +(rotatedRect.size.width/2),
                          +(rotatedRect.size.height/2));
    CGContextRotateCTM(bmContext, angleInRadians);
    CGContextTranslateCTM(bmContext,
                          -(rotatedRect.size.width/2),
                          -(rotatedRect.size.height/2));
    
    CGContextSetFillColorWithColor(bmContext, backGroundcolor.CGColor);
    CGContextFillRect(bmContext, CGRectMake(-2000, -2000, 4000, 4000));
    
    CGContextDrawImage(bmContext, CGRectMake(0, 0,
                                             rotatedRect.size.width,
                                             rotatedRect.size.height),
                       imgRef);
    
    
    
    CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
    CFRelease(bmContext);
    
    return rotatedImage;
}

- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle color: (UIColor *)backGroundcolor size:(CGSize)size
{
    CGFloat angleInRadians = angle * (M_PI / 180);
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGRect imgRect = CGRectMake(0, 0, width, height);
    
    //*** Testing
    CGRect imgRectTest = (CGRect){0,0, size};
    CGAffineTransform transformTest = CGAffineTransformMakeRotation(angleInRadians);
    CGRect rotatedRectTest = CGRectApplyAffineTransform(imgRectTest, transformTest);
    
    if (rotatedRectTest.origin.x < 0)
        rotatedRectTest.size.width += -rotatedRectTest.origin.x;
    
    if (rotatedRectTest.origin.y < 0)
        rotatedRectTest.size.height += -rotatedRectTest.origin.y;
    CGRect rotatedRect = rotatedRectTest;
    //*** End Testing
    
    /*CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
     CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
     
     rotatedRect.size.height = MAX(imgRect.size.height, rotatedRect.size.height);
     rotatedRect.size.width = MAX(imgRect.size.width, rotatedRect.size.width);
     */
    rotatedRect.size.width = MAX(imgRectTest.size.width, rotatedRect.size.width);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                   rotatedRect.size.width,
                                                   rotatedRect.size.height,
                                                   8,
                                                   0,
                                                   colorSpace,
                                                   kCGImageAlphaPremultipliedFirst);
    
    CGContextSetAllowsAntialiasing(bmContext, YES);
    CGContextSetShouldAntialias(bmContext, YES);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(bmContext,
                          +(rotatedRect.size.width/2),
                          +(rotatedRect.size.height/2));
    CGContextRotateCTM(bmContext, angleInRadians);
    
    CGContextTranslateCTM(bmContext,
                          -(rotatedRect.size.width/2),
                          -(rotatedRect.size.height/2));
    
    CGContextTranslateCTM(bmContext,
                          0,
                          0);
    
    CGContextSetFillColorWithColor(bmContext, backGroundcolor.CGColor);
    CGContextFillRect(bmContext, CGRectMake(-2000, -2000, 4000, 4000));
    
    float x;
    float y;
    if (rotatedRectTest.origin.x < 0)
        x = -rotatedRectTest.origin.x;
    else
        x = rotatedRectTest.origin.x;
    
    if (rotatedRectTest.origin.y < 0)
        y = -rotatedRectTest.origin.y;
    else
        y = rotatedRectTest.origin.y;
    
    //x = rotatedRectTest.size.width - imgRectTest.size.width;
    //y = rotatedRectTest.size.height - imgRectTest.size.height;
    
    CGContextDrawImage(bmContext, CGRectMake(x/2,y,
                                             imgRectTest.size.width,
                                             rotatedRectTest.size.height),
                       imgRef);
    
    
    
    CGImageRef rotatedImage1 = CGBitmapContextCreateImage(bmContext);
    CFRelease(bmContext);
    
    return rotatedImage1;
}

#pragma mark - Detect Faces
-(UIImage *)getFaceFromRotated:(UIImage *)imgSource{
    return [self getFaceFromRotated:imgSource color:[UIColor whiteColor]];
}
-(UIImage *)getFaceFromRotated:(UIImage *)imgSource color:(UIColor *)color{
    UIImage *imgPhoto = imgSource;
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh};
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:opts];
    //opts = @{CIDetectorImageOrientation : [NSNumber numberWithInt:1], CIDetectorSmile: [NSNumber numberWithBool:true]};
    CIImage *ciImage = [CIImage imageWithCGImage:imgSource.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];//[detector featuresInImage:ciImage options:opts];
    
    /*
     for (int i = 1 ;i <= 8 && features.count == 0; i++){
     opts = @{CIDetectorImageOrientation : [NSNumber numberWithInt:i], CIDetectorSmile: [NSNumber numberWithBool:true]};
     features = [detector featuresInImage:ciImage options:opts];
     }
     */
    // arrFeatures = features;
    for (int i=0; i<features.count; i++){
        CIFaceFeature *f = features[i];
        /*
         NSLog(@"2..Bound: %@",NSStringFromCGRect(f.bounds));
         if (f.hasLeftEyePosition){
         NSLog(@"LeftEyePosition: %@",NSStringFromCGPoint(f.leftEyePosition));
         }
         if (f.hasRightEyePosition){
         NSLog(@"RightEyePosition: %@",NSStringFromCGPoint(f.rightEyePosition));
         }
         if (f.hasMouthPosition){
         NSLog(@"MouthPosition: %@",NSStringFromCGPoint(f.mouthPosition));
         }*/
        float diffLeftEye = f.mouthPosition.x - f.leftEyePosition.x;
        float diffRightEye = f.rightEyePosition.x - f.mouthPosition.x;
        
        //        NSLog(@"Distance from Mouth : Left Eye = %f, Right Eye = %f",diffLeftEye, diffRightEye);
        if (diffLeftEye > 10 && diffRightEye > 10){
            isSideFace = true;
            if (diffLeftEye < diffRightEye){
                isLeftSide = true;
            }else{
                isLeftSide = false;
            }
        }
        
        
        /*** CREATE FACE FRAME USING EYE AND MOUTH POSITION*/
        //        CGRect rect = CGRectMake(f.leftEyePosition.x - 30.0f, f.leftEyePosition.y + 30.0f, (f.rightEyePosition.x - f.leftEyePosition.x) + 60.0f, (f.mouthPosition.y - f.leftEyePosition.y ) + 60.0f);//f.bounds;
        //        rect.origin.y = imgSource.size.height - rect.origin.y;
        
        CGRect rect = f.bounds;
        rect.origin.x = rect.origin.x/3.2;
        rect.origin.y = rect.origin.y/2.5;
        
        rect.size.height = rect.size.height * 3;
        rect.size.width = rect.size.width * 2.7;
        //        if (f.hasSmile){
        //            rect.size.height += 20.0f;
        //        }
        // Crop face from image.
        
        if (f.hasFaceAngle){
            CGImageRef imgRef = [self CGImageRotatedByAngle:[imgSource CGImage] angle:f.faceAngle color:color];
            UIImage *imgPhotoStreght = [UIImage imageWithCGImage:imgRef];
            return imgPhotoStreght;
        }
        
        CGImageRef imageRef = CGImageCreateWithImageInRect(imgSource.CGImage, rect);
        imgPhoto = [UIImage imageWithCGImage:imageRef];
    }
    return imgPhoto;
}
-(void)createFaceDetector_V_0{
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:opts];
    
    rotatedImage = [self rotate:_myImage orientation:_myImage.imageOrientation];
    opts = @{CIDetectorImageOrientation : [NSNumber numberWithInt:1], CIDetectorSmile: [NSNumber numberWithBool:true]};
    CIImage *ciImage = [CIImage imageWithCGImage:rotatedImage.CGImage];
    NSArray *features = [detector featuresInImage:ciImage options:opts];
    
    arrFeatures = [features mutableCopy];
    for (int i=0; i<features.count; i++){
        CIFaceFeature *f = features[i];
        
        NSLog(@"Bound: %@",NSStringFromCGRect(f.bounds));
        
        /*** CREATE FACE FRAME USING EYE AND MOUTH POSITION*/
        float offsetEye = 10.0f;
        CGRect rect = CGRectMake(f.leftEyePosition.x - offsetEye,
                                 f.leftEyePosition.y - offsetEye,
                                 (f.rightEyePosition.x + offsetEye*2) - (f.leftEyePosition.x - offsetEye*2) ,
                                 10.0f);//f.bounds;
        
        if (f.mouthPosition.x < f.leftEyePosition.x){
            rect.origin.x = f.mouthPosition.x - offsetEye*2;
            rect.size.width = (f.rightEyePosition.x + offsetEye*2) - (f.mouthPosition.x - offsetEye*2);
            
        }else if(f.mouthPosition.x > f.rightEyePosition.x){
            rect.size.width = (f.mouthPosition.x + offsetEye*2)- (f.leftEyePosition.x - offsetEye*2);
        }
        
        if ((f.rightEyePosition.y < f.leftEyePosition.y) && (f.leftEyePosition.y > f.mouthPosition.y && f.rightEyePosition.y > f.mouthPosition.y)){
            //RIGHT EYE IS HIGHER THEN LEFT EYE
            rect.origin.y = f.rightEyePosition.y + offsetEye*2;
            rect.size.height =  (f.rightEyePosition.y - f.mouthPosition.y) + offsetEye;
            
        }else if ((f.leftEyePosition.y < f.rightEyePosition.y) && (f.leftEyePosition.y > f.mouthPosition.y && f.rightEyePosition.y > f.mouthPosition.y)){
            //LEFT EYE IS HIGHERE THAN RIGHT EYE
            rect.origin.y = f.leftEyePosition.y + offsetEye*2;
            rect.size.height =  (f.leftEyePosition.y - f.mouthPosition.y) + offsetEye;
        }
        rect.origin.y = rotatedImage.size.height - rect.origin.y;
        
        /*** CREATE FACE FRAME USING WHOLE FACE BOUND
         CGRect rect = f.bounds;
         rect.origin.y = (rotatedImage.size.height - rect.origin.y) - rect.size.height;
         */
        if (f.hasSmile){
            rect.size.height += 10.0f;
        }
        
        // Crop face from image.
        CGImageRef imageRef = CGImageCreateWithImageInRect(rotatedImage.CGImage, rect);
        UIImage *imgPhoto = [UIImage imageWithCGImage:imageRef];
        
        // Make Frame for imageview with respect to Image. So, it can fit on face.
        CGFloat y = (rect.origin.y * imgMyImage.frame.size.height) / rotatedImage.size.height;
        CGFloat x = (f.bounds.origin.x * imgMyImage.frame.size.width) / rotatedImage.size.width;
        CGFloat _width = (f.bounds.size.width * imgMyImage.frame.size.width) / rotatedImage.size.width;
        CGFloat _height = (f.bounds.size.height * imgMyImage.frame.size.height) / rotatedImage.size.height;
        
        // Create ImageView for number of faces.
        CGRect faceRect = CGRectMake(x, y, _width,_height);
        UIImageView *faceView = [[UIImageView alloc] initWithFrame:faceRect];
        faceView.tag = i;
        faceView.contentMode = UIViewContentModeScaleToFill;
        //faceView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        
        // Mask Image Processing
        UIImage *imgCirle = [UIImage imageNamed:@"Black mask_image"];
        
        // Calculate face angle and rotation
        CIFaceFeature *_selectedFace = f;
        float _rotationAngle = 0.f;
        if (_selectedFace.leftEyePosition.x != _selectedFace.rightEyePosition.x) {
            _rotationAngle = atan((_selectedFace.leftEyePosition.y - _selectedFace.rightEyePosition.y) / (_selectedFace.leftEyePosition.x - _selectedFace.rightEyePosition.x));
        }
        //_rotationAngle = _rotationAngle * -1.0;
        
        if (f.hasFaceAngle){
            //            imgCirle = [self imageRotatedByDegrees:_rotationAngle src:imgCirle];
            imgPhoto = [self imageRotatedByDegrees:_rotationAngle src:imgPhoto];
            faceView.transform = CGAffineTransformMakeRotation(radians(f.faceAngle));
        }
        imgPhoto = [self getFaceFromRotated:imgPhoto];
        
        imgPhoto = [self resizedFaceMaskImageToSize:imgCirle.size withImage:imgPhoto];
        
        faceRect.size.width = imgPhoto.size.width / 2.0;
        faceRect.size.height = imgPhoto.size.height / 2.0;
        faceView.frame = faceRect;
        
        
        //        imgCirle = [self resizedFaceMaskImageFromRect:imgPhoto.size withImage:imgCirle];
        
        [arrFacesOriginal addObject:imgPhoto];
        
        // Apply Mask on cropped face image.
        UIImage *imgResult = [self maskImage:imgPhoto withMask:imgCirle];
        
        if (swapType == Auto){
            faceView.image = imgResult;//[UIImage imageWithCGImage:imageRef];
            [faceImages addObject:imgResult];
            [faceView setUserInteractionEnabled:true];
            
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
            panGesture.minimumNumberOfTouches = 1;
            panGesture.maximumNumberOfTouches = 1;
            
            panGesture.delegate = self;
            [faceView addGestureRecognizer:panGesture];
            
            [scrMain.panGestureRecognizer requireGestureRecognizerToFail:panGesture];
            
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
            [faceView addGestureRecognizer:pinchGesture];
            
            UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
            [faceView addGestureRecognizer:rotateGesture];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [faceView addGestureRecognizer:tapGesture];
            
            faceView.userInteractionEnabled = YES;
            
            [imgMyImage addSubview:faceView];
            [faces addObject:faceView];
        }
        imgMyImage.userInteractionEnabled = true;
    }
}
-(void)createFaceDetector_V_1{
    CIContext *context = [CIContext contextWithOptions:nil];
    /*
     int exifOrientation;
     switch (_myImage.imageOrientation) {
     case UIImageOrientationUp:
     exifOrientation = 1;
     break;
     case UIImageOrientationDown:
     exifOrientation = 3;
     break;
     case UIImageOrientationLeft:
     exifOrientation = 8;
     break;
     case UIImageOrientationRight:
     exifOrientation = 6;
     break;
     case UIImageOrientationUpMirrored:
     exifOrientation = 2;
     break;
     case UIImageOrientationDownMirrored:
     exifOrientation = 4;
     break;
     case UIImageOrientationLeftMirrored:
     exifOrientation = 5;
     break;
     case UIImageOrientationRightMirrored:
     exifOrientation = 7;
     break;
     default:
     break;
     }
     */
    
    /*
     NSDictionary *options = nil;
     if([[ciImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation] == nil)
     {
     opts = @{CIDetectorImageOrientation : [NSNumber numberWithInt:1], CIDetectorSmile: [NSNumber numberWithBool:true]};
     }
     else
     {
     opts = @{CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString *)kCGImagePropertyOrientation]};
     }*/
    
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:opts];
    
    rotatedImage = [self rotate:_myImage orientation:_myImage.imageOrientation];
    opts = @{CIDetectorImageOrientation : [NSNumber numberWithInt:1], CIDetectorSmile: [NSNumber numberWithBool:true]};
    CIImage *ciImage = [CIImage imageWithCGImage:rotatedImage.CGImage];
    NSArray *features = [detector featuresInImage:ciImage options:opts];
    
    arrFeatures = [features mutableCopy];
    
    faceImages = [@[] mutableCopy];
    arrFacesOriginal = [@[] mutableCopy];
    
    arrMirroredface = [@[] mutableCopy];
    
    //    for (CIFaceFeature *f in features){
    for (int i=0; i<features.count; i++){
        CIFaceFeature *f = features[i];
        
        NSLog(@"Bound: %@",NSStringFromCGRect(f.bounds));
        
        /*** CREATE FACE FRAME USING EYE AND MOUTH POSITION
         CGRect rect = CGRectMake(f.leftEyePosition.x - 30.0f, f.leftEyePosition.y + 30.0f, (f.rightEyePosition.x - f.leftEyePosition.x) + 60.0f, (f.leftEyePosition.y - f.mouthPosition.y) + 60.0f);//f.bounds;
         rect.origin.y = rotatedImage.size.height - rect.origin.y;
         */
        
        /*** CREATE FACE FRAME USING WHOLE FACE BOUND*/
        CGRect rect = f.bounds;
        rect.origin.y = (rotatedImage.size.height - rect.origin.y) - rect.size.height;
        
        if (f.hasSmile){
            rect.size.height += 10.0f;
        }
        // Crop face from image.
        CGImageRef imageRef = CGImageCreateWithImageInRect(rotatedImage.CGImage, rect);
        UIImage *imgPhoto = [UIImage imageWithCGImage:imageRef];
        [arrFacesOriginal addObject:imgPhoto];
        
        // Make Frame for imageview with respect to Image. So, it can fit on face.
        CGFloat y = (rect.origin.y * imgMyImage.frame.size.height) / rotatedImage.size.height;
        CGFloat x = (f.bounds.origin.x * imgMyImage.frame.size.width) / rotatedImage.size.width;
        CGFloat _width = (f.bounds.size.width * imgMyImage.frame.size.width) / rotatedImage.size.width;
        CGFloat _height = (f.bounds.size.height * imgMyImage.frame.size.height) / rotatedImage.size.height;
        
        // Create ImageView for number of faces.
        CGRect faceRect = CGRectMake(x, y, _width,_height);
        UIImageView *faceView = [[UIImageView alloc] initWithFrame:faceRect];
        faceView.tag = i;
        faceView.contentMode = UIViewContentModeScaleToFill;
        //faceView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        
        // Mask Image Processing
        UIImage *imgCirle = [UIImage imageNamed:@"Black mask_image"];
        
        CIFaceFeature *_selectedFace = f;
        float _rotationAngle = 0.f;
        if (_selectedFace.leftEyePosition.x != _selectedFace.rightEyePosition.x) {
            _rotationAngle = atan((_selectedFace.leftEyePosition.y - _selectedFace.rightEyePosition.y) / (_selectedFace.leftEyePosition.x - _selectedFace.rightEyePosition.x));
        }
        _rotationAngle = _rotationAngle * -1.0;
        
        if (f.hasFaceAngle){
            //            imgCirle = [self rotate:imgCirle angle:_rotationAngle];
            imgCirle = [self imageRotatedByDegrees:_rotationAngle src:imgCirle];
        }
        
        // Apply Mask on cropped face image.
        UIImage *imgResult = [self maskImage:imgPhoto withMask:imgCirle];
        
        if (swapType == Auto){
            faceView.image = imgResult;//[UIImage imageWithCGImage:imageRef];
            [faceImages addObject:imgResult];
            [faceView setUserInteractionEnabled:true];
            
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
            panGesture.minimumNumberOfTouches = 1;
            panGesture.maximumNumberOfTouches = 1;
            
            panGesture.delegate = self;
            [faceView addGestureRecognizer:panGesture];
            
            [scrMain.panGestureRecognizer requireGestureRecognizerToFail:panGesture];
            
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
            [faceView addGestureRecognizer:pinchGesture];
            
            UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
            [faceView addGestureRecognizer:rotateGesture];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [faceView addGestureRecognizer:tapGesture];
            
            faceView.userInteractionEnabled = YES;
            
            [imgMyImage addSubview:faceView];
            [faces addObject:faceView];
        }
        else{
            if (_width < 60.0f)
                _width = 60.0f;
            if (_height < 60.0f)
                _height = 60.0f;
            faceRect.size.width = _width;
            faceRect.size.height = _height;
            
            //            MaskView *maskView = [[MaskView alloc] initWithFrame:faceRect];
            //            maskView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
            
            SPUserResizableView *imageResizableView = [[SPUserResizableView alloc] initWithFrame:faceRect];
            //            SPUserResizableView *imageResizableView = [[SPUserResizableView alloc] initWithFrame:CGRectMake(5, 5, faceRect.size.width - 5, faceRect.size.height - 5)];
            imageResizableView.delegate = self;
            
            //            imageResizableView.backgroundColor = [UIColor blueColor];
            faceView.image = selectedMaskImage;
            imageResizableView.contentView = faceView;
            //            imageResizableView.contentView.alpha = 0.5f;
            [imageResizableView addSubview:faceView];
            //            faceView.frame = CGRectMake(0, 0, imageResizableView.frame.size.width, imageResizableView.frame.size.height);
            //            [maskView addSubview:imageResizableView];
            
            UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
            [imageResizableView addGestureRecognizer:rotateGesture];
            
            [imgMyImage addSubview:imageResizableView];
            
            [faces addObject:imageResizableView];
        }
        imgMyImage.userInteractionEnabled = true;
    }
}
-(void)createFaceDetector_V_2{
    CIContext *context = [CIContext contextWithOptions:nil];
    
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh,CIDetectorSmile: [NSNumber numberWithBool:true] };
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:opts];
    
    rotatedImage = [self rotate:_myImage orientation:_myImage.imageOrientation];
    
    opts = @{CIDetectorImageOrientation : [NSNumber numberWithInt:1], CIDetectorSmile: [NSNumber numberWithBool:true]};
    
    CIImage *ciImage = [CIImage imageWithCGImage:rotatedImage.CGImage];
    NSArray *features = [detector featuresInImage:ciImage options:opts];
    
    for (int i = 2 ;i <= 8 && features.count == 0; i++){
        opts = @{CIDetectorImageOrientation : [NSNumber numberWithInt:i], CIDetectorSmile: [NSNumber numberWithBool:true]};
        features = [detector featuresInImage:ciImage options:opts];
    }
    arrFeatures = [features mutableCopy];
    arr_Rotation = [@[]mutableCopy];
    
    //    for (int i = 0; i < arrFeatures.count; i++) {
    //        CIFaceFeature *f1 = arrFeatures[i];
    //        float  diff = f1.faceAngle;
    //        [arr_Rotation addObject:[NSString stringWithFormat:@"%f",diff]];
    //    }
    //    int a = fmodf(SwipeAutomaticCount,faces.count);
    //    for (int i = 0; i < a; i++) {
    //        CIFaceFeature *f2 = arrFeatures[arrFeatures.count - 1];
    //        [arrFeatures removeObjectAtIndex:arrFeatures.count-1];
    //        [arrFeatures addObject:f2];
    //    }
    
    faceImages = [@[] mutableCopy];
    arrFacesOriginal = [@[] mutableCopy];
    arr_FaceAutoSwap = [@[] mutableCopy];
    arrMirroredface = [@[] mutableCopy];
    arr_FaceColor = [@[] mutableCopy];
    arr_sliderValue_Brightness = [@[] mutableCopy];
    arr_sliderValue_Color = [@[] mutableCopy];
    
    arr_FaceWidth = [@[]mutableCopy];
    arr_FaceHeight = [@[]mutableCopy];
    arr_FaceX = [@[]mutableCopy];
    arr_FaceY = [@[]mutableCopy];
    //    for (CIFaceFeature *f in features){
    for (int i=0; i<features.count; i++){
        CIFaceFeature *f = features[i];
        [arr_sliderValue_Brightness addObject:@"0.5"];
        [arr_sliderValue_Color addObject:@"0.5"];
        
        
        /*  JUST FOR PRINT FACE DETECTION OBJECT'S LOCATION
         NSLog(@"1..Bound: %@",NSStringFromCGRect(f.bounds));
         if (f.hasLeftEyePosition){
         NSLog(@"LeftEyePosition: %@",NSStringFromCGPoint(f.leftEyePosition));
         }
         if (f.hasRightEyePosition){
         NSLog(@"RightEyePosition: %@",NSStringFromCGPoint(f.rightEyePosition));
         }
         if (f.hasMouthPosition){
         NSLog(@"MouthPosition: %@",NSStringFromCGPoint(f.mouthPosition));
         }
         */
        /*** CREATE FACE FRAME USING EYE AND MOUTH POSITION*/
        //        CGRect rect = CGRectMake(x1, highestY, width, height);
        
        /* CGRect rect = CGRectMake(f.leftEyePosition.x - offsetOnImage,
         highestY +offsetOnImage,
         (f.rightEyePosition.x - f.leftEyePosition.x) + offsetOnImage*2,
         (f.leftEyePosition.y - f.mouthPosition.y) + offsetOnImage);//f.bounds;
         rect.origin.y = rotatedImage.size.height - rect.origin.y;*/
        
        
        /*** CREATE FACE FRAME USING WHOLE FACE BOUND */
        CGRect rect = f.bounds;
        rect.origin.y = (rotatedImage.size.height - rect.origin.y) - rect.size.height;
        //        rect.size.height -= 10.0f;
        //        rect.size.width -= 10.0f;
        //        rect.origin.x -=10.0f;
        
        // Crop face from image.
        CGImageRef imageRef = CGImageCreateWithImageInRect(rotatedImage.CGImage, rect);
        UIImage *imgPhoto = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        [arrFacesOriginal addObject:imgPhoto];
        
        // Make Frame for imageview with respect to Image. So, it can fit on face.
        CGFloat y = (rect.origin.y * imgMyImage.frame.size.height) / rotatedImage.size.height;
        CGFloat x = (f.bounds.origin.x * imgMyImage.frame.size.width) / rotatedImage.size.width;
        CGFloat _width = (f.bounds.size.width * imgMyImage.frame.size.width) / rotatedImage.size.width;
        CGFloat _height = (f.bounds.size.height * imgMyImage.frame.size.height) / rotatedImage.size.height;
        
        // Create ImageView for number of faces.
        CGRect faceRect = CGRectMake(x, y, _width,_height);
        UIImageView *faceView = [[UIImageView alloc] initWithFrame:faceRect];
        faceView.tag = i+1;
        
        faceView.contentMode = UIViewContentModeScaleAspectFill;
        //faceView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        //faceView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.2];
        
        /*
         CIFaceFeature *_selectedFace = f;
         float _rotationAngle = 0.f;
         if (_selectedFace.leftEyePosition.x != _selectedFace.rightEyePosition.x) {
         _rotationAngle = atan((_selectedFace.leftEyePosition.y - _selectedFace.rightEyePosition.y) / (_selectedFace.leftEyePosition.x - _selectedFace.rightEyePosition.x));
         }
         _rotationAngle = _rotationAngle * -1.0;
         */
        
        //        if (f.hasFaceAngle){
        //            imgCirle = [self imageRotatedByDegrees:_rotationAngle src:imgCirle];
        //            CGImageRef imageRef =  [self CGImageRotatedByAngle:[imgCirle CGImage] angle:f.faceAngle*-1.0];
        //            imgCirle = [UIImage imageWithCGImage: imageRef];
        //            imgCirle = [self resizedFaceMaskImageFromRect:imgPhoto.size withImage:imgCirle];
        //        }
        NSArray *arrColors = [MainControllerVC getRGBAsFromImage:imgPhoto atX:imgPhoto.size.width/2.0f andY:imgPhoto.size.height/2.0f count:1];
        CGSize sizeFace = imgPhoto.size;
        [arr_FaceColor addObject:[arrColors objectAtIndex:0]];
        CGColorRef color = [arrColors[0] CGColor];
        NSInteger numComponents = CGColorGetNumberOfComponents(color);
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(color);
            CGFloat red = components[0];
            CGFloat green = components[1];
            CGFloat blue = components[2];
            //            CGFloat alpha = components[3];
            float red_New = red*red*255.0*255.0*0.241;
            float green_New = green*green*255.0*255.0*0.691;
            float blue_New = blue*blue*255.0*255.0*0.068;
            float num =sqrtf(red_New+green_New+blue_New);
            NSLog(@"sqaure %f",num);
        }
        CGImageRef imagePhotoRef ;
        if (arrColors.count > 0)
            imagePhotoRef = [self CGImageRotatedByAngle:[imgPhoto CGImage] angle:f.faceAngle color:arrColors[0]];
        else
            imagePhotoRef = [self CGImageRotatedByAngle:[imgPhoto CGImage] angle:f.faceAngle];
        UIImage *imgStretFace = [UIImage imageWithCGImage:imagePhotoRef];
        
        imgStretFace = [self resizedFaceMaskImageToSize:CGSizeMake(sizeFace.width + sizeFace.width/10.0f, sizeFace.height + sizeFace.height/10.0f) withImage:imgStretFace];
        
        isSideFace = false;
        isLeftSide = false;
        if (arrColors.count > 0){
            imgStretFace = [self getFaceFromRotated:imgStretFace color:arrColors[0]];
        }else{
            imgStretFace = [self getFaceFromRotated:imgStretFace];
        }
        
        UIImage *imgCirle;
        if (isSideFace == true){
            imgCirle = [UIImage imageNamed:@"Black mask_image_half"];
            if (isLeftSide){
                imgCirle = [self flipImage:imgCirle];
            }
        }else{
            // Mask Image Processing
            imgCirle = [UIImage imageNamed:@"Black mask_image"];
        }
        
        imgCirle = [self resizedFaceMaskImageToSize:sizeFace withImage:imgCirle];
        //        imgCirle = [self resizedFaceMaskImageFromRect:CGSizeMake(sizeFace.width-sizeFace.width/2.0f, sizeFace.height-sizeFace.height/2.0f) withImage:imgCirle];
        
        
        // Apply Mask on cropped face image.
        UIImage *imgResult = [self maskImage:imgStretFace withMask:imgCirle];//imgPhoto;
        
        if (swapType == Auto){
            faceView.image = imgResult;//[UIImage imageWithCGImage:imageRef];
            [faceImages addObject:imgResult];
            [faceView setUserInteractionEnabled:true];
            //COMMENT : GIRISH code for mask location slide in ui
            
            /*UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
             panGesture.minimumNumberOfTouches = 1;
             panGesture.maximumNumberOfTouches = 1;
             
             panGesture.delegate = self;
             [faceView addGestureRecognizer:panGesture];
             
             [scrMain.panGestureRecognizer requireGestureRecognizerToFail:panGesture];*/
            
            /*UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
             [faceView addGestureRecognizer:pinchGesture];
             
             UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
             [faceView addGestureRecognizer:rotateGesture];*/
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [faceView addGestureRecognizer:tapGesture];
            
            faceView.userInteractionEnabled = YES;
            // Maulik Changes
            
            [imgMyImage addSubview:faceView];
            
            //            faceView.frame = CGRectMake(faceView.frame.origin.x, faceView.frame.origin.y+ imgMyImage.frame.origin.y,faceView.frame.size.width, faceView.frame.size.height);
            //            [scrMain addSubview:faceView];
            [arr_FaceWidth addObject:[NSString stringWithFormat:@"%f",faceView.bounds.size.width]];
            [arr_FaceHeight addObject:[NSString stringWithFormat:@"%f",faceView.bounds.size.height]];
            [arr_FaceY addObject:[NSString stringWithFormat:@"%f",faceView.frame.origin.y]];
            [arr_FaceX addObject:[NSString stringWithFormat:@"%f",faceView.frame.origin.x]];
            [faces addObject:faceView];
            [arr_FaceAutoSwap addObject:faceView.image];
        }
        imgMyImage.userInteractionEnabled = true;
    }
    //        if (swapType == Auto) {
    //            int a = fmodf(SwipeAutomaticCount,faces.count);
    //            NSLog(@"Count Modulo %d",a);
    //            for (int i = 0; i < a; i++) {
    //                UIView *sub = faces[faces.count-1];
    //                [faces removeObjectAtIndex:faces.count-1];
    //                [faces insertObject:sub atIndex:0];
    //                CIFaceFeature *f2 = arrFeatures[arrFeatures.count-1];
    //                [arrFeatures removeObjectAtIndex:arrFeatures.count-1];
    //                [arrFeatures insertObject:f2 atIndex:0];
    //                UIImage *faceImage = faceImages[faceImages.count - 1];
    //                [faceImages removeObjectAtIndex:faceImages.count-1];
    //                [faceImages insertObject:faceImage atIndex:0];
    //
    //                UIImage *faceImageOrignal = arrFacesOriginal[arrFacesOriginal.count - 1];
    //                [arrFacesOriginal removeObjectAtIndex:arrFacesOriginal.count-1];
    //                [arrFacesOriginal insertObject:faceImageOrignal atIndex:0];
    //
    //                //            UIImage *faceImageMirror = arrMirroredface[arrMirroredface.count - 1];
    //                //            [arrMirroredface removeObjectAtIndex:arrMirroredface.count-1];
    //                //            [arrMirroredface insertObject:faceImageMirror atIndex:0];
    //
    //            }
    //            for (int  k = 0; k  < faces.count; k++) {
    //                [imgMyImage addSubview:faces[k]];
    //            }
    //        }
}
-(void)swapFaces_My{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"swapSound"
                                         ofType:@"wav"]];
    audioPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:url
                   error:nil];
    //    audioPlayer.volume = 10.0f;
    [audioPlayer play];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    self.view.alpha = 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 1;
    }];
    
    
    //SWAP FACES
    //int prev = 0;
    CGRect lastRect;
    CGRect nextRect;
    
    float maxIndex = 0;
    maxIndex = faces.count;
    
    if (faces.count > 1){
        UIImageView *img2 = faces[faces.count - 1 ];
        CGRect rect1 = img2.frame;
        lastRect = rect1;
        UIImageView *imgNext = faces[0];
        nextRect = imgNext.frame;
    }
    
    //Give how many time auto swap clicked count to modulo
    int ButtonClickCount = fmodf(SwipeAutomaticCount,faces.count);
    for (int n = 0; n < ButtonClickCount; n++) {
        for (int i = 0; i < maxIndex; i++){
            UIImageView *img1 = faces[0];
            CGRect rect1 = img1.frame;
            UIImageView *img2 = faces[i];
            
            /** Swap frame */
            CGRect rect2 = img2.frame;
            img2.frame = rect1;
            img1.frame = rect2;
            if (n+1 == ButtonClickCount ) {
                //Create two view with animation for swap
                UIView *animView1 = img1;
                UIView *animView2 = img2;
                CATransition *transition = [[CATransition alloc] init];
                transition.startProgress = 0.0f;
                transition.endProgress = 1.0f;
                transition.duration = 0.4f;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromLeft;
                //                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                //                transition.type = kCATransitionFade;
                
                CATransition *transition1 = [[CATransition alloc] init];
                transition1.startProgress = 0.0f;
                transition1.endProgress = 1.0f;
                transition1.duration = 0.4f;
                transition1.type = kCATransitionPush;
                transition1.subtype = kCATransitionFromRight;
                //                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                //                transition.type = kCATransitionFade;
                
                //                transition.type = kCATransitionReveal;
                [animView2.layer addAnimation:transition1 forKey:@"opacity"];
                [animView1.layer addAnimation:transition forKey:@"opacity"];
                
                
            }
        }
    }
    for (int i = 0; i < maxIndex; i++){
        UIImageView *img1 = faces[i];
        
        //Frame angel change
        int frameangel = fmodf(i+faces.count-ButtonClickCount,faces.count);
        CIFaceFeature *f1 = arrFeatures[frameangel];
        if (f1.hasFaceAngle){
            float  diff = f1.faceAngle;
            img1.transform = CGAffineTransformMakeRotation(radians(diff));
            [arr_Rotation addObject:[NSString stringWithFormat:@"%f",diff]];
        }else{
            float  diff = f1.faceAngle;
            [arr_Rotation addObject:[NSString stringWithFormat:@"%f",diff]];
        }
        continue;
    }
    //    [audioPlayer stop];
    
    /*New Logic for simple face swap
     for (int i = 0; i < maxIndex; i++){
     UIImageView *img1 = faces[i];
     
     //Frame angel change
     int frameangel = fmodf(i+faces.count-ButtonClickCount,faces.count);
     CIFaceFeature *f1 = arrFeatures[i];
     if (f1.hasFaceAngle){
     float  diff = f1.faceAngle;
     img1.transform = CGAffineTransformMakeRotation(radians(diff));
     [arr_Rotation addObject:[NSString stringWithFormat:@"%f",diff]];
     }else{
     float  diff = f1.faceAngle;
     [arr_Rotation addObject:[NSString stringWithFormat:@"%f",diff]];
     }
     img1.image = arr_FaceAutoSwap[frameangel];
     
     continue;
     }
     
*/
}

-(void)swapFaces{
    //SWAP FACES
    //int prev = 0;
    CGRect lastRect;
    CGRect nextRect;
    
    float maxIndex = 0;
    if(faces.count%2 != 0)
        maxIndex = faces.count - 1;
    else
        maxIndex = faces.count;
    
    if (faces.count > 1){
        UIImageView *img2 = faces[faces.count - 1 ];
        CGRect rect1 = img2.frame;
        lastRect = rect1;
        
        UIImageView *imgNext = faces[0];
        nextRect = imgNext.frame;
    }
    
    for (int i = 1; i < maxIndex; i=i+2){
        UIImageView *img1 = faces[i-1];
        CIFaceFeature *f1 = arrFeatures[i-1];
        
        CGRect rect1 = img1.frame;
        
        UIImageView *img2 = faces[i];
        CIFaceFeature *f2 = arrFeatures[i];
        
        /** Swap frame */
        CGRect rect2 = img2.frame;
        img2.frame = rect1;
        img1.frame = rect2;
        
        // JUST ROTATE FACES
        if (f1.hasFaceAngle){
            float  diff = f1.faceAngle;
            //            if (f2.hasFaceAngle){
            //                diff = f1.faceAngle - f2.faceAngle;
            //            }
            img2.transform = CGAffineTransformMakeRotation(radians(diff));
        }
        if (f2.hasFaceAngle){
            float  diff = f2.faceAngle;
            //            if (f2.hasFaceAngle){
            //                diff = f1.faceAngle - f2.faceAngle;
            //            }
            img1.transform = CGAffineTransformMakeRotation(radians(diff));
        }
        continue;
        /** NOT REQUIRED CODE
         **
         // ROTATE SECOND FACE
         if (f1.hasFaceAngle){
         
         float  diff = f1.faceAngle;
         if (f2.hasFaceAngle){
         diff = f1.faceAngle - f2.faceAngle;
         }
         img2.transform = CGAffineTransformMakeRotation(radians(diff));
         
         //            //STORE ROTATION
         //            NSString *key = [NSString stringWithFormat:@"%d",(int)img2.tag];
         //            [_dictTransform setObject:[NSNumber numberWithFloat:diff] forKey:key];
         
         // arrFaceAngle[i] = [NSNumber numberWithFloat:diff];
         }else if (f2.hasFaceAngle){
         float  diff = f2.faceAngle * -1.0;
         img2.transform = CGAffineTransformMakeRotation(radians(diff));
         
         //            //STORE ROTATION
         //            NSString *key = [NSString stringWithFormat:@"%d",(int)img2.tag];
         //            [_dictTransform setObject:[NSNumber numberWithFloat:diff] forKey:key];
         }
         if (f2.hasFaceAngle){
         //            CIFaceFeature *_selectedFace = f2;// the face feature
         //            float _rotationAngle = 0.f;
         //            if (_selectedFace.leftEyePosition.x != _selectedFace.rightEyePosition.x) {
         //                _rotationAngle = atan((_selectedFace.leftEyePosition.y - _selectedFace.rightEyePosition.y) / (_selectedFace.leftEyePosition.x - _selectedFace.rightEyePosition.x));
         //            }
         //            _rotationAngle = _rotationAngle * -1.0;
         
         float  diff = f2.faceAngle;
         if (f1.hasFaceAngle){
         diff = f2.faceAngle - f1.faceAngle;
         }else{
         // diff = 360 - diff;
         }
         //            img1.transform = CGAffineTransformMakeRotation(_rotationAngle);
         img1.transform = CGAffineTransformMakeRotation(radians(diff));
         //arrFaceAngle[i-1] = [NSNumber numberWithFloat:diff];
         
         //            //STORE ROTATION
         //            NSString *key = [NSString stringWithFormat:@"%d",(int)img1.tag];
         //            [_dictTransform setObject:[NSNumber numberWithFloat:diff] forKey:key];
         }else if(f1.hasFaceAngle){
         img1.transform = CGAffineTransformMakeRotation(radians(f1.faceAngle * -1.0));
         
         //            //STORE ROTATION
         //            NSString *key = [NSString stringWithFormat:@"%d",(int)img2.tag];
         //            [_dictTransform setObject:[NSNumber numberWithFloat:f1.faceAngle * -1.0] forKey:key];
         }
         */
        
        //prev = i;
    }
    
    if (faces.count % 2 != 0){
        CIFaceFeature *f1 = arrFeatures[0];
        
        CIFaceFeature *f2 = arrFeatures[faces.count - 1];
        
        UIImageView *img1 = faces[0];
        //        CIFaceFeature *f1 = arrFeatures[0];
        
        CGRect rect1 = img1.frame;
        
        UIImageView *img2 = faces[faces.count-1];
        //        CIFaceFeature *f2 = arrFeatures[faces.count-1];
        
        //Swap faces
        CGRect rect2 = img2.frame;
        img2.frame = rect1;
        img1.frame = rect2;
        // JUST ROTATE FACES
        if (f1.hasFaceAngle){
            float  diff = f1.faceAngle;
            //            if (f2.hasFaceAngle){
            //                diff = f1.faceAngle - f2.faceAngle;
            //            }
            img2.transform = CGAffineTransformMakeRotation(radians(diff));
        }
        if (f2.hasFaceAngle){
            float  diff = f2.faceAngle;
            //            if (f2.hasFaceAngle){
            //                diff = f1.faceAngle - f2.faceAngle;
            //            }
            img1.transform = CGAffineTransformMakeRotation(radians(diff));
        }
        /** NOT REQUIRED CODE.
         ** ROTATE SECOND FACE
         
         if (f1.hasFaceAngle){
         //            CIFaceFeature *_selectedFace = f1;// the face feature
         //            float _rotationAngle = 0.f;
         //            if (_selectedFace.leftEyePosition.x != _selectedFace.rightEyePosition.x) {
         //                _rotationAngle = atan((_selectedFace.leftEyePosition.y - _selectedFace.rightEyePosition.y) / (_selectedFace.leftEyePosition.x - _selectedFace.rightEyePosition.x));
         //            }
         //            _rotationAngle = _rotationAngle;
         
         float  diff = f1.faceAngle;
         if (f2.hasFaceAngle){
         diff = f1.faceAngle - f2.faceAngle;
         }
         img2.transform = CGAffineTransformMakeRotation(radians(diff));
         
         // arrFaceAngle[i] = [NSNumber numberWithFloat:diff];
         }else if (f2.hasFaceAngle){
         float  diff = f2.faceAngle * -1.0;
         img2.transform = CGAffineTransformMakeRotation(radians(diff));
         }
         if (f2.hasFaceAngle){
         CIFaceFeature *_selectedFace = f2;// the face feature
         float _rotationAngle = 0.f;
         if (_selectedFace.leftEyePosition.x != _selectedFace.rightEyePosition.x) {
         _rotationAngle = atan((_selectedFace.leftEyePosition.y - _selectedFace.rightEyePosition.y) / (_selectedFace.leftEyePosition.x - _selectedFace.rightEyePosition.x));
         }
         _rotationAngle = _rotationAngle * -1.0;
         
         float  diff = f2.faceAngle;
         if (f1.hasFaceAngle){
         diff = f2.faceAngle - f1.faceAngle;
         }else{
         // diff = 360 - diff;
         }
         img1.transform = CGAffineTransformMakeRotation(_rotationAngle);
         //            img1.transform = CGAffineTransformMakeRotation(radians(diff));
         //arrFaceAngle[i-1] = [NSNumber numberWithFloat:diff];
         }else if(f1.hasFaceAngle){
         img1.transform = CGAffineTransformMakeRotation(radians(f1.faceAngle * -1.0));
         }*/
    }
    [audioPlayer stop];
}

-(void)SwapFacesForManual{
    isManualFaceSwaped = true;
    UIImage *faceMaskedImage = selectedMaskImage;//[UIImage imageNamed:@"face3_mask"];
    
    for (int i = 1; i < faces.count; i=i+2){
        // *** First Image
        //        SPUserResizableView *view1 = faces[i-1];
        //        [view1 hideEditingHandles];
        //        UIImageView *img1 = (UIImageView *)view1.contentView;
        MaskView *view1 = faces[i-1];
        UIImageView *img1 = (UIImageView *)view1.faceView;
        img1.backgroundColor = [UIColor clearColor];
        
        
        //        UIImageView *img1 = faces[i-1];
        CGRect rect = view1.frame;
        //Crop face from actual image
        CGRect cropRect =  [self convertRectToImageRect:rect];
        CGImageRef imageRef = CGImageCreateWithImageInRect(finalImage.CGImage, cropRect);
        
        UIImage *imgSquar_1 = [UIImage imageWithCGImage:imageRef];
        //Create face maske image which fit with face.
        UIImage *imgResizedMask = [self resizedFaceMaskImageToSize:imgSquar_1.size withImage:faceMaskedImage];
        UIImage *imgMasked_1 = [self maskImage:imgSquar_1 withMask:imgResizedMask];
        img1.image = imgMasked_1;
        
        CGRect rect1 = view1.frame; //img1.frame;
        
        // *** Second Image
        //        SPUserResizableView *view2 = faces[i];
        //        [view2 hideEditingHandles];
        //        UIImageView *img2 = (UIImageView *) view2.contentView;
        MaskView *view2 = faces[i];
        UIImageView *img2 = (UIImageView *) view2.faceView;
        img2.backgroundColor = [UIColor clearColor];
        
        //        UIImageView *img2 = faces[i];
        CGRect rect2 = view2.frame;
        //Crop face from actual image
        
        CGImageRef imageRef2 = CGImageCreateWithImageInRect(finalImage.CGImage,  [self convertRectToImageRect:rect2]);
        UIImage *imgSquar_2 = [UIImage imageWithCGImage:imageRef2];
        //Create face maske image which fit with face.
        UIImage *imgResizedMask2 = [self resizedFaceMaskImageToSize:imgSquar_2.size withImage:faceMaskedImage];
        UIImage *imgMasked_2 = [self maskImage:imgSquar_2 withMask:imgResizedMask2];
        img2.image = imgMasked_2;
        
        // *** SWAP BOTH IMAGES
        view2.frame = rect1;  //img2.frame = rect1;
        view1.frame = rect2;    //img1.frame = rect2;
        
        //prev = i;
    }
    if (faces.count % 2 != 0){
        // *** Last Image
        //        SPUserResizableView *view1 = faces[faces.count - 1];
        //        [view1 hideEditingHandles];
        //        UIImageView *img1 = (UIImageView *)view1.contentView;
        
        MaskView *view1 = faces[faces.count - 1];
        UIImageView *img1 = (UIImageView *)view1.faceView;
        img1.backgroundColor = [UIColor clearColor];
        //UIImageView *img1 = faces[faces.count - 1];
        
        CGRect rect = view1.frame;//img1.frame;
        //Crop face from actual image
        CGImageRef imageRef = CGImageCreateWithImageInRect(imgMyImage.image.CGImage, [self convertRectToImageRect:rect]);
        UIImage *imgSquar_1 = [UIImage imageWithCGImage:imageRef];
        //Create face maske image which fit with face.
        UIImage *imgResizedMask = [self resizedFaceMaskImageToSize:imgSquar_1.size withImage:faceMaskedImage];
        UIImage *imgMasked_1 = [self maskImage:imgSquar_1 withMask:imgResizedMask];
        img1.image = imgMasked_1;
        CGRect rect1 = view1.frame;//img1.frame;
        
        // *** Second Image
        //        SPUserResizableView *view2 = faces[0];
        //UIImageView *img2 = (UIImageView *)view2.contentView;//faces[0];
        MaskView *view2 = faces[0];
        CGRect rect2 = view2.frame;// img2.frame;
        
        // *** SWAP BOTH IMAGES
        view2.frame = rect1;  //img2.frame = rect1;
        view1.frame = rect2;    //img1.frame = rect2;
    }
}


-(UIImage *)resizedFaceMaskImageToSize:(CGSize)size withImage:(UIImage *)currentImage{
    UIGraphicsBeginImageContext(size);
    [[UIColor whiteColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(),CGRectMake(0,0, size.width+5.0f , size.height+5.0f));
    
    [currentImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return picture1;
}
-(CGRect)convertRectToImageRect:(CGRect)rect{
    CGRect rectImageview = imgMyImage.frame;
    
    CGRect rectForFullImage = CGRectMake(0,0,finalImage.size.width, finalImage.size.height); //CGRectMake(0,0, fixWidth, aspectHeight);
    
    rect.origin.x = rect.origin.x + 5;
    rect.origin.y = rect.origin.y + 5;
    rect.size.height = rect.size.height - 10;
    rect.size.width = rect.size.width - 10;
    CGRect frameTemp = rect;
    CGRect newRect;
    
    newRect.origin.x = (rectForFullImage.size.width * frameTemp.origin.x) / rectImageview.size.width;
    newRect.origin.y = (rectForFullImage.size.height * frameTemp.origin.y) / rectImageview.size.height;
    
    newRect.size.height = (rectForFullImage.size.height * frameTemp.size.height) / rectImageview.size.height;
    
    newRect.size.width = (rectForFullImage.size.width * frameTemp.size.width) / rectImageview.size.width;
    
    return  newRect;
}
-(CGRect)convertOriginRectToImageRect:(CGRect)rect{
    CGRect rectImageview = imgMyImage.frame;
    
    CGRect rectForFullImage = CGRectMake(0,0,finalImage.size.width, finalImage.size.height); //CGRectMake(0,0, fixWidth, aspectHeight);
    
    
    CGRect frameTemp = rect;
    CGRect newRect;
    
    newRect.origin.x = (rectForFullImage.size.width * frameTemp.origin.x) / rectImageview.size.width;
    newRect.origin.y = (rectForFullImage.size.height * frameTemp.origin.y) / rectImageview.size.height;
    
    newRect.size.height = (rectForFullImage.size.height * frameTemp.size.height) / rectImageview.size.height;
    
    newRect.size.width = (rectForFullImage.size.width * frameTemp.size.width) / rectImageview.size.width;
    
    return  newRect;
}
#pragma mark - Gesture Recognize method
//Main image
- (IBAction)handlePinchMain:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    NSLog(@"tx: %f, ty: %f",recognizer.view.transform.c,recognizer.view.transform.d);
    
    if (recognizer.view.transform.d > 1.0){
        panMain.enabled = true;
    }else{
        panMain.enabled = false;
    }
    recognizer.scale = 1;
}
-(IBAction)panDetectedMain:(UIPanGestureRecognizer *)recognizer{
    
    
    [self RemoveOldMaskFrame];
    
    /*CGPoint translatedPoint = [recognizer translationInView:self.view];
     if ([recognizer state] == UIGestureRecognizerStateBegan) {
     firstXMain = [[recognizer view] center].x;
     firstYMain = [[recognizer view] center].y;
     }
     
     translatedPoint = CGPointMake(firstXMain+translatedPoint.x, firstYMain+translatedPoint.y);
     
     //    for (UIImageView *face in faces){
     //        CGRect rect = face.frame;
     //        rect =  [face convertRect:rect toView:recognizer.view];
     //        //CGPoint point = [face convertPoint:translatedPoint toView:recognizer.view];
     //        if (CGRectContainsPoint(rect, translatedPoint) == true){
     //            return;
     //        }
     //    }
     
     [[recognizer view] setCenter:translatedPoint];*/
}
- (UIImage *)flipImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform =CGAffineTransformMakeTranslation(image.size.width, 0.0);
    transform = CGAffineTransformScale(transform, -1.0, 1.0);
    CGContextConcatCTM(context, transform);
    //draw image in the context
    //CGContextDrawImage(context, CGRectMake(0.,0., image.size.width, image.size.height), ((UIImage*)image).CGImage);
    [image drawInRect:CGRectMake(0.,0., image.size.width, image.size.height)];
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return i;
}
- (UIImage *)flipVerticleImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform =CGAffineTransformMakeTranslation(image.size.width, 0.0);
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGContextConcatCTM(context, transform);
    //draw image in the context
    //CGContextDrawImage(context, CGRectMake(0.,0., image.size.width, image.size.height), ((UIImage*)image).CGImage);
    [image drawInRect:CGRectMake(0.,0., image.size.width, image.size.height)];
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return i;
}
-(void)RemoveOldMaskFrame{
    for (int j = 0;  j <faces.count; j++) {
        UIImageView *ImgTemp = faces[j];
        if (ImgTemp.tag == Tag_MaskDetail) {
            //            float Temp = scale /[arr_FaceZooming[j] floatValue];
            [arr_FaceWidth replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%f",ImgTemp.frame.size.width]];
            [arr_FaceHeight replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%f",ImgTemp.frame.size.height]];
            [arr_FaceX replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%f",ImgTemp.frame.origin.x]];
            [arr_FaceY replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%f",ImgTemp.frame.origin.y]];
            break;
        }
    }
    
    scrMain.minimumZoomScale = 1.0f;
    scrMain.maximumZoomScale = 2.5f;
    if (Tag_MaskDetail == 0) {
        
    }else{
        UIImageView *ImgOld;
        
        for (UIView *subview in scrMain.subviews) {
            if (subview.tag == Tag_MaskDetail){
                ImgOld = subview;
            }
        }
        //        panGesture_Face = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
        
        [scrMain removeGestureRecognizer:panGesture_Face];
        [scrMain removeGestureRecognizer:pinchGestureImg];
        [scrMain removeGestureRecognizer:rotateGestureImg];
        [ImgOld  removeGestureRecognizer:tapGestureMask];
        
        CGPoint center = ImgOld.center;
        CGRect rectImage = ImgOld.bounds;
        
        CGRect newRectImage = [imgMyImage convertRect:rectImage fromView:scrMain];
        
        CGPoint newCenter = [imgMyImage convertPoint:center fromView:scrMain];
        
        [ImgOld removeFromSuperview];
        
        [imgMyImage addSubview:ImgOld];
        
        ImgOld.center = newCenter;
        ImgOld.bounds = newRectImage;
        
        NSString *Oldlayer_Name = [NSString stringWithFormat:@"layer %ld",(long)ImgOld.tag];
        for (CALayer *layer in [borderView.layer.sublayers copy]) {
            NSLog(@"%lu",[[ImgOld.layer.sublayers copy]count]);
            if ([[layer name]isEqualToString:Oldlayer_Name]) {
                [layer removeFromSuperlayer];
            }
        }
        [[ImgOld viewWithTag:Tag_MaskDetail+100] removeFromSuperview];
        [[ImgOld viewWithTag:Tag_MaskDetail+1000] removeFromSuperview];
        [[scrMain viewWithTag:Tag_MaskDetail + 10000] removeFromSuperview];
    }
    Tag_MaskDetail = 0;
    
}
//Face image
-(void)changeSkinColorValue:(float)value WithImage:(UIImage*)needToModified
{
    UIImageView *img_main = faces[0];
    UIImage *ImgTemp = arr_FaceAutoSwap[0];
    CGContextRef ctx;
    
    CGImageRef imageRef = needToModified.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //unsigned char *rawData = malloc(firstImageV.image.size.height * firstImageV.image.size.width * 10);
    
    CFMutableDataRef m_DataRef = CFDataCreateMutableCopy(0, 0,CGDataProviderCopyData(CGImageGetDataProvider(ImgTemp.CGImage)));
    UInt8 *rawData = (UInt8 *) CFDataGetMutableBytePtr(m_DataRef);
    int length = CFDataGetLength(m_DataRef);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * ImgTemp.size.width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context1 = CGBitmapContextCreate(rawData, ImgTemp.size.width, ImgTemp.size.height, bitsPerComponent, bytesPerRow, colorSpace,                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context1, CGRectMake(0, 0, ImgTemp.size.width, ImgTemp.size.height), imageRef);
    
    NSLog(@"%lu::%lu",(unsigned long)width,(unsigned long)height);
    
    
    // for(int ii = 0 ; ii < 250   ; ii+=4)
    //{
    
    //    for(int ii = 0 ; ii < length ; ii+=4)
    //    {
    //        //NSLog(@"Raw data %s",rawData);
    //
    //        int  R = rawData[ii];
    //        int G = rawData[ii+1];
    //        int B = rawData[ii+2];
    //
    //        //        NSLog(@"%d   %d   %d", R, G, B);
    //        //if( ( (R>60)&&(R<237) ) || ((G>10)&&(G<120))||((B>4) && (B<120)))
    //        //       if( ( (R>100)&&(R<186) ) || ((G>56)&&(G<130))||((B>30) && (B<120)))
    //        //        if( ( (R>188)&&(R<228) ) || ((G>123)&&(G<163))||((B>85) && (B<125)))
    //        // if( ( (R>95)&&(R<260) ) || ((G>40)&&(G<210))||((B>20) && (B<170)))
    //
    //        //new code......
    //
    //        if( ( (R>0)&&(R<260) ) || ((G>0)&&(G<210))||((B>0) && (B<170)))
    //
    //        {
    //            rawData[ii+1]=R;//13;
    //            rawData[ii+2]=G;//43;
    //            rawData[ii+3]=value;//63
    //        }
    //    }
    //
    for(int ii = 0 ; ii < length ; ii+=4)
    {
        
        int  R = rawData[ii];
        int G = rawData[ii+1];
        int B = rawData[ii+2];
        
        //        NSLog(@"%d   %d   %d", R, G, B);
        if( ( (R>60)&&(R<237) ) || ((G>10)&&(G<120))||((B>4) && (B<120)))
            //        if( ( (R>100)&&(R<186) ) || ((G>56)&&(G<130))||((B>30) && (B<120)))
            //        if( ( (R>188)&&(R<228) ) || ((G>123)&&(G<163))||((B>85) && (B<125)))
            //        if( ( (R>95)&&(R<220) ) || ((G>40)&&(G<210))||((B>20) && (B<170)))
        {
            
            
            rawData[ii+1]=R;//13;
            rawData[ii+2]=G;//43;
            rawData[ii+3]=value;//63
            //            NSLog(@"entered");
        }
    }
    
    ctx = CGBitmapContextCreate(rawData,
                                CGImageGetWidth( imageRef ),
                                CGImageGetHeight( imageRef ),
                                8,
                                CGImageGetBytesPerRow( imageRef ),
                                CGImageGetColorSpace( imageRef ),
                                kCGImageAlphaPremultipliedLast );
    
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
    //UIImageView *ty=[[UIImageView alloc]initWithFrame:CGRectMake(100, 200, 400, 400)];
    //ty.image=rawImage;
    //[self.view addSubview:ty];
    [img_main setImage:rawImage];
    CGContextRelease(context1);
    CGContextRelease(ctx);
    free(rawData);
}
-(void)colorImageBySliderValue:(float)value WithImage:(UIImage*)needToModified
{
    UIImageView *img_main = faces[0];
    UIImage *ImgTemp = arr_FaceAutoSwap[0];
    
    CGContextRef ctx;
    
    CGImageRef imageRef = needToModified.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(ImgTemp.size.height * ImgTemp.size.width * 10);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * ImgTemp.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context1 = CGBitmapContextCreate(rawData, ImgTemp.size.width, ImgTemp.size.height,
                                                  bitsPerComponent, bytesPerRow, colorSpace,
                                                  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context1, CGRectMake(0, 0, ImgTemp.size.width, ImgTemp.size.height), imageRef);
    
    NSLog(@"%lu::%lu",(unsigned long)width,(unsigned long)height);
    
    
    for(int ii = 0 ; ii < 768 * 1024 ; ii+=4)
    {
        
        int  R = rawData[ii];
        int G = rawData[ii+1];
        int B = rawData[ii+2];
        
        //        NSLog(@"%d   %d   %d", R, G, B);
        if( ( (R>60)&&(R<237) ) || ((G>10)&&(G<120))||((B>4) && (B<120)))
            //        if( ( (R>100)&&(R<186) ) || ((G>56)&&(G<130))||((B>30) && (B<120)))
            //        if( ( (R>188)&&(R<228) ) || ((G>123)&&(G<163))||((B>85) && (B<125)))
            //        if( ( (R>95)&&(R<220) ) || ((G>40)&&(G<210))||((B>20) && (B<170)))
        {
            
            
            rawData[ii+1]=R;//13;
            rawData[ii+2]=G;//43;
            rawData[ii+3]=value;//63
            //            NSLog(@"entered");
        }
    }
    
    
    ctx = CGBitmapContextCreate(rawData,
                                CGImageGetWidth( imageRef ),
                                CGImageGetHeight( imageRef ),
                                8,
                                CGImageGetBytesPerRow( imageRef ),
                                CGImageGetColorSpace( imageRef ),
                                kCGImageAlphaPremultipliedLast );
    
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
    //    UIImageView *ty=[[UIImageView alloc]initWithFrame:CGRectMake(100, 200, 400, 400)];
    img_main.image=rawImage;
    //    [self.view addSubview:ty];
    CGContextRelease(context1);
    CGContextRelease(ctx);
    free(rawData);
}
- (IBAction)handleTapMask:(UITapGestureRecognizer *)recognizer {
    
    UIImageView *img = (UIImageView *) [recognizer view];
    UIImage *sourceImage = img.image;
    img.image = [self flipImage:sourceImage];
    if ([arrMirroredface containsObject:[NSNumber numberWithInt:(int)img.tag]]){
        [arrMirroredface removeObject:[NSNumber numberWithInt:(int)img.tag]];
    }else{
        [arrMirroredface addObject:[NSNumber numberWithInt:(int)img.tag]];
    }
    //    for (int j = 0;  j <faces.count; j++) {
    //        UIImageView *ImgTemp = faces[j];
    //        if (ImgTemp.tag == Tag_MaskDetail) {
    //            ImgTemp.image = [self flipImage:sourceImage];
    //            [faces replaceObjectAtIndex:j withObject:ImgTemp];
    //            [arr_FaceAutoSwap replaceObjectAtIndex:j withObject:ImgTemp.image];
    //        }
    //    }
}
- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer {
    //        scrMain.zoomScale = 1.0;
    NSLog(@"%f",scrMain.zoomScale);
    
    [self RemoveOldMaskFrame];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:KeyIsUnlockedAll] != nil || [userDefault valueForKey:KeyIsUnlockedSkin] != nil){
        viewColorOptions.hidden = false;
    }else{
        
    }
    // Flip Image
    UIImageView *img = (UIImageView *) [recognizer view];
    UIImage *sourceImage = img.image;
    img.image = [self flipImage:sourceImage];
    
    //    for (int j = 0;  j <faces.count; j++) {
    //        UIImageView *ImgTemp1 = faces[j];
    //        if (ImgTemp1.tag == img.tag) {
    //            [arr_FaceAutoSwap replaceObjectAtIndex:j withObject:sourceImage];
    //            [faces replaceObjectAtIndex:j withObject:img];
    //        }
    //    }
    if ([arrMirroredface containsObject:[NSNumber numberWithInt:(int)img.tag]]){
        [arrMirroredface removeObject:[NSNumber numberWithInt:(int)img.tag]];
    }else{
        [arrMirroredface addObject:[NSNumber numberWithInt:(int)img.tag]];
    }
    
    
    //**********
    CGPoint center1 = img.center;
    CGPoint newCenter1 = [imgMyImage convertPoint:center1 toView:scrMain];
    CGRect rectImage = img.bounds;
    CGRect newRectImage = [imgMyImage convertRect:rectImage toView:scrMain];
    
    borderView = [[UIView alloc] initWithFrame:CGRectMake(newRectImage.origin.x - 20, newRectImage.origin.y - 20, newRectImage.size.width + 40, newRectImage.size.height+ 40)];
    //    borderView.backgroundColor = [UIColor greenColor];
    borderView.tag = img.tag + 10000;
    
    shapeLayer = [CAShapeLayer layer];
    CGSize frameSize = CGSizeMake(borderView.bounds.size.width - 20.0, borderView.bounds.size.height - 20.0) ;
    CGRect shapeRect = CGRectMake(10.0f, 10.0f, borderView.bounds.size.width-20.0, borderView.bounds.size.height-20.0);
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake( frameSize.width/2 + 10,frameSize.height/2 + 10)];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[UIColor whiteColor].CGColor];
    [shapeLayer setLineWidth:1.0f];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:5],nil]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:1.0];
    [shapeLayer setPath:path.CGPath];
    NSString *layer_Name = [NSString stringWithFormat:@"layer %ld",(long)img.tag];
    [shapeLayer setName:layer_Name];
    [borderView.layer addSublayer:shapeLayer];
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation
                     animationWithKeyPath:@"lineDashPhase"];
    
    [dashAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [dashAnimation setToValue:[NSNumber numberWithFloat:15.0f]];
    [dashAnimation setDuration:0.5f];
    [dashAnimation setRepeatCount:100000];
    [shapeLayer addAnimation:dashAnimation forKey:@"linePhase"];
    button_Cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button_Cancel.tag = img.tag + 100;
    [button_Cancel addTarget:self action:@selector(buttonClickedRemoveFace:) forControlEvents:UIControlEventTouchUpInside];
    [button_Cancel setTitle:@"X" forState:UIControlStateNormal];
    [button_Cancel setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:100.0/255.0 blue:27.0/255.0 alpha:1.0]];
    [button_Cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button_Cancel.titleLabel.font = [UIFont systemFontOfSize:10.0];
    button_Cancel.frame = CGRectMake(00.0, 00.0, 20.0, 20.0);
    button_Cancel.layer.cornerRadius = 10.0; // this value vary as per your desire
    button_Cancel.clipsToBounds = YES;
    [borderView addSubview:button_Cancel];
    
    buttonCopy = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonCopy.tag = img.tag + 1000;
    [buttonCopy addTarget:self action:@selector(buttonClickedCopyFace:) forControlEvents:UIControlEventTouchUpInside];
    [buttonCopy setTitle:@"C" forState:UIControlStateNormal];
    [buttonCopy setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:100.0/255.0 blue:27.0/255.0 alpha:1.0]];
    [buttonCopy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonCopy.frame = CGRectMake(borderView.bounds.size.width-20 , 0.0, 20.0, 20.0);
    buttonCopy.layer.cornerRadius = 10.0; // this value vary as per your desire
    buttonCopy.clipsToBounds = YES;
    buttonCopy.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [borderView addSubview:buttonCopy];
    // Remove from Main Image
    [img removeFromSuperview];
    
    // Add Selected Image to scrollview
    borderView.center = newCenter1;
    //    borderView.userInteractionEnabled = false;
    [self AddGestureInScrollview:img.tag];
    
    tapGestureMask = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapMask:)];
    [img addGestureRecognizer:tapGestureMask];
    img.userInteractionEnabled = true;
    
    
    [scrMain addSubview:borderView];
    [scrMain addSubview:img];
    
    img.bounds = newRectImage;
    img.center = newCenter1;
    
    //******
    
    scrMain.minimumZoomScale = 0.1f;
    scrMain.maximumZoomScale = 10.0f;
    Tag_MaskDetail = img.tag;
    
    
    
    //Set Color tune value
    for (int j = 0;  j <faces.count; j++) {
        UIImageView *ImgTemp = faces[j];
        if (ImgTemp.tag == img.tag) {
            [sliderColored setValue:[arr_sliderValue_Color[j]floatValue] animated:YES];
            [sliderBW setValue:[arr_sliderValue_Brightness[j]floatValue]animated:YES];
            break;
        }
    }
    
    return;
}

# pragma mark - Add Gesture in face
-(void)AddGestureInScrollview :(NSInteger)tag{
    
    pinchGestureImg = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [scrMain addGestureRecognizer:pinchGestureImg];
    
    rotateGestureImg = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    [scrMain addGestureRecognizer:rotateGestureImg];
    
    pinchGestureImg.delegate = self;
    rotateGestureImg .delegate = self;
    
    panGesture_Face = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [scrMain addGestureRecognizer:panGesture_Face];
    //    [self gestureRecognizer:pinchGestureImg shouldRecognizeSimultaneouslyWithGestureRecognizer:rotateGestureImg];
    
    
}
- (BOOL)gestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIRotationGestureRecognizer *)otherGestureRecognizer{
    if (gestureRecognizer == pinchGestureImg && otherGestureRecognizer == rotateGestureImg) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - Zooming Selected face in pinch Gesture
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    for (int j = 0;  j <faces.count; j++) {
        UIImageView *ImgTemp = faces[j];
        if (ImgTemp.tag == Tag_MaskDetail) {
            ImgTemp.transform = CGAffineTransformScale(ImgTemp.transform, recognizer.scale, recognizer.scale);
            recognizer.scale = 1;
            borderView.frame = CGRectMake(ImgTemp.frame.origin.x - 20, ImgTemp.frame.origin.y - 20, ImgTemp.frame.size.width + 40, ImgTemp.frame.size.height+ 40);
            CGSize frameSize =CGSizeMake(borderView.bounds.size.width - 20.0, borderView.bounds.size.height - 20.0);
            CGRect shapeRect = CGRectMake(10.0f, 10.0f, borderView.bounds.size.width-20.0, borderView.bounds.size.height-20.0);
            [shapeLayer setBounds:shapeRect];
            [shapeLayer setPosition:CGPointMake( frameSize.width/2 + 10,frameSize.height/2 + 10)];
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:1.0];
            [shapeLayer setPath:path.CGPath];
            buttonCopy.frame = CGRectMake(borderView.bounds.size.width - 20.0, 0.0, 20.0, 20.0);
        }
    }
}

#pragma mark - Rotate Selected Mask Gesture
- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    for (int j = 0;  j <faces.count; j++) {
        UIImageView *ImgTemp = faces[j];
        if (ImgTemp.tag == Tag_MaskDetail) {
            ImgTemp.transform = CGAffineTransformRotate(ImgTemp.transform, recognizer.rotation);
            recognizer.rotation = 0;
        }
    }
}
#pragma mark - face Pan detect to move face
-(void)panDetected:(UIPanGestureRecognizer *)recognizer{
    //Maulik Change Replace Scrmain to imgMyImage //undo
    for (int j = 0;  j <faces.count; j++) {
        UIImageView *ImgTemp = faces[j];
        if (ImgTemp.tag == Tag_MaskDetail) {
            float max = MAX(height_imgview.constant, scrMain.frame.size.height);
            CGPoint translatedPoint = [recognizer translationInView:scrMain];
            if ([recognizer state] == UIGestureRecognizerStateBegan) {
                firstX = [ImgTemp center].x;
                firstY = [ImgTemp center].y;
            }
            translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
            if (translatedPoint.y < 10.0f){
                translatedPoint.y = 10.0f;
            }else if (translatedPoint.y > (max*scrMain.zoomScale - 10.0f)){
                translatedPoint.y = (max*scrMain.zoomScale) - 10.0f;
            }
            [ImgTemp setCenter:translatedPoint];
            [borderView setCenter:translatedPoint];
        }
    }
    
}
/* Old Code For Pan Detect in face in auto swap face.
 float max = MAX(height_imgview.constant, scrMain.frame.size.height);
 
 }else if (translatedPoint.y > (max*scrMain.zoomScale - 10.0f)){
 NSLog(@"trnasltae %f",translatedPoint.y);
 NSLog(@"scr %f",scrMain.frame.size.height);
 
 //                translatedPoint.y = (scrMain.frame.size.height) - 10.0f;
 
 translatedPoint.y = (max*scrMain.zoomScale) - 10.0f;
 NSLog(@"Not change");
 }

 
 
 -(void)panDetected:(UIPanGestureRecognizer *)recognizer{
 //Maulik Change Replace Scrmain to imgMyImage //undo
 CGPoint translatedPoint = [recognizer translationInView:scrMain];
 if ([recognizer state] == UIGestureRecognizerStateBegan) {
 firstX = [[recognizer view] center].x;
 firstY = [[recognizer view] center].y;
 }
 
 translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
 
 if (translatedPoint.y < 10.0f){
 translatedPoint.y = 10.0f;
 }else if (translatedPoint.y > (scrMain.frame.size.height - 10.0f)){
 translatedPoint.y = (scrMain.frame.size.height) - 10.0f;
 }
 
 //    if (CGRectContainsPoint(imgMyImage.frame, translatedPoint) == true){
 [[recognizer view] setCenter:translatedPoint];
 [borderView setCenter:translatedPoint];
 //    }
 
 }*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClickedRemoveFace:(id)sender {
    NSInteger tag= ((UIButton *)sender).tag;
    NSLog(@"tag %ld",(long)tag);
    DeleteFaceTag = tag;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Face?" message:@"Are you sure you want to delete this face?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alert.tag = 101;
    [alert show];
}
- (IBAction)buttonClickedCopyFace:(id)sender {
    NSInteger tag= ((UIButton *)sender).tag;
    NSLog(@"tag %ld",(long)tag);
    DeleteFaceTag = tag;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copy Face" message:@"Are you sure you want to copy this face?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Copy", nil];
    alert.tag = 1011;
    [alert show];
}
- (IBAction)SlideChangeNew:(UISlider *)sender {
    NSLog(@"color change : %f", sender.value);

}

#pragma mark - Color Tune Method

- (IBAction)colorValueChaged:(UISlider *)sender {
//    NSLog(@"senderv%f",sender.value);
    
    int value = sender.value *100 / 6.25;
    float value1 = value *6.25;
    float value2 = sender.value * 100 -value1;
    float red = 0.0,green = 0.0;
    float blue1 = 0.0;
    
    //Comment : Create Fianl RGB Color Base on the slider value
    if (sender.value*100 > 50.0) {
        red = [arr_Red[value]floatValue] - value2;
        green = [arr_Green[value]floatValue] - value2;
        blue1 = [arr_Blue[value]floatValue] - value2;
    }else{
        red = [arr_Red[value]floatValue] + value2;
        green = [arr_Green[value]floatValue] + value2;
        blue1 = [arr_Blue[value]floatValue] + value2;
    }
    //Comment : Apply Color To Selected Mask
    if (typeView == Auto){
        UIImageView *ImgNew;
        UIImage *ImgOld;
        for (int j = 0;  j <faces.count; j++) {
            UIImageView *ImgTemp= faces[j];
            if (ImgTemp.tag == Tag_MaskDetail) {
                ImgNew = ImgTemp;
                ImgOld = arr_FaceAutoSwap[j];
                
                if ([arr_sliderValue_Brightness[j]floatValue] > 0.60 || [arr_sliderValue_Brightness[j]floatValue] < 0.40) {
                    ImgOld = [ImgOld brightness:(1+[arr_sliderValue_Brightness[j]floatValue]-0.5)];
                }else {
                    ImgOld = arr_FaceAutoSwap[j];
                }
                if ([arrMirroredface containsObject:[NSNumber numberWithInt:(int)ImgTemp.tag]]){
                    UIImage *sourceImage = ImgOld;
                    ImgOld = [self flipImage:sourceImage];
                    
                }else{
                    ImgOld = arr_FaceAutoSwap[j];
                }
                [arr_sliderValue_Color replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%f",sender.value]];
                break;
            }
        }
        CGRect rect = CGRectMake(0, 0, ImgOld.size.width, ImgOld.size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, rect, ImgOld.CGImage);
        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue1/255.0 alpha:0.4] CGColor]);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                    scale:1.0 orientation: UIImageOrientationDownMirrored];
        
        if (sender.value < 0.40 || sender.value > 0.60) {
            UIImage *imgMain = [self imageByCombiningImage:ImgOld withImage:flippedImage];
            ImgNew.image = imgMain;
        }else {
            ImgNew.image = ImgOld;
        }
    }else {
        NSInteger i;
        UIImage *ImgOld;
        MaskView *mask;
        if ([ManualSwapX  isEqual: @""]) {
            mask = arrManualSwappedFaces[0];
            i = 0;
        }else{
            mask = arrManualSwappedFaces[0];
            if ([ManualSwapX  isEqual: @"Mask 1"]) {
                i = 0;
            }else {
                mask = arrManualSwappedFaces[1];
                i = 1;
            }
        }
        
        if ([arr_SliderValue_Brightness_Manual[i]floatValue] > 0.60 || [arr_SliderValue_Brightness_Manual[i]floatValue] < 0.40) {
            ImgOld = [arr_FaceManualSwap[i] brightness:(1+[arr_SliderValue_Brightness_Manual[i]floatValue]-0.5)];
        }else {
            ImgOld = arr_FaceManualSwap[i];
        }
        
        [arr_sliderValue_Color_Manual replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%f",sender.value]];
        
        //return the color-burned image
        CGRect rect = CGRectMake(0, 0, ImgOld.size.width, ImgOld.size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, rect, ImgOld.CGImage);
        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue1/255.0 alpha:0.4] CGColor]);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                    scale:1.0 orientation: UIImageOrientationDownMirrored];
        if (sender.value < 0.40 || sender.value > 0.60) {
            UIImage *imgMain = [self imageByCombiningImage:ImgOld withImage:flippedImage];
            mask.faceView.image = imgMain;
        }else {
            mask.faceView.image = ImgOld;
            
        }
    }
}
- (IBAction)bwValueChanged:(UISlider *)sender {
//    [sliderBW setContinuous: NO];
    
    //Comment : Code For Brightness Set in face.
    if (typeView == ManualSwap) {
        NSInteger i;
        UIImage *ImgOld;
        MaskView *mask;
        UIImage *imgMain;
        if ([ManualSwapX  isEqual: @""]) {
            mask = arrManualSwappedFaces[0];
            i = 0;
        }else{
            mask = arrManualSwappedFaces[0];
            if ([ManualSwapX  isEqual: @"Mask 1"]) {
                i = 0;
            }else {
                mask = arrManualSwappedFaces[1];
                i = 1;
            }
        }
        ImgOld = arr_FaceManualSwap[i];
        if ([arr_sliderValue_Color_Manual[i]floatValue] > 0.6 || [arr_sliderValue_Color_Manual[i]floatValue] < 0.4){
            int value = [arr_sliderValue_Color_Manual[i] floatValue] *100 / 6.25;
            float value1 = value *6.25;
            float value2 = [arr_sliderValue_Color_Manual[i] floatValue] * 100 -value1;
            float red = 0.0,green = 0.0;
            float blue1 = 0.0;
            
            //Comment : Create Fianl RGB Color Base on the slider value
            if ([arr_sliderValue_Color_Manual[i] floatValue]*100 > 50.0) {
                red = [arr_Red[value]floatValue] - value2;
                green = [arr_Green[value]floatValue] - value2;
                blue1 = [arr_Blue[value]floatValue] - value2;
            }else{
                red = [arr_Red[value]floatValue] + value2;
                green = [arr_Green[value]floatValue] + value2;
                blue1 = [arr_Blue[value]floatValue] + value2;
            }
            
            
            //return the color-burned image
            CGRect rect = CGRectMake(0, 0, ImgOld.size.width, ImgOld.size.height);
            UIGraphicsBeginImageContext(rect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextClipToMask(context, rect, ImgOld.CGImage);
            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue1/255.0 alpha:0.4] CGColor]);
            CGContextFillRect(context, rect);
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                        scale:1.0 orientation: UIImageOrientationDownMirrored];
            
            imgMain = [self imageByCombiningImage:ImgOld withImage:flippedImage];
            
        }else{
            imgMain = ImgOld;
        }
        mask.faceView.image = [imgMain brightness:(1+sender.value-0.5)];
        
        [arr_SliderValue_Brightness_Manual replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%f",sender.value]];
    }else{
        UIImage *ImgOld;
        UIImageView *ImgNew;
        UIImage *imgMain;
        for (int j = 0;  j <faces.count; j++) {
            UIImageView *ImgTemp = faces[j];
            if (ImgTemp.tag == Tag_MaskDetail) {
                ImgNew = ImgTemp;
                ImgOld = arr_FaceAutoSwap[j];
                
                if ([arrMirroredface containsObject:[NSNumber numberWithInt:(int)ImgTemp.tag]]){
                    UIImage *sourceImage = ImgOld;
                    ImgOld = [self flipImage:sourceImage];
                }else{
                    ImgOld = ImgOld;
                }
                
                if ([arr_sliderValue_Color[j]floatValue] > 0.60 || [arr_sliderValue_Color[j]floatValue] < 0.40) {
                    int value = [arr_sliderValue_Color[j] floatValue] *100 / 6.25;
                    float value1 = value *6.25;
                    float value2 = [arr_sliderValue_Color[j] floatValue] * 100 -value1;
                    float red = 0.0,green = 0.0;
                    float blue1 = 0.0;
                    
                    //Comment : Create Fianl RGB Color Base on the slider value
                    if ([arr_sliderValue_Color[j] floatValue]*100 > 50.0) {
                        red = [arr_Red[value]floatValue] - value2;
                        green = [arr_Green[value]floatValue] - value2;
                        blue1 = [arr_Blue[value]floatValue] - value2;
                    }else{
                        red = [arr_Red[value]floatValue] + value2;
                        green = [arr_Green[value]floatValue] + value2;
                        blue1 = [arr_Blue[value]floatValue] + value2;
                    }
                    CGRect rect = CGRectMake(0, 0, ImgOld.size.width, ImgOld.size.height);
                    UIGraphicsBeginImageContext(rect.size);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, rect, ImgOld.CGImage);
                    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue1/255.0 alpha:0.4] CGColor]);
                    CGContextFillRect(context, rect);
                    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
                    imgMain = [self imageByCombiningImage:ImgOld withImage:flippedImage];
                    
                }else{
                    
                    imgMain = ImgOld;
                    
                    
                }
                
                [arr_sliderValue_Brightness replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%f",sender.value]];
                ImgNew.image = [imgMain brightness:(1+sender.value-0.5)];
                break;
            }
        }
    }
}
-(UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [color CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newImageSize);
    }
    [firstImage drawAtPoint:CGPointMake(roundf((newImageSize.width-firstImage.size.width)/2),
                                        roundf((newImageSize.height-firstImage.size.height)/2))];
    [secondImage drawAtPoint:CGPointMake(roundf((newImageSize.width-secondImage.size.width)/2),
                                         roundf((newImageSize.height-secondImage.size.height)/2))];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueShare"]){
        ShareVC *share = (ShareVC *)segue.destinationViewController;
        share.myImage = sharableImage;
    }
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
    self.interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
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
    if (alertView.tag == 101) {
        if(buttonIndex == 0){
        }else if(buttonIndex == 1){
            //Comment : Code For Delete Mask
            DeleteFaceTag = DeleteFaceTag-100;
            [[scrMain viewWithTag:DeleteFaceTag] removeFromSuperview];
            for (int i = 0; i <faces.count ; i++) {
                UIImageView *faceView = faces[i];
                if (faceView.tag == DeleteFaceTag) {
                    [faces removeObject:faceView];
                    [arr_FaceWidth removeObjectAtIndex:i];
                    [arr_FaceHeight removeObjectAtIndex:i];
                    [arr_FaceX removeObjectAtIndex:i];
                    [arr_FaceY removeObjectAtIndex:i];
                    [arr_sliderValue_Brightness removeObjectAtIndex:i];
                    [arr_sliderValue_Color removeObjectAtIndex:i];
                    [arr_FaceAutoSwap removeObjectAtIndex:i];
                    [[scrMain viewWithTag:Tag_MaskDetail + 10000] removeFromSuperview];
                    scrMain.minimumZoomScale = 1.0f;
                    scrMain.maximumZoomScale = 2.5f;
                    
                    [scrMain removeGestureRecognizer:panGesture_Face];
                    [scrMain removeGestureRecognizer:pinchGestureImg];
                    [scrMain removeGestureRecognizer:rotateGestureImg];
                    Tag_MaskDetail = 0;
                    
                    break;
                }else{
                }
            }
            Tag_MaskDetail = 0;
        }else{
        }
    }
    else if (alertView.tag == 1011) {
        if(buttonIndex == 0){
        }else if(buttonIndex == 1){
            [self RemoveOldMaskFrame];
            //Comment : Code For Copy Mask
            DeleteFaceTag = DeleteFaceTag-1000;
            for (int i = 0; i <faces.count ; i++) {
                UIImageView *faceView = faces[i];
                UIImageView *lastFaceView = faces [faces.count -1];
                NSInteger NewImageTag = lastFaceView.tag + 5;
                if (faceView.tag == DeleteFaceTag) {
                    int value = [arr_sliderValue_Color[i] floatValue] *100 / 6.25;
                    float value1 = value *6.25;
                    float value2 = [arr_sliderValue_Color[i] floatValue]  * 100 -value1;
                    float red = 0.0,green = 0.0;
                    float blue1 = 0.0;
                    
                    //Comment : Create Fianl RGB Color Base on the slider value
                    if ([arr_sliderValue_Color[i] floatValue] *100 > 50.0) {
                        red = [arr_Red[value]floatValue] - value2;
                        green = [arr_Green[value]floatValue] - value2;
                        blue1 = [arr_Blue[value]floatValue] - value2;
                    }else{
                        red = [arr_Red[value]floatValue] + value2;
                        green = [arr_Green[value]floatValue] + value2;
                        blue1 = [arr_Blue[value]floatValue] + value2;
                    }
                    UIImageView *newFace =[[UIImageView alloc] initWithFrame:CGRectMake(faceView.frame.origin.x+30, faceView.frame.origin.y +30, faceView.frame.size.width, faceView.frame.size.height)];
                    UIImage *img = arr_FaceAutoSwap[i];
                    newFace.image = img;
                    newFace.tag = NewImageTag;
                    [newFace setUserInteractionEnabled:true];
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                    [newFace addGestureRecognizer:tapGesture];
                    [arr_FaceWidth addObject:[NSString stringWithFormat:@"%f",newFace.bounds.size.width]];
                    [arr_FaceHeight addObject:[NSString stringWithFormat:@"%f",newFace.bounds.size.height]];
                    [arr_FaceY addObject:[NSString stringWithFormat:@"%f",newFace.frame.origin.y + 30]];
                    [arr_FaceX addObject:[NSString stringWithFormat:@"%f",newFace.frame.origin.x + 30]];
                    [arr_sliderValue_Brightness addObject:@"0.5"];
                    [arr_sliderValue_Color addObject:@"0.5"];
                    
                    [arr_FaceAutoSwap addObject:newFace.image];
                    [faces addObject:newFace];
                    [imgMyImage addSubview:newFace];
                    break;
                }else{
                }
            }
            Tag_MaskDetail = 0;
        }else{
        }
    } else{
    }
}
#pragma mark GADInterstitialDelegate implementation

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidDismissScreen");
}
-(void)ColorTunePurchase{
    [self RemoveInAppPurchase];
//    RemoveAdsVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RemoveAdsVC"];
//    [[self navigationController] pushViewController:VC animated:YES];
}
@end