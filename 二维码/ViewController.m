//
//  ViewController.m
//  二维码
//
//  Created by LiJie on 15/6/25.
//  Copyright (c) 2015年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "QRView.h"
#import "LJAlertView.h"
@interface ViewController ()

@property(nonatomic, strong)QRView* contentQRView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof(self) tempWeakSelf=self;
    self.contentQRView = [QRView setQRCodeToViewController:self result:^(id result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [tempWeakSelf restartScan:result];
        });
    }];
    
    //两个可选属性：
    self.contentQRView.QRScanSize=CGSizeMake(300, 200);
    self.contentQRView.QRBackgroundColor=[[UIColor orangeColor]colorWithAlphaComponent:0.3];
    [self.contentQRView startScan];
}

-(void)restartScan:(NSString*)result{
    NSString* titleStr = @"二维码已拷贝";
    if (!result) {
        result = @"";
        titleStr = @"不存在二维码";
    }else{
        [[UIPasteboard generalPasteboard] setString:result];
    }
    [self.contentQRView stopScan];
    __weak typeof(self) tempWeakSelf=self;
    
    [LJAlertView customAlertWithTitle:titleStr message:result delegate:self cancelButtonTitle:nil otherButtonTitles:@"继续" clickButton:^(NSInteger flag) {
        [tempWeakSelf.contentQRView startScan];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.contentQRView) {
        [self.contentQRView startScan];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.contentQRView) {
        [self.contentQRView stopScan];
    }
}


- (IBAction)flashClick:(UIBarButtonItem *)sender {
    [self.contentQRView openFlash];
}
- (IBAction)albumClick:(UIBarButtonItem *)sender {
    [self.contentQRView openSystemAlbum];
}



@end
