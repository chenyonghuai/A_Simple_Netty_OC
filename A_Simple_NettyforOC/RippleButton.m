//
//  RippleButton.m
//  A_Simple_NettyforOC
//
//  Created by chenyonghuai on 16/3/22.
//  Copyright © 2016年 chenyonghuai. All rights reserved.
//

#import "RippleButton.h"

@implementation RippleButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:tap];
        
        self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setTextAlignment:NSTextAlignmentCenter];
        self.textLabel.font = [UIFont systemFontOfSize:16.0];
        [self addSubview:self.textLabel];
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor grayColor];
        
        CAShapeLayer *circleShape = nil;
        CGFloat scale = 2.5f;
        
        CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
        
        circleShape = [self createCircleShapeWithPosition:CGPointMake(width/2, height/2)
                                                 pathRect:CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), width, height)
                                                   radius:50];
        
        [self.layer addSublayer:circleShape];
        
        CAAnimationGroup *groupAnimation = [self createFlashAnimationWithScale:scale duration:3.0f];
        /* Use KVC to remove layer to avoid memory leak */
        [groupAnimation setValue:circleShape forKey:@"circleShaperLayer"];
        [circleShape addAnimation:groupAnimation forKey:nil];
    }
    return self;
}


#pragma mark - Public
- (void)setText:(NSString *)text
{
    [self setText:text withTextColor:nil];
}

- (void)setTextColor:(UIColor *)textColor
{
    [self setText:nil withTextColor:textColor];
}

- (void)setText:(NSString *)text withTextColor:(UIColor *)textColor
{
    if (textColor) {
        [self.textLabel setTextColor:textColor];
    }
    
    if (text) {
        [self.textLabel setText:text];
    }
}

#pragma mark - Private
- (void)didTap:(UITapGestureRecognizer *)tapGestureHandler
{
    if (self.clickBlock) {
        self.clickBlock();
    }
    
}

- (CAShapeLayer *)createCircleShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect radius:(CGFloat)radius
{
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = [self createCirclePathWithRadius:rect radius:radius];
    circleShape.position = position;
    
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.strokeColor = [UIColor colorWithRed:255/255.f green:119/255.f blue:0/255.f alpha:1].CGColor;
    
    circleShape.opacity = 0;
    circleShape.lineWidth = 4;
    
    return circleShape;
}

- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4, 1.4, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0.4;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.delegate = self;
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = INT_MAX;
    return animation;
}

- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius
{
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CALayer *layer = [anim valueForKey:@"circleShaperLayer"];
    if (layer) {
        [layer removeFromSuperlayer];
    }
}

@end
