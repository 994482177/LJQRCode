//
//  LJCreateQRViewController.m
//  二维码
//
//  Created by LiJie on 2017/1/12.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "LJCreateQRViewController.h"

#import "LJCreateQRCode.h"
#import "LJPHPhotoTools.h"

#define kRGBColor(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface LJCreateQRViewController ()
@property (weak, nonatomic) IBOutlet UITextView *contenTextView;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (nonatomic, assign)CGFloat imageWidth;

@end

@implementation LJCreateQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.imageWidth = self.contentImageView.bounds.size.width;
}

- (IBAction)createClick:(id)sender {
    UIImage* QRcodeImage = [LJCreateQRCode createGenerateQRImageFromString:self.contenTextView.text imageWidth:self.imageWidth];
    self.contentImageView.image = QRcodeImage;
    
}

- (IBAction)logoClick:(id)sender {
    UIImage* QRcodeImage = [LJCreateQRCode createLogoQRImageFromString:self.contenTextView.text logoImage:[UIImage imageNamed:@"button"] imageWidth:self.imageWidth];
    self.contentImageView.image = QRcodeImage;
}


- (IBAction)colorClick:(id)sender {
    UIColor* imageColor = [UIColor blackColor];
    UIColor* qrColor = [UIColor redColor];
    
    UIImage* bgImge = [UIImage imageNamed:@"logo"];
    self.contentImageView.image = bgImge;
    
    UIImage* QRcodeImage = [LJCreateQRCode createColorQRImageFromString:self.contenTextView.text
                                                                bgColor:imageColor
                                                                QRColor:qrColor
                                                             imageWidth:self.imageWidth];
    
    CALayer* maskLayer=[CALayer layer];
    maskLayer.contents=(id)QRcodeImage.CGImage;
    maskLayer.bounds=self.contentImageView.bounds;
    
    maskLayer.position = CGPointMake(self.contentImageView.bounds.size.width/2.0, self.contentImageView.bounds.size.height/2.0);
    maskLayer.masksToBounds=NO;
    
    self.contentImageView.layer.mask=maskLayer;
    
    
    //将 imageView 的layer 转为Image，再重新设置回去。
    UIGraphicsBeginImageContextWithOptions(self.contentImageView.lj_size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.contentImageView.layer renderInContext:context];
    UIImage* endImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.contentImageView.layer.mask = nil;
    self.contentImageView.image = endImage;
}

- (IBAction)logoAndColor:(id)sender {
    UIImage* QRcodeImage = [LJCreateQRCode createLogoAndColorQRImageFromString:self.contenTextView.text logoImage:[UIImage imageNamed:@"logo"] bgColor:[UIColor orangeColor] QRColor:[UIColor greenColor] imageWidth:self.imageWidth];
    self.contentImageView.image = QRcodeImage;
}

- (IBAction)saveImageClick:(UIBarButtonItem *)sender {
    [LJPHPhotoTools saveImageToCameraRoll:self.contentImageView.image handler:^(BOOL success) {
        if (success) {
            [LJInfoAlert showInfo:@"保存成功" bgColor:nil];
        }else{
            [LJInfoAlert showInfo:@"保存失败" bgColor:nil];
        }
    }];
    
}












#pragma mark - ================ 工具 方法 ==================
/**  iOS获取图片UIImage颜色均值AverageColor */
- (UIColor *)averageColorForImage:(UIImage*)image {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}



/**  使用颜色创建图片： */
+ (UIImage *) createImageWithColor: (UIColor *) color{
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

/**  获取颜色透明度： */
- (CGFloat) alphaForColor:(UIColor*)color {
    
    CGFloat r, g, b, a, w, h, s, l;
    BOOL compatible = [color getWhite:&w alpha:&a];
    
    if (compatible) {
        return a;
    } else {
        compatible = [color getRed:&r green:&g blue:&b alpha:&a];
        
        if (compatible) {
            return a;
        } else {
            [color getHue:&h saturation:&s brightness:&l alpha:&a];
            return a;
        }
    }
}

/**  判断颜色深浅： */
-(BOOL)isDarkColor:(UIColor *)newColor{
    
    if ([self alphaForColor: newColor]<10e-5) {
        return YES;
    }
    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);
    
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    
    if (colorBrightness < 0.5){
        DLog(@"Color is dark");
        return YES;
    }else{
        DLog(@"Color is light");
        return NO;
    }
}



/**  取得图片某一像素点的颜色值： */
- (UIColor*) getPixelColorAtLocation:(CGPoint)point inImage:(UIImage *)image {
    
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    
    if (cgctx == NULL) {
        return nil; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    unsigned char* data = CGBitmapContextGetData (cgctx);
    
    if (data != NULL) {
        
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    CGContextRelease(cgctx);
    if (data) {
        free(data);
    }
    return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow = (pixelsWide * 4);
    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL){
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    bitmapData = malloc( bitmapByteCount );
    
    if (bitmapData == NULL){
        
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmapData,pixelsWide,pixelsHigh,8,bitmapBytesPerRow,colorSpace,kCGImageAlphaPremultipliedFirst);
    
    if (context == NULL){
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    CGColorSpaceRelease( colorSpace );
    return context;
}






@end
