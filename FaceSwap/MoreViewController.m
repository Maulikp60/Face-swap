//
//  MoreViewController.m
//  FaceSwap
//
//  Created by MAC on 18/02/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "MoreViewController.h"


@interface MoreViewController ()<SBPageFlowViewDelegate,SBPageFlowViewDataSource>{
    NSArray *_imageArray;

    NSArray *urlArray;
    NSInteger    _currentPage;
    
    SBPageFlowView  *_flowView;
}

@end

@implementation MoreViewController{
    CGFloat firstX;
    CGFloat firstY;
    CGPoint pointBegin;
    BOOL shouldResize;
    
    UIImageView *imgRightController;
    UIImageView *imgBottomController;
    UIImageView *imgRotationController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:false];
    /*
    // Add control on imageview
    // Right
    CGRect rectRight = CGRectMake(_imgMask.frame.size.width - 20.0f, _imgMask.frame.size.height/2 - 20.0, 40.0, 40.0);
    imgRightController = [[UIImageView alloc] initWithFrame:rectRight];
    imgRightController.image = [UIImage imageNamed:@"expand"];
    [self.imgMask addSubview:imgRightController];

    // Bottom
    CGRect rectBottom = CGRectMake(_imgMask.frame.size.width/2.0 - 20.0, _imgMask.frame.size.height - 20.0, 40.0, 40.0);
    imgBottomController = [[UIImageView alloc] initWithFrame:rectBottom];
    imgBottomController.image = [UIImage imageNamed:@"expand"];
    [self.imgMask addSubview:imgBottomController];

    // Rotate
    CGRect rectRotate = CGRectMake(_imgMask.frame.size.width - 20.0, _imgMask.frame.size.height - 20.0, 40.0, 40.0);
    imgRotationController = [[UIImageView alloc] initWithFrame:rectRotate];
    imgRotationController.image = [UIImage imageNamed:@"expand"];
    [self.imgMask addSubview:imgRotationController];
    
   
  
    float x = 0;
    float y = 20;
    float width = 100;
    float height = 100;
    
    for (int i=0; i<3; i++) {
        CGRect rect = CGRectMake(x, y, width, height);
        x += 120;
        y += 120;
        MaskView *mask = [[MaskView alloc] initWithFrame:rect];
        [self.view addSubview:mask];
//        mask.mainView = self.view;
        
        //mask.contentView = faceView;

        [self.view addSubview:mask];
        
    } 
     */
    
    _imageArray = [[NSArray alloc] initWithObjects:@"add text to photos",@"audio video mixer",@"beastly photo art",@"emoji picture editor",@"pip camera",nil];
    
    _currentPage = 0;
    
    _flowView = [[SBPageFlowView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height)];
    _flowView.delegate = self;
    _flowView.dataSource = self;
    _flowView.minimumPageAlpha = 0.6;
    _flowView.minimumPageScale = 0.8;
    _flowView.defaultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];
    [self.view addSubview:_flowView];
    
    [_flowView reloadData];
    
//    UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btn.frame = CGRectMake(130, 260, 60, 30);
//    [btn setTitle:@"下一页" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(scropTo:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
    urlArray = @[
                 @"https://itunes.apple.com/us/app/add-text-to-photos-letter/id1048950445?mt=8",
                 @"https://itunes.apple.com/us/app/audio-video-mixer-background/id1006386292?mt=8",
                 @"https://itunes.apple.com/us/app/beastly-photo-art-funny-animal/id969953584?mt=8",
                 @"https://itunes.apple.com/us/app/emoji-picture-editor-add-emoticons/id1025844317?mt=8",
                 @"https://itunes.apple.com/us/app/best-pip-camera-app-free-photo/id1073869864?mt=8"
                 ];
}

- (void)scropTo:(id)sender{
    [_flowView scrollToNextPage];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - PagedFlowView Datasource
//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(SBPageFlowView *)flowView{
    return [_imageArray count];
}

- (CGSize)sizeForPageInFlowView:(SBPageFlowView *)flowView;{
    if ([[[UIDevice currentDevice] model] containsString:@"iPhone"])
        return CGSizeMake(240, 426);//self.view.frame.size.height -150.0f);
    else
        return CGSizeMake(self.view.frame.size.width - self.view.frame.size.width/3, self.view.frame.size.height - 200.0f);
}

//返回给某列使用的View
- (UIView *)flowView:(SBPageFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    UIImageView *imageView = (UIImageView *)[flowView dequeueReusableCell];
    if (!imageView) {
        imageView = [[UIImageView alloc] init] ;
        imageView.layer.masksToBounds = YES;
    }
    
    imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:index]];
    return imageView;
}

#pragma mark - PagedFlowView Delegate
- (void)didReloadData:(UIView *)cell cellForPageAtIndex:(NSInteger)index
{
    UIImageView *imageView = (UIImageView *)cell;
    imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:index]];
}

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(SBPageFlowView *)flowView {
//    NSLog(@"Scrolled to page # %d", pageNumber);
    _currentPage = pageNumber;
    pageControl.currentPage = _currentPage;
}

- (void)didSelectItemAtIndex:(NSInteger)index inFlowView:(SBPageFlowView *)flowView
{
//    NSLog(@"didSelectItemAtIndex: %d", index);
    
    NSString *urlString = urlArray[index];
//    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
    
//    UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                     message:[NSString stringWithFormat:@"您当前选择的是第 %d 个图片",index]
//                                                    delegate:self
//                                           cancelButtonTitle:@"确定"
//                                           otherButtonTitles: nil];
//    [alert show];
//    [alert release];
    
}

/*
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        firstX = [[recognizer view] center].x;
        firstY = [[recognizer view] center].y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
//    if (translatedPoint.y < 10.0f){
//        translatedPoint.y = 10.0f;
//    }else if (translatedPoint.y > (recognizer.view.frame.size.height - 10.0f)){
//        translatedPoint.y = (recognizer.view.frame.size.height) - 10.0f;
//    }
    
    //    if (CGRectContainsPoint(imgMyImage.frame, translatedPoint) == true){
    [[recognizer view] setCenter:translatedPoint];
    //    }
}
- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}
*/
@end
