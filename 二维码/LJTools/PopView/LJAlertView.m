//
//  LJAlertView.m
//  7dmallStore
//
//  Created by celink on 15/6/30.
//  Copyright (c) 2015年 celink. All rights reserved.
//

#import "LJAlertView.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

#define AppDelegateInstance	 ([UIApplication sharedApplication].delegate)
#define LJAlertButtonTextColor [UIColor whiteColor]
#define LJAlertButtonBackColor kRGBColor(96, 190, 80, 1)

@interface LJAlertView ()

@property(nonatomic, strong)CommitBlock tempBlock;
@property(nonatomic, strong)UIAlertController* tempAlert;

@end

@implementation LJAlertView
{
    __weak UIViewController* tempVC;
}

static char alertKey;
//自定义 弹出框：
+(void)customAlertWithTitle:(NSString*)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles clickButton:(CommitBlock)commit
{
    LJAlertView* tempSelf=[[LJAlertView alloc]initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles andClick:commit];
    [tempSelf show];
}
-(void)dealloc{
    DLog(@"alert dealloc");
}
-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles andClick:(CommitBlock)commit{
    self=[super init];
    //回调Block：
    self.tempBlock=commit;
    
    //ios8 用UIAlertController 替换
    _tempAlert=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction=nil;
    UIAlertAction* otherAction=nil;
    
    tempVC=delegate;
    if (!delegate) {
        tempVC=AppDelegateInstance.window.rootViewController;
    }
    objc_setAssociatedObject(AppDelegateInstance, &alertKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    @weakify(self);
    if (cancelButtonTitle!=nil){
        
        cancelAction=[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                      {
                          @strongify(self);
                          if (self.tempBlock)
                          {
                              self.tempBlock(0);
                              objc_setAssociatedObject(AppDelegateInstance, &alertKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                          }
                      }];
//        [cancelAction setValue:LJAlertButtonTextColor forKey:@"titleTextColor"];
        
        [_tempAlert addAction:cancelAction];
    }
    if (otherButtonTitles!=nil)
    {
        otherAction=[UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                     {
                         @strongify(self);
                         if (self.tempBlock)
                         {
                             self.tempBlock(1);
//                             UITextField* textField =  self.tempAlert.textFields.firstObject;
//                             NSLog(@"...%@", textField.text);
                             objc_setAssociatedObject(AppDelegateInstance, &alertKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }
                     }];
//        [otherAction setValue:LJAlertButtonTextColor forKey:@"titleTextColor"];
        [_tempAlert addAction:otherAction];
    }
//    [_tempAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        @strongify(self);
//        textField.placeholder = @"密码";
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
//    
//    }];
//    [_tempAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        @strongify(self);
//        textField.placeholder = @"账号";
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
//        
//    }];
    
    return self;
}

-(void)alertTextFieldDidChange:(NSNotification*)noti{
    UITextField* textField = noti.object;
    NSLog(@"##text= %@", textField.text);
}

-(void)show{
    
    if (tempVC!=nil)
    {
        [tempVC presentViewController:_tempAlert animated:YES completion:nil];
        
//        [self setButtonBackColor];
    }
}

-(void)setButtonBackColor{
    for (UIView* subView in _tempAlert.view.subviews) {
        for (UIView* subSubView in subView.subviews) {
            for (UIView* subSubSubView in subSubView.subviews) {
                for (UIView* subSubSubSubView in subSubSubView.subviews) {
                    if ([subSubSubSubView isKindOfClass:NSClassFromString(@"_UIInterfaceActionRepresentationsSequenceView")]) {

                        subSubSubSubView.backgroundColor = LJAlertButtonBackColor;
                    }
                }
            }
        }
    }
}

//                        for (UIView* butSubView in subSubSubSubView.subviews) {
//                            if ([butSubView isKindOfClass:NSClassFromString(@"_UIInterfaceActionSeparatableSequenceView")]) {
//                                butSubView.backgroundColor = LJAlertButtonBackColor;
//                            }
//                            NSLog(@"==%@", butSubView);
//                            for (UIView* butSub2View in butSubView.subviews) {
//                                NSLog(@"++%@", butSub2View);
//                                for (UIView* butSub3View in butSub2View.subviews) {
//                                    NSLog(@"\\\\ %@", butSub3View);
//                                }
//                                butSub2View.backgroundColor = LJAlertButtonBackColor;
//                            }
//                            UIStackView* stackView = [[UIStackView alloc]init];
//                        }


//unsigned int count=0;
//Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
//for (int i = 0; i<count; i++) {
//    Ivar ivar = ivars[i];
//    NSLog(@"#%s#------#%s#", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
//}

@end
