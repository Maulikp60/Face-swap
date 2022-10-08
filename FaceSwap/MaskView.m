//
//  MaskView.m
//  FaceSwap
//
//  Created by MAC on 22/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "MaskView.h"

@implementation MaskView{
    CGFloat firstX;
    CGFloat firstY;
    CGPoint pointBegin, pointResizeStart;
    
    CGPoint pointStartForRotation,pointStopForRotation;
    BOOL shouldResize;
    
    UIView *borderView;
    UIImageView *imgRightController;
    UIImageView *imgLeftController;
    UIImageView *imgTopController;
    UIImageView *imgBottomController;
    UIImageView *imgRotationController;
    UIImageView *imgCloseController;
    UIImageView *imgFlipController;
    UIImageView *imgFixController;
    
    UIButton *btnFixController;
    UIButton *btnFlipController;
    UIButton *btnCloseController;
    
    float width;
    float height;
    float offset;
    CGFloat lastRadius;
    BOOL isFixed;
    float deltaAngle;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(id)initWithFrame:(CGRect)frame withMaskImage:(UIImage *)maskImage{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp:frame];
        _faceView.image = maskImage;
        return self;
    }
    return nil;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setUp:frame];
        return self;
    }
    return nil;
}
-(void)setUp:(CGRect)frame{
    
    width = 40.0f;
    height = 40.0f;
    offset = 3.0f;
    
    borderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, self.frame.size.width-20.0f, self.frame.size.height-20.0f)];
    borderView.backgroundColor = [UIColor clearColor];
    borderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    borderView.layer.borderWidth = 1.0f;
    [self addSubview:borderView];
    
    //self.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.4];
    _faceView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, frame.size.width - 40.0, frame.size.height - 40.0f)];
    //    _faceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    _faceView.contentMode = UIViewContentModeScaleToFill;
    _faceView.image = [UIImage imageNamed:@"Manual_Mask"];
    _faceView.tintColor = [UIColor cyanColor];
    _faceView.alpha = 1.0;
    [self addSubview:_faceView];
    
    // Add control on imageview
    // Right
    CGRect rectRight = CGRectMake(self.frame.size.width - width, self.frame.size.height/2 - height/2, width, height);
    imgRightController = [[UIImageView alloc] initWithFrame:rectRight];
    imgRightController.image = [UIImage imageNamed:@"Arrow_Horizontal"];
    imgRightController.tintColor = [UIColor cyanColor];
    [self addSubview:imgRightController];
    
    // Left
    CGRect rectLeft = CGRectMake(0.0f, self.frame.size.height/2 - height/2, width, height);
    imgLeftController = [[UIImageView alloc] initWithFrame:rectLeft];
    imgLeftController.image = [UIImage imageNamed:@"Arrow_Horizontal"];
    imgLeftController.tintColor = [UIColor cyanColor];
    [self addSubview:imgLeftController];
    
    // Top
    CGRect rectTop = CGRectMake(self.frame.size.width/2.0 - width/2, 0.0, width, height);
    imgTopController = [[UIImageView alloc] initWithFrame:rectTop];
    imgTopController.image = [UIImage imageNamed:@"Arrow_Vertical"];
    imgTopController.tintColor = [UIColor cyanColor];
    [self addSubview:imgTopController];
    
    // Bottom
    CGRect rectBottom = CGRectMake(self.frame.size.width/2.0 - width/2, self.frame.size.height - height, width, height);
    imgBottomController = [[UIImageView alloc] initWithFrame:rectBottom];
    imgBottomController.image = [UIImage imageNamed:@"Arrow_Vertical"];
    imgBottomController.tintColor = [UIColor cyanColor];
    [self addSubview:imgBottomController];
    
    // Rotate
    CGRect rectRotate = CGRectMake(self.frame.size.width - width, self.frame.size.height - height, width, height);
    imgRotationController = [[UIImageView alloc] initWithFrame:rectRotate];
    imgRotationController.image = [UIImage imageNamed:@"Rotate-1"];
    imgRotationController.tintColor = [UIColor cyanColor];
    [self addSubview:imgRotationController];
    
    // Close
    CGRect rectClose = CGRectMake(0.0, 0.0, width, height);
    imgCloseController = [[UIImageView alloc] initWithFrame:rectClose];
    imgCloseController.image = [UIImage imageNamed:@"Close-1"];
    imgCloseController.tintColor = [UIColor cyanColor];
    //    [self addSubview:imgCloseController];
    
    btnCloseController = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloseController.frame = rectClose;
    UIImage *closeImage = [UIImage imageNamed:@"Close-1"];
    [btnCloseController setBackgroundImage:closeImage forState:UIControlStateNormal];
    [btnCloseController setBackgroundImage:closeImage forState:UIControlStateHighlighted];
    
    [btnCloseController addTarget:self action:@selector(closeMaskClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnCloseController];
    
    // Flip
    CGRect rectFlip = CGRectMake(0.0,self.frame.size.height - height , width, height);
    imgFlipController = [[UIImageView alloc] initWithFrame:rectFlip];
    imgFlipController.image = [UIImage imageNamed:@"turnOver"];
    imgFlipController.tintColor = [UIColor cyanColor];
    //    [self addSubview:imgFlipController];
    
    btnFlipController = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFlipController.frame = rectFlip;
    UIImage *flipImage = [UIImage imageNamed:@"turnOver"];
    [btnFlipController setBackgroundImage:flipImage forState:UIControlStateNormal];
    [btnFlipController setBackgroundImage:flipImage forState:UIControlStateHighlighted];
    [btnFlipController addTarget:self action:@selector(flipMaskClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnFlipController];
    
    
    CGRect rectFix = CGRectMake(self.frame.size.width - width,0.0f , width, height);
    imgFixController = [[UIImageView alloc] initWithFrame:rectFix];
    imgFixController.image = [UIImage imageNamed:@"confirm"];
    imgFixController.tintColor = [UIColor cyanColor];
    //    [self addSubview:imgFixController];
    
    btnFixController = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFixController.frame = rectFix;
    UIImage *fixImage = [UIImage imageNamed:@"confirm"];
    [btnFixController setBackgroundImage:fixImage forState:UIControlStateNormal];
    [btnFixController setBackgroundImage:fixImage forState:UIControlStateHighlighted];
    [btnFixController addTarget:self action:@selector(fixMaskClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnFixController];
    
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGesture];
    
    UIPanGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [imgRotationController addGestureRecognizer:panResizeGesture];
    imgRotationController.userInteractionEnabled = true;
    //    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //    self.layer.borderWidth = 1.0f;
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
}
-(void)resetControl{
    borderView.frame = CGRectMake(10.0, 10.0, self.frame.size.width-20.0f, self.frame.size.height-20.0f);
    
    _faceView.frame = CGRectMake(20, 20, self.frame.size.width - 40.0, self.frame.size.height - 40.0f);//CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    // Right
    CGRect rectRight = CGRectMake(self.frame.size.width - width, self.frame.size.height/2 - height/2, width, height);
    imgRightController.frame = rectRight;
    
    // Left
    CGRect rectLeft = CGRectMake(0.0f, self.frame.size.height/2 - height/2, width, height);
    imgLeftController.frame = rectLeft;
    
    // Top
    CGRect rectTop = CGRectMake(self.frame.size.width/2.0 - width/2, 0.0, width, height);
    imgTopController.frame = rectTop;
    
    // Bottom
    CGRect rectBottom = CGRectMake(self.frame.size.width/2.0 - width/2, self.frame.size.height - height, width, height);
    imgBottomController.frame = rectBottom;
    
    // Rotate
    CGRect rectRotate = CGRectMake(self.frame.size.width - width, self.frame.size.height - height, width, height);
    imgRotationController.frame = rectRotate;
    
    // Close
    CGRect rectClose = CGRectMake(0.0, 0.0, width, height);
    btnCloseController.frame = rectClose;
    
    // Flip
    CGRect rectFlip = CGRectMake(0.0,self.frame.size.height - height , width, height);
    btnFlipController.frame = rectFlip;
    //    imgFlipController.bounds = CGRectMake(-10.0, -10.0, imgFlipController.bounds.size.width + 20.f, imgFlipController.bounds.size.height + 20.f);
    
    // Fix
    CGRect rectFix = CGRectMake(self.frame.size.width - width,0.0f , width, height);
    btnFixController.frame = rectFix;
}
-(void)resetControlOnBounds{
    borderView.frame = CGRectMake(10.0, 10.0, self.bounds.size.width-20.0f, self.bounds.size.height-20.0f);
    
    _faceView.frame = CGRectMake(20, 20, self.bounds.size.width - 40.0, self.bounds.size.height - 40.0f);//CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    // Right
    CGRect rectRight = CGRectMake(self.bounds.size.width - width, self.bounds.size.height/2 - height/2, width, height);
    imgRightController.frame = rectRight;
    
    // Left
    CGRect rectLeft = CGRectMake(0.0f, self.bounds.size.height/2 - height/2, width, height);
    imgLeftController.frame = rectLeft;
    
    // Top
    CGRect rectTop = CGRectMake(self.bounds.size.width/2.0 - width/2, 0.0, width, height);
    imgTopController.frame = rectTop;
    
    // Bottom
    CGRect rectBottom = CGRectMake(self.bounds.size.width/2.0 - width/2, self.bounds.size.height - height, width, height);
    imgBottomController.frame = rectBottom;
    
    // Rotate
    CGRect rectRotate = CGRectMake(self.bounds.size.width - width, self.bounds.size.height - height, width, height);
    imgRotationController.frame = rectRotate;
    
    // Close
    CGRect rectClose = CGRectMake(0.0, 0.0, width, height);
    btnCloseController.frame = rectClose;
    
    // Flip
    CGRect rectFlip = CGRectMake(0.0,self.bounds.size.height - height , width, height);
    btnFlipController.frame = rectFlip;
    
    // Fix
    CGRect rectFix = CGRectMake(self.bounds.size.width - width,0.0f , width, height);
    btnFixController.frame = rectFix;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translatedPoint = [recognizer translationInView:self.mainView];
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        firstX = [[recognizer view] center].x;
        firstY = [[recognizer view] center].y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    [[recognizer view] setCenter:translatedPoint];
    if (recognizer.state == UIGestureRecognizerStateEnded){
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskResizingStop:)])
            [self.delegate performSelectorOnMainThread:@selector(maskResizingStop:) withObject:self waitUntilDone:NO];
    }
}
-(CGRect)expandedFrame:(CGRect)rect{
    return (CGRect){0,0,rect.size.width + 10.0f, rect.size.height+ 10.0f};
}
#pragma mark - Button Touche Method
-(void)closeMaskClicked:(UIButton *)sender{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskWillRemove:)])
        [self.delegate performSelectorOnMainThread:@selector(maskWillRemove:) withObject:self waitUntilDone:NO];
}
-(void)flipMaskClicked:(UIButton *)sender{
    self.faceView.image = [self flipImage:self.faceView.image];
}
-(void)fixMaskClicked:(UIButton *)sender{
    [self fixClicked];
}

