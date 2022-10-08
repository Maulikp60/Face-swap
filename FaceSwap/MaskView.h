//
//  MaskView.h
//  FaceSwap
//
//  Created by MAC on 22/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ResizeDirection{
    HorizontalRight,
    HorizontalLeft,
    VerticalUp,
    VerticalDown,
    Both,
    Rotate,
    None
};

@class MaskView;

@protocol MaskViewDelegate <NSObject>
-(void)maskResizingStart:(MaskView *)maskView;
-(void)maskResizingInProgress:(MaskView *)maskView;
-(void)maskResizingStop:(MaskView *)maskView;
-(void)maskWillRemove:(MaskView *)maskView;
-(void)maskRotationStart:(MaskView *)maskView;
-(void)maskRotationInProgress:(MaskView *)maskView;
-(void)maskRotationStop:(MaskView *)maskView;
@end

@interface MaskView : UIView{
    enum ResizeDirection _resizeDirection;
    IBOutlet UIPanGestureRecognizer *panGesture;
}
@property UIImageView *faceView;
@property UIImage *faceImage, *maskImage;
@property NSString *Name;

@property BOOL hasFaceAngle;
@property float rotateAngle;
@property UIView *mainView;
@property (weak) NSObject<MaskViewDelegate> *delegate;
@property enum ResizeDirection _resizeDirectionForUse;

-(id)initWithFrame:(CGRect)frame withMaskImage:(UIImage *)maskImage;
-(void)hideMaskControls;
-(void)showMaskControls;
-(void)resetControl;
-(void)showFlip;
-(void)hideFlip;
-(void)fixClicked;
@end
