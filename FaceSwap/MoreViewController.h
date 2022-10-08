//
//  MoreViewController.h
//  FaceSwap
//
//  Created by MAC on 18/02/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaskView.h"
#import "SPUserResizableView.h"
#import "SBPageFlowView.h"

@interface MoreViewController : UIViewController{
    enum ResizeDirection _resizeDirection;
    IBOutlet UIPanGestureRecognizer *panGesture;
    __weak IBOutlet UIPageControl *pageControl;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgMask;

@end
