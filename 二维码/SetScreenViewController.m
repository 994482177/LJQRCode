//
//  SetScreenViewController.m
//  二维码
//
//  Created by lijie on 2020/5/28.
//  Copyright © 2020 celink. All rights reserved.
//

#import "SetScreenViewController.h"
#import "LJPHPhotoTools.h"

@interface SetScreenViewController ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property(nonatomic, strong)NSArray* imagesArray;
@property(nonatomic, assign)BOOL inEdit;

@end

@implementation SetScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //设置截图
    NSString* path = [[NSBundle mainBundle]resourcePath];
    path = [path stringByAppendingPathComponent:@"ScreenImage"];
    NSFileManager *manager = [NSFileManager defaultManager];
    self.imagesArray = [manager subpathsAtPath:path];
    
    self.infoLabel.text = [NSString stringWithFormat:@"一共有 %ld 张图片需要裁剪", self.imagesArray.count];
}


- (IBAction)beginClick:(id)sender {
    
    if (self.inEdit) {
        return;
    }
    self.inEdit = YES;
    [self setImageSizeWithIndex:0];
}

-(void)addLog:(NSString*)log{
    self.infoTextView.text = [NSString stringWithFormat:@"%@%@\n", self.infoTextView.text, log];
    [self.infoTextView scrollRangeToVisible:NSMakeRange(self.infoTextView.text.length, 0)];
}

/**  设置截图的大小 */
-(void)setImageSizeWithIndex:(NSInteger)index{
    
    if (self.imagesArray.count <= index) {
        self.inEdit = NO;
        [self addLog:@"裁剪完成✅"];
        return;
    }
    [self addLog:[NSString stringWithFormat:@"开始裁剪:%@",self.imagesArray[index]]];
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"ScreenImage/%@", self.imagesArray[index]]];
    CGFloat width=image.size.width;
    CGFloat height=image.size.height;
    CGSize toSize = CGSizeMake(2048, 2732);
    
    if (image.size.width == 2245) {
        //ipadPro 12.9 {2245, 2930}
        //(2048, 2732)
        toSize = CGSizeMake(2048, 2732);
        
    }else if (image.size.width == 1728){
        //ipad 12.9
        //(2048, 2732)
        toSize = CGSizeMake(2048, 2732);
        
    }else if (image.size.width == 979 ||
              image.size.width == 1413 ||
              image.size.width == 1295){
        //iPhone XS Max
        //(1242, 2688)
        toSize = CGSizeMake(1242, 2688);
        
    }else if (image.size.width == 1446){
        //iPhone 8Plus
        //(1242, 2208)
        toSize = CGSizeMake(1242, 2208);
        
    }else{
        [self addLog:[NSString stringWithFormat:@"❌该图片尺寸不合格(%.0f,%.0f)",width, height]];
        [self setImageSizeWithIndex:index+1];
        return;
    }
    [self addLog:[NSString stringWithFormat:@"(%.0f,%.0f)->(%.0f, %.0f)",width, height, toSize.width, toSize.height]];
    
    float verticalRadio=toSize.height/height;
    float horizontalRadio=toSize.width/width;
    float radio=verticalRadio>horizontalRadio ? horizontalRadio : verticalRadio;
    
    CGFloat toWidth=width*radio;
    CGFloat toHeight=height*radio;
    
    CGFloat lead = (toSize.width - toWidth)/2.0;
    CGFloat top = (toSize.height - toHeight)/2.0;
    
    UIGraphicsBeginImageContext(toSize);
    [image drawInRect:CGRectMake(lead, top, toWidth, toHeight)];
    UIImage* newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [LJPHPhotoTools saveImageToCameraRoll:newImage handler:^(BOOL success) {
        if (success) {
            [self addLog:@"裁剪成功"];
        }else{
            [self addLog:@"❌裁剪失败"];
        }
        [self setImageSizeWithIndex:index+1];
    }];
}



@end
