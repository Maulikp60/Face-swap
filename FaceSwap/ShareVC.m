//
//  ShareVC.m
//  FaceSwap
//
//  Created by MAC on 09/01/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "ShareVC.h"
#import <Social/Social.h>
#import "RemoveAdsVC.h"
#import <MessageUI/MessageUI.h>
@interface ShareVC ()<MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UIDocumentMenuDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *dic;

@end

@implementation ShareVC
@synthesize heightconstrain,lbl_Height;
- (void)viewDidLoad {
    [super viewDidLoad];
    imgMyImage.image = self.myImage;
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *BackBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(barBackClicked:)];
    self.navigationItem.leftBarButtonItem = BackBar;
    UIBarButtonItem *HomeBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home"] style:UIBarButtonItemStylePlain target:self action:@selector(barHomeClicked:)];
    self.navigationItem.rightBarButtonItem = HomeBar;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [btnObj_Email setImage:[UIImage imageNamed:@"email after click"] forState:UIControlStateHighlighted];
    [btnObj_Facebook setImage:[UIImage imageNamed:@"facebook after click"] forState:UIControlStateHighlighted];
    [btnObj_Gallery setImage:[UIImage imageNamed:@"gallery after click"] forState:UIControlStateHighlighted];
    [btnObj_Instagram setImage:[UIImage imageNamed:@"instagram after click"] forState:UIControlStateHighlighted];
    [btnObj_More setImage:[UIImage imageNamed:@"more after click"] forState:UIControlStateHighlighted];
    [btnObj_MoreApps setImage:[UIImage imageNamed:@"more apps after click"] forState:UIControlStateHighlighted];
    [btnObj_RateUs setImage:[UIImage imageNamed:@"rate us after click"] forState:UIControlStateHighlighted];
    [btnObj_Twitter setImage:[UIImage imageNamed:@"twitter after click"] forState:UIControlStateHighlighted];
    
  /*  NSString * timestamp = [NSString stringWithFormat:@"%f.jpg",[[NSDate date] timeIntervalSince1970] * 1000];

    NSData *data = UIImagePNGRepresentation(self.myImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:timestamp];
    [data writeToFile:filePath atomically:YES];
    */
    btnRemoveAds.hidden = true;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self isPurchasedUnlockPro]){
        lbl_Bottom.hidden = false;
    }else{
        lbl_Bottom.hidden = true;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)barBackClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)barHomeClicked:(id)sender{
    [self btnBackClicked];
//
}
-(void)btnBackClicked{
    [self showConfirmAlertForGoBack];
}
-(void)showConfirmAlertForGoBack{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Oh! You haven’t share the photo! Do you want to import a new one?                               All the change will lost"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"YES"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self.navigationController popToRootViewControllerAnimated:YES];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                         }];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - Button Touch Method
//- (IBAction)btnRemoveAdClicked:(id)sender {
//    [self.navigationController setNavigationBarHidden:false];
//    RemoveAdsVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RemoveAdsVC"];
//    [[self navigationController] pushViewController:VC animated:YES];
//    //    [self showConfirmAlertForInapp];
//}
- (IBAction)btnShowSomeLoveClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:AppLink];
    [[UIApplication sharedApplication] openURL:url];
}
-(IBAction)postToInstagram:(id)sender{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
    {
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.igo"];
        
        NSFileManager *fileManager =[NSFileManager defaultManager];
        NSError *err = nil;
        if ([fileManager fileExistsAtPath:jpgPath]){
            [fileManager removeItemAtPath:jpgPath error:&err];
        }
        if (err == nil){
            [fileManager createFileAtPath:jpgPath contents:UIImageJPEGRepresentation(self.myImage, 1.0) attributes:nil];
        }
        
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
        self.dic.UTI = @"com.instagram.photo";
        self.dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
        self.dic=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        UIButton * btn = (UIButton *)sender;
        CGRect rect = (CGRect){btn.frame.origin.x,btn.frame.origin.y};
        rect = [btn convertRect:rect toView:self.view];
        [self.dic presentOpenInMenuFromRect:rect inView: self.view animated: YES ];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please download and install Instagram to follow Faceswap" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(IBAction)saveToGallery:(id)sender{
    UIImageWriteToSavedPhotosAlbum(self.myImage, nil, nil, nil);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Saved in gallery." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}
- (IBAction)postToTwitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
//        [tweetSheet setInitialText:@"Faceswap app: checkout my latest photo."];
        [tweetSheet addImage:self.myImage];
        [tweetSheet addURL:[NSURL URLWithString:AppiTunes_Link]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}
- (IBAction)postToFacebook:(id)sender {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Faceswap app: checkout my latest photo."];
       // [controller addURL:[NSURL URLWithString:AppiTunes_Link]];
        [controller addImage:self.myImage];

        [self presentViewController:controller animated:YES completion:Nil];
    }
}
- (IBAction)emailPhoto:(id)sender {
    [self showEmail:@""];
}
- (void)showEmail:(NSString*)file {
//    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        NSString *emailTitle = @"Great Photo created by FaceSwap app";
        NSString *messageBody = @"Hey, check this out!";
        messageBody = [messageBody stringByAppendingFormat:@"Download App at %@", AppiTunes_Link];
        //NSArray *toRecipents = [NSArray arrayWithObject:@"support@appcoda.com"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        //[mc setToRecipients:toRecipents];
        
        // Determine the file name and extension
        /*
         NSArray *filepart = [file componentsSeparatedByString:@"."];
         NSString *filename = [filepart objectAtIndex:0];
         NSString *extension = [filepart objectAtIndex:1];
         
         // Get the resource path and read the file using NSData
         NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
         NSData *fileData = [NSData dataWithContentsOfFile:filePath];
         
         // Determine the MIME type
         NSString *mimeType;
         if ([extension isEqualToString:@"jpg"]) {
         mimeType = @"image/jpeg";
         } else if ([extension isEqualToString:@"png"]) {
         mimeType = @"image/png";
         } else if ([extension isEqualToString:@"doc"]) {
         mimeType = @"application/msword";
         } else if ([extension isEqualToString:@"ppt"]) {
         mimeType = @"application/vnd.ms-powerpoint";
         } else if ([extension isEqualToString:@"html"]) {
         mimeType = @"text/html";
         } else if ([extension isEqualToString:@"pdf"]) {
         mimeType = @"application/pdf";
         }*/
        NSData *imageData = UIImageJPEGRepresentation(self.myImage, 1.0f);
        // Add attachment
        [mc addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"FaceSwap.jpg"];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This device is unable to send mail.Please configure mail in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
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
-(IBAction)showMoreOptions:(id)sender{
   /* NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
//    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:getImagePath]){
        [fileManager removeItemAtPath:getImagePath error:nil];
    }
    NSData *data = UIImageJPEGRepresentation(self.myImage, 1.0);
    [data writeToFile:getImagePath atomically:true];
    
    NSURL *fileURL = [NSURL fileURLWithPath:getImagePath];
    
    UIDocumentInteractionController *documentInterationControl = [self setupControllerWithURL:fileURL usingDelegate:self];
//    [documentInterationControl presentOpenInMenuFromRect:(CGRect){0, self.view.frame.size.height - 20.0, self.view.frame.size.width, 20.0f} inView:self.view animated:true];
    documentInterationControl.delegate = self;
   [ documentInterationControl presentOptionsMenuFromRect:(CGRect){0, self.view.frame.size.height - 20.0, self.view.frame.size.width, 20.0f} inView:self.view animated:true];*/
    
    UIImage *image = self.myImage;
    NSArray * shareItems = @[image];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
}
- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL *) fileURL
                                               usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    
    UIDocumentInteractionController *interactionController =
    [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}
-(void)documentInteractionControllerWillPresentOptionsMenu:(UIDocumentInteractionController *)controller{
    if(self.banner != nil && [self isPurchasedUnlockPro] == false){
        self.banner.hidden = true;
    }
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}
-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    if(self.banner != nil && [self isPurchasedUnlockPro] == false){
        self.banner.hidden = false;
    }
}

-(void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller{
    if(self.banner != nil && [self isPurchasedUnlockPro] == false){
        self.banner.hidden = false;
    }
}
-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    if(self.banner != nil && [self isPurchasedUnlockPro] == false){
        self.banner.hidden = false;
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
