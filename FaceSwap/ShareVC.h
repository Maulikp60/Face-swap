//
//  ShareVC.h
//  FaceSwap
//
//  Created by MAC on 09/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface ShareVC : SuperViewController<UIDocumentInteractionControllerDelegate>{
    __weak IBOutlet UIImageView *imgMyImage;
    
    __weak IBOutlet UILabel *lbl_Bottom;
    __weak IBOutlet UIButton *btnObj_Gallery;
    __weak IBOutlet UIButton *btnObj_Instagram;
    __weak IBOutlet UIButton *btnObj_Facebook;
    __weak IBOutlet UIButton *btnObj_RateUs;
    __weak IBOutlet UIButton *btnObj_Twitter;
    __weak IBOutlet UIButton *btnObj_More;
    __weak IBOutlet UIButton *btnObj_MoreApps;
    __weak IBOutlet UIButton *btnObj_Email;
}

@property UIImage *myImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightconstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl_Height;

@end
