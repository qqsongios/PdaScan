//
//  LBXScanLineAnimation.m
//
//
//  Created by lbxia on 15/11/3.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanLineAnimation.h"


@interface LBXScanLineAnimation()
{
    int num;
    BOOL down;
    NSTimer * timer;
    
    BOOL isAnimationing;
}

@property (nonatomic,assign) CGRect animationRect;

@end



@implementation LBXScanLineAnimation



- (void)stepAnimation
{
    if (!isAnimationing) {
        return;
    }
    
   
    CGFloat leftx = _animationRect.origin.x + 5;
    CGFloat width = _animationRect.size.width - 10;
    
    self.frame = CGRectMake(leftx, _animationRect.origin.y + 8, width, 8);
    
    self.alpha = 0.0;
    
    self.hidden = NO;
    
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.5 animations:^{
         weakSelf.alpha = 1.0;
        
     
        
    } completion:^(BOOL finished)
     {
         
     }];
    
    [UIView animateWithDuration:3 animations:^{
        CGFloat leftx = _animationRect.origin.x + 5;
        CGFloat width = _animationRect.size.width - 10;
        
        
        
        weakSelf.frame = CGRectMake(leftx, _animationRect.origin.y + _animationRect.size.height - 8, width, 2);
        
    } completion:^(BOOL finished)
     {
         self.hidden = YES;
         [weakSelf performSelector:@selector(stepAnimation) withObject:nil afterDelay:0.3];
     }];
}



- (void)startAnimatingWithRect:(CGRect)animationRect InView:(UIView *)parentView Image:(UIImage*)image
{
    if (isAnimationing) {
        return;
    }
    
    isAnimationing = YES;

    
    self.animationRect = animationRect;
    down = YES;
    num =0;
    
    CGFloat centery = CGRectGetMinY(animationRect) + CGRectGetHeight(animationRect)/2;
    CGFloat leftx = animationRect.origin.x + 5;
    CGFloat width = animationRect.size.width - 10;
    
    self.frame = CGRectMake(leftx, centery+2*num, width, 2);
    self.image = image;
//    self.backgroundColor = [UIColor redColor];
    [parentView addSubview:self];
    
    [self startAnimating_UIViewAnimation];
    
//    [self startAnimating_NSTimer];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer = gradientLayer;
    
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[
                                  (__bridge id)[UIColor colorWithRed:255/255.0 green:72/255.0 blue:145/255.0 alpha:0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:255/255.0 green:72/255.0 blue:145/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:255/255.0 green:72/255.0 blue:145/255.0 alpha:0].CGColor];
    gradientLayer.locations=@[@(0.0), @(0.5), @(1.0)];
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    
    [self.layer addSublayer:gradientLayer];//加上渐变层
    
//    [self setupSublayer];
}

- (void)startAnimating_UIViewAnimation
{
     [self stepAnimation];
}

- (void)startAnimating_NSTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(scanLineAnimation) userInfo:nil repeats:YES];
}

-(void)scanLineAnimation
{
    CGFloat centery = CGRectGetMinY(_animationRect) + CGRectGetHeight(_animationRect)/2;
    CGFloat leftx = _animationRect.origin.x + 5;
    CGFloat width = _animationRect.size.width - 10;
    
    if (down)
    {
        num++;
        
        self.frame = CGRectMake(leftx, centery+2*num, width, 2);
        
        if (centery+2*num > (CGRectGetMinY(_animationRect) + CGRectGetHeight(_animationRect) - 5 ) )
        {
            down = NO;
        }
    }
    else {
        num --;
        self.frame = CGRectMake(leftx, centery+2*num, width, 2);
        if (centery+2*num < (CGRectGetMinY(_animationRect) + 5 ) )
        {
            down = YES;
        }
    }
}

- (void)dealloc
{
    [self stopAnimating];
}

- (void)stopAnimating
{
    if (isAnimationing) {
        
        isAnimationing = NO;
        
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        
        [self removeFromSuperview];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];  
}

@end
