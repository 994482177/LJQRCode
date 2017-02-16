//
//  ViewController.m
//  二维码
//
//  Created by LiJie on 15/6/25.
//  Copyright (c) 2015年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "QRView.h"

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
        NSLog(@"%@", result);
        [tempWeakSelf restartScan];
    }];
    
    //两个可选属性：
    self.contentQRView.QRScanSize=CGSizeMake(300, 200);
    self.contentQRView.QRBackgroundColor=[[UIColor orangeColor]colorWithAlphaComponent:0.3];
//    self.contentQRView.QRBackgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"logo"]]colorWithAlphaComponent:0.3];
    
    
    [self.contentQRView startScan];
    
}

-(void)restartScan{
    
}
- (IBAction)flashClick:(UIBarButtonItem *)sender {
    [self.contentQRView openFlash];
}
- (IBAction)albumClick:(UIBarButtonItem *)sender {
    [self.contentQRView openSystemAlbum];
}



@end
