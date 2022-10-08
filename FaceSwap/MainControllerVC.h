//
//  MainControllerVC.h
//  FaceSwap
//
//  Created by MAC on 09/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaskView.h"
#import "SuperViewController.h"
#import "Imaging.h"
#import "JMMarkSlider.h"
enum TypeOfView{
    Main,
    ManualSwap,
    ColorTune
};
enum SwapType{
    Auto,
    Manual
};

@interface MainControllerVC : SuperViewController<MaskViewDelegate>{
    enum TypeOfView typeView;
    enum SwapType swapType;
    BOOL isManualFaceSwaped;
    
    __weak IBOutlet NSLayoutConstraint *height_imgview;
    __weak IBOutlet NSLayoutConstraint *width_imgview;
    __weak IBOutlet NSLayoutConstraint *top_imgview;
    __weak IBOutlet NSLayoutConstraint *bottom_imgview;
        
    __weak IBOutlet UIView *viewColorOptions;
    __weak IBOutlet UIView *viewManualSwap;
    __weak IBOutlet UIView *viewMainOptions;
    __weak IBOutlet UIImageView *imgMyImage;
    __weak IBOutlet UIScrollView *scrMain;
    
    //MASK BUTTONS
    __weak IBOutlet UIButton *btnMask1;
    __weak IBOutlet UIButton *btnMask2;
    __weak IBOutlet UIButton *btnMask3;
    
    //COLOR TUNE
    
    __weak IBOutlet JMMarkSlider *sliderColored;
//    __weak IBOutlet UISlider *sliderColored;
//    __weak IBOutlet UISlider *sliderBW;
    __weak IBOutlet JMMarkSlider *sliderBW;
    
    __weak IBOutlet UIButton *btnUnlockPro;
    __weak IBOutlet UIActivityIndicatorView *activityPurchase;
    // SETTING
    
    __weak IBOutlet UIView *viewSetting;
    
    __weak IBOutlet UIImageView *imgTutorialAutoSwap;
    
    __weak IBOutlet UIImageView *imgTutorialManualSwap;
    IBInspectable  UIColor *borderColor;
    
    __weak IBOutlet UIScrollView *scrTutorial;
    __weak IBOutlet UIPageControl *pageControlTutorial;
    
    __weak IBOutlet UIButton *btn_ObjAutoSwapColorTuneView;
    __weak IBOutlet UIButton *btn_ObjAutoSwapMainView;
    __weak IBOutlet UIButton *btn_ObjManualSwapMainView;
    __weak IBOutlet UIButton *btn_ObjSwipeInManualView;
    
    IBOutlet UITapGestureRecognizer *TapGestureManaulTutorial;
    
}
-(void)UpdateImage;
@property UIImage *myImage;
@end
