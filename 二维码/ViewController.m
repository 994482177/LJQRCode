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
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof(self) tempWeakSelf=self;
    self.contentQRView = [QRView setQRCodeToViewController:self result:^(id result) {
        //NSLog(@"%@", result);
        dispatch_async(dispatch_get_main_queue(), ^{
            [tempWeakSelf restartScan:result];
        });
    }];
    
    
    
    //两个可选属性：
    self.contentQRView.QRScanSize=CGSizeMake(300, 200);
    self.contentQRView.QRBackgroundColor=[[UIColor orangeColor]colorWithAlphaComponent:0.3];
//    self.contentQRView.QRBackgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"logo"]]colorWithAlphaComponent:0.3];
    
    
    [self.contentQRView startScan];
}

-(void)restartScan:(NSString*)result{
    [self.contentQRView stopScan];
    __weak typeof(self) tempWeakSelf=self;
    [LJAlertView customAlertWithTitle:@"二维码" message:result delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"commit" clickButton:^(NSInteger flag) {
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