#pragma mark - Touch Up Method
-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        pointBegin = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        /*
         
         if (self.bounds.size.width < minWidth || self.bounds.size.width < minHeight)
         {
         self.bounds = CGRectMake(self.bounds.origin.x,
         self.bounds.origin.y,
         minWidth,
         minHeight);
         resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
         self.bounds.size.height-kZDStickerViewControlSize,
         kZDStickerViewControlSize,
         kZDStickerViewControlSize);
         deleteControl.frame = CGRectMake(0, 0,
         kZDStickerViewControlSize, kZDStickerViewControlSize);
         prevPoint = [recognizer locationInView:self];
         
         } else {
         CGPoint point = [recognizer locationInView:self];
         float wChange = 0.0, hChange = 0.0;
         
         wChange = (point.x - prevPoint.x);
         hChange = (point.y - prevPoint.y);
         
         if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
         prevPoint = [recognizer locationInView:self];
         return;
         }
         
         if (YES == self.preventsLayoutWhileResizing) {
         if (wChange < 0.0f && hChange < 0.0f) {
         float change = MIN(wChange, hChange);
         wChange = change;
         hChange = change;
         }
         if (wChange < 0.0f) {
         hChange = wChange;
         } else if (hChange < 0.0f) {
         wChange = hChange;
         } else {
         float change = MAX(wChange, hChange);
         wChange = change;
         hChange = change;
         }
         }
         
         self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
         self.bounds.size.width + (wChange),
         self.bounds.size.height + (hChange));
         resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
         self.bounds.size.height-kZDStickerViewControlSize,
         kZDStickerViewControlSize, kZDStickerViewControlSize);
         deleteControl.frame = CGRectMake(0, 0,
         kZDStickerViewControlSize, kZDStickerViewControlSize);
         prevPoint = [recognizer locationInView:self];
         }
         */
        
        CGPoint point = [recognizer locationInView:self];
        /* Resize */
        
        CGRect currentRect = self.bounds;
        float wChange = 0.0, hChange = 0.0;
        wChange = (point.x - pointBegin.x);
        hChange = (point.y - pointBegin.y);
        
        if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
            pointBegin = [recognizer locationInView:self];
            return;
        }
        if (wChange < 0.0f && hChange < 0.0f) {
            float change = MIN(wChange, hChange);
            wChange = change;
            hChange = change;
        }
        if (wChange < 0.0f) {
            hChange = wChange;
        } else if (hChange < 0.0f) {
            wChange = hChange;
        } else {
            float change = MAX(wChange, hChange);
            wChange = change;
            hChange = change;
        }
        CGRect newBounds = CGRectMake(currentRect.origin.x, currentRect.origin.y,
                                      currentRect.size.width + (wChange),
                                      currentRect.size.height + (hChange));
        //CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
        //                                 self.bounds.size.width + (wChange),
        //                                 self.bounds.size.height + (hChange));
        self.bounds = newBounds;
        [self resetControlOnBounds];
        
        pointBegin = [recognizer locationInView:self];
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        float angleDiff = deltaAngle - ang;
        //        if (NO == preventsResizing) {
        self.transform = CGAffineTransformMakeRotation(-angleDiff);
        //        }
        
        //        borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        //        [borderView setNeedsDisplay];
        
        
        [self setNeedsDisplay];
        
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        //        pointBegin = [recognizer locationInView:self];
        [self setNeedsDisplay];
        [self setNeedsDisplay];
        shouldResize = false;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskRotationStop:)])
            [self.delegate performSelectorOnMainThread:@selector(maskRotationStop:) withObject:self waitUntilDone:NO];
        
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    //NSLog(@"Touch Began at : %@",NSStringFromCGPoint(point));
    // NSLog(@"Image Bound : %@",NSStringFromCGRect(self.bounds));
    
    CGPoint locationInMainView = [[touches anyObject] locationInView:self.mainView];
    pointResizeStart = locationInMainView;
    
    CGPoint locationInImageView = [self convertPoint:locationInMainView fromView:self.mainView];
    
    if (CGRectContainsPoint(self.bounds, locationInImageView)){
        if(isFixed == true)
            [self showMaskControls];
        NSLog(@"Yes");
    }
    else
        NSLog(@"No");
    
    // RIGHT CONTROLLER POSITION
    CGPoint locationInRightController = [imgRightController convertPoint:locationInMainView fromView:self.mainView];
    
    // LEFT CONTROLLER POSITION
    CGPoint locationInLeftController = [imgLeftController convertPoint:locationInMainView fromView:self.mainView];
    
    // TOP CONTROLLER POSITION
    CGPoint locationInTopController = [imgTopController convertPoint:locationInMainView fromView:self.mainView];
    
    // BOTTOM CONTROLLER POSITION
    CGPoint locationInBottomController = [imgBottomController convertPoint:locationInMainView fromView:self.mainView];
    
    // ROTATE CONTROLLER POSITION
    CGPoint locationInRotateController = [imgRotationController convertPoint:locationInMainView fromView:self.mainView];
    
    // CLOSE CONTROLLER POSITION
    CGPoint locationInCloseController = [imgCloseController convertPoint:locationInMainView fromView:self.mainView];
    // FLIP CONTROLLER POSITION
    CGPoint locationInFlipController = [imgFlipController convertPoint:locationInMainView fromView:self.mainView];
    
    // FIX CONTROLLER POSITION
    CGPoint locationInFixController = [imgFixController convertPoint:locationInMainView fromView:self.mainView];
    
    // CHECK DETECTION
    if (CGRectContainsPoint([self expandedFrame:imgRightController.bounds], locationInRightController)){
        pointBegin = point;
        shouldResize = true;
        _resizeDirection = HorizontalRight;
        self._resizeDirectionForUse = _resizeDirection;
        panGesture.enabled = false;
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskResizingStart:)])
            [self.delegate performSelectorOnMainThread:@selector(maskResizingStart:) withObject:self waitUntilDone:NO];
        
    }else if (CGRectContainsPoint([self expandedFrame:imgLeftController.bounds], locationInLeftController)){
        pointBegin = point;
        shouldResize = true;
        _resizeDirection = HorizontalLeft;
        panGesture.enabled = false;
        self._resizeDirectionForUse = _resizeDirection;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskResizingStart:)])
            [self.delegate performSelectorOnMainThread:@selector(maskResizingStart:) withObject:self waitUntilDone:NO];
        
    }
    else if (CGRectContainsPoint([self expandedFrame:imgBottomController.bounds], locationInBottomController)){
        pointBegin = point;
        shouldResize = true;
        _resizeDirection = VerticalDown;
        panGesture.enabled = false;
        self._resizeDirectionForUse = _resizeDirection;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskResizingStart:)])
            [self.delegate performSelectorOnMainThread:@selector(maskResizingStart:) withObject:self waitUntilDone:NO];
        
    }else if (CGRectContainsPoint([self expandedFrame:imgTopController.bounds], locationInTopController)){
        pointBegin = point;
        shouldResize = true;
        _resizeDirection = VerticalUp;
        panGesture.enabled = false;
        self._resizeDirectionForUse = _resizeDirection;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskResizingStart:)])
            [self.delegate performSelectorOnMainThread:@selector(maskResizingStart:) withObject:self waitUntilDone:NO];
        
    }else if (CGRectContainsPoint(imgRotationController.bounds, locationInRotateController)){
        pointBegin = point;
        shouldResize = true;
        _resizeDirection = None;
        panGesture.enabled = false;
        self._resizeDirectionForUse = _resizeDirection;
        pointStartForRotation = locationInImageView;
        
        CGPoint rotateFromPoint = self.center;
        
        rotateFromPoint.y = [imgRotationController convertPoint:point toView:self.mainView].y;
        pointStartForRotation = rotateFromPoint;
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskRotationStart:)])
            [self.delegate performSelectorOnMainThread:@selector(maskRotationStart:) withObject:self waitUntilDone:NO];
        
    }else if (CGRectContainsPoint(imgCloseController.bounds, locationInCloseController)){
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskWillRemove:)])
            [self.delegate performSelectorOnMainThread:@selector(maskWillRemove:) withObject:self waitUntilDone:NO];
        
    }else if (CGRectContainsPoint(imgFlipController.bounds, locationInFlipController)){
        self.faceView.image = [self flipImage:self.faceView.image];
    }else if (CGRectContainsPoint(imgFixController.bounds, locationInFixController)){
        [self fixClicked];
    }else{
        panGesture.enabled = true;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskResizingStart:)])
            [self.delegate performSelectorOnMainThread:@selector(maskResizingStart:) withObject:self waitUntilDone:NO];
    }
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!shouldResize)
        return;
    CGRect rect = self.frame;
    CGPoint point = [[touches anyObject] locationInView:self.mainView];
    
    // Detect rotation.
    CGFloat radians = atan2f(self.transform.b, self.transform.a);
    CGFloat degrees = radians * (180 / M_PI);
    CGRect bounds = (CGRect){0,0,self.bounds.size};
    
    if (_resizeDirection == HorizontalRight ){
        CGFloat diff = point.x - pointResizeStart.x;
        
        rect.origin.x -= diff;
        rect.size.width += diff*2.0f;
        if (degrees != 0)
            bounds.size.width += diff * 2.0f;
        /*
         if (degrees == 0)
         self.frame = rect;
         else {
         bounds.size.width += diff*2.0f;
         
         CGPoint center = self.center;
         
         CGRect currentRect = self.frame;
         currentRect.size.width = bounds.size.width;
         currentRect.size.height = bounds.size.height;
         
         self.transform = CGAffineTransformIdentity;
         self.frame = currentRect;
         [self resetControl];
         self.transform = CGAffineTransformMakeRotation(radians);
         self.center = center;
         }*/
        
    }else if (_resizeDirection == HorizontalLeft ){
        CGFloat diff = pointResizeStart.x - point.x;
        rect.origin.x -= diff;
        rect.size.width += diff*2.0f;
        if (degrees != 0)
            bounds.size.width += diff * 2.0f;
        
    } else if (_resizeDirection == VerticalDown){
        CGFloat diff = point.y- pointResizeStart.y;
        rect.origin.y -= diff;
        rect.size.height += diff*2.0f;
        if (degrees != 0)
            bounds.size.height += diff * 2.0f;
        
    } else if (_resizeDirection == VerticalUp){
        CGFloat diff = pointResizeStart.y - point.y;
        rect.origin.y -= diff;
        rect.size.height += diff*2.0f;
        if (degrees != 0)
            bounds.size.height += diff * 2.0f;
    } else if (_resizeDirection == Rotate){
        
        /* Rotation */
        //        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
        //                          [recognizer locationInView:self.superview].x - self.center.x);
        
        
        float ang = atan2([imgRotationController convertPoint:point toView:self.mainView] .y - self.center.y,
                          [imgRotationController convertPoint:point toView:self.mainView].x - self.center.x);
        float angleDiff = deltaAngle - ang;
        //        if (NO == preventsResizing) {
        self.transform = CGAffineTransformMakeRotation(-angleDiff);
        //        }
        
        
    } else if (_resizeDirection == Both){
        //        CGFloat dx = point.x - pointBegin.x;
        //        CGFloat dy = point.y - pointBegin.y;
        //        rect.size.width += dx;
        //        rect.size.height += dy;
    }
    if (_resizeDirection != Rotate){
        if (degrees == 0){
            self.frame = rect;
            [self resetControl];
        } else {
            CGPoint center = self.center;
            CGRect currentRect = self.frame;
            currentRect.size.width = bounds.size.width;
            currentRect.size.height = bounds.size.height;
            
            self.transform = CGAffineTransformIdentity;
            self.frame = currentRect;
            [self resetControl];
            self.transform = CGAffineTransformMakeRotation(radians);
            self.center = center;
        }
        pointResizeStart = point;
        
        //        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskResizingInProgress:)])
        //            [self.delegate performSelectorOnMainThread:@selector(maskResizingInProgress:) withObject:self waitUntilDone:NO];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    shouldResize = false;
    panGesture.enabled = true;
    if (_resizeDirection != Rotate){
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskResizingStop:)])
            [self.delegate performSelectorOnMainThread:@selector(maskResizingStop:) withObject:self waitUntilDone:NO];
    }else{
        lastRadius = atan2f(self.transform.b, self.transform.a);
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(maskRotationStop:)])
            [self.delegate performSelectorOnMainThread:@selector(maskRotationStop:) withObject:self waitUntilDone:NO];
    }
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    shouldResize = false;
    panGesture.enabled = true;
    
}
#pragma mark - Image Processing Method
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
#pragma mark - Custom Method
-(void)hideFlip{
    //    imgFlipController.hidden = true;
    //    imgFixController.hidden = true;
    btnFlipController.hidden = true;
    btnFixController.hidden = true;
    
}
-(void)showFlip{
    //    imgFlipController.hidden = false;
    //    imgFixController.hidden = false;
    btnFlipController.hidden = false;
    btnFixController.hidden = false;
    
    borderView.hidden = false;
}
-(void)fixClicked{
    [self hideMaskControls];
    borderView.hidden = true;
}
-(void)hideMaskControls{
    imgRightController.hidden = true;
    imgLeftController.hidden = true;
    imgTopController.hidden = true;
    imgBottomController.hidden = true;
    //    imgCloseController.hidden = true;
    btnCloseController.hidden = true;
    imgRotationController.hidden = true;
    [self hideFlip];
    isFixed = true;
}
-(void)showMaskControls{
    imgRightController.hidden = false;
    imgLeftController.hidden = false;
    imgTopController.hidden = false;
    imgBottomController.hidden = false;
    //    imgCloseController.hidden = false;
    btnCloseController.hidden = false;
    imgRotationController.hidden = false;
    [self showFlip];
    isFixed = false;
}
@end
