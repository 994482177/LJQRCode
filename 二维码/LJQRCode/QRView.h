//
//  QRView.h
//  二维码
//
//  Created by LiJie on 15/11/5.
//  Copyright © 2015年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QRBlock)(id result);

@interface QRView : UIView

@property(nonatomic, copy)UIColor* QRBackgroundColor;   //背景色(默认灰色，半透明)(一定要加 colorWithAlphaComponent)
@property(nonatomic, assign)CGSize QRScanSize;         //扫描框的大小 默认Frame 的一半大小）



+(instancetype)getQRViewWithFrame:(CGRect)frame result:(QRBlock)resultBlock;

-(void)startScan;   //开始扫描
-(void)stopScan;    //停止扫描


@end
