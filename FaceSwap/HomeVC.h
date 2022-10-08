//
//  HomeVC.h
//  FaceSwap
//
//  Created by MAC on 09/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
@import GoogleMobileAds;

@interface HomeVC : SuperViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *picker;
    __weak IBOutlet GADBannerView *bannerView;
    UIImage *myImage;
 
    __weak IBOutlet UIButton *btnObj_Library;
    __weak IBOutlet UIButton *btnObj_Camera;
}
/*
 
 <key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
 
 <key>NSAppTransportSecurity</key>
	<dict>
 <key>NSAllowsArbitraryLoads</key>
 <true/>
 <dict>
 <key>NSExceptionMinimumTLSVersion</key>
 <string>TLSv1.0</string>
 </dict>
	</dict>
 */

@end
