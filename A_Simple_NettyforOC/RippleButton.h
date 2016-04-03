//
//  RippleButton.h
//  A_Simple_NettyforOC
//
//  Created by chenyonghuai on 16/3/22.
//  Copyright © 2016年 chenyonghuai. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^FlashButtonDidClickBlock)(void);

@interface RippleButton : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, copy) FlashButtonDidClickBlock clickBlock;

- (void)setText:(NSString *)text;
- (void)setTextColor:(UIColor *)textColor;
- (void)setText:(NSString *)text withTextColor:(UIColor *)textColor;

@end
