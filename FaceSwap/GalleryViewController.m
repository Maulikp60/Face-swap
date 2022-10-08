//
//  GalleryViewController.m
//  FaceSwap
//
//  Created by MAC on 28/04/16.
//  Copyright © 2016 ais. All rights reserved.
//

#import "GalleryViewController.h"
#import "FSCustomCell.h"
@interface GalleryViewController ()
{
    NSMutableArray *arr_GallaryImage;
    NSString *documentsDirectory;
}
@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Gallery";
    arr_GallaryImage = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    //Get All file from local document Directory
   NSMutableArray *arr_GallaryImage1 = [[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil] mutableCopy];
    arr_GallaryImage = [[[arr_GallaryImage1 reverseObjectEnumerator] allObjects] mutableCopy];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arr_GallaryImage.count;
    //    if ([tag_forCarAlbum  isEqual: @"car"]) {
    //        return arr_get_car_album_list.count;
    //    }else{
    //        return  arr_clv_car_pic.count+1;
    //    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FSCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *str = [NSString stringWithFormat:@"%@/%@",documentsDirectory,arr_GallaryImage[indexPath.row]];
    cell.clv_img.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:str]];
    return cell;
}
@end
