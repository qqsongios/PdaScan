//
//  MFScanViewController.m
//  ceshi
//
//  Created by 张宇 on 2020/4/15.
//  Copyright © 2020 张宇. All rights reserved.
//




#import "MFScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIButton+Vertical.h"
#import "LBXScanView.h"
#import "LBXScanNative.h"
#import "Masonry.h"
#import "UIView+MJExtension.h"

//定义了一个__weak的self_weak_变量
#define weakifySelf  \
__weak __typeof(&*self)weakSelf = self;

//局域定义了一个__strong的self指针指向self_weak
#define strongifySelf \
__strong __typeof(&*weakSelf)self = weakSelf;

#define UI_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define WIDTH_RATIO (((UI_SCREEN_WIDTH/375) > 1) ? 1 : (UI_SCREEN_WIDTH/375))
#define FIT_SCREEN(wh) (wh * WIDTH_RATIO)
#define UIColorFromRGB(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

@interface MFScanViewController ()<LBXScanNativeDelegate>

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *scanView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UILabel *mindLabel;

@property (nonatomic, strong) UIView *scanLineView;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) UIView *translucentView;

@property (nonatomic, strong) UIButton *torchButton;

@property (nonatomic, strong) LBXScanNative *scanNative;

@property (nonatomic, strong) LBXScanLineAnimation *animation;

@property (nonatomic, strong) UIButton *leftBut;


@end

@implementation MFScanViewController {
    CGAffineTransform _captureSizeTransform;
}

- (void)dealloc {
    [self.animation stopAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupScan];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSelector:@selector(startScan) withObject:nil afterDelay:0.1];
    
}

- (void)leftButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startAnimation];
}

- (void)startScan {
    [self.scanNative startScan];
}

- (void)startAnimation {
    if (!self.animation) {
        LBXScanLineAnimation *animation = [[LBXScanLineAnimation alloc] init];
        [animation startAnimatingWithRect:self.scanView.frame InView:self.view Image:[UIImage imageNamed:@"qrcode_Scan_weixin_Line"]];
        self.animation = animation;
    }
}

- (void)startTimer {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(animationScanLine) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.scanNative stopScan];
    self.scanNative = nil;
    [_timer invalidate];
}

- (void)setupScan {
    
   
    
    self.contentView = [[UIView alloc] init];
    [self.view addSubview:self.contentView];
    self.contentView.frame = self.view.bounds;
    self.contentView.layer.masksToBounds = YES;
    self.view.layer.masksToBounds = YES;
    
    [self setupView];
    [self.view layoutIfNeeded];
    
    
    CGRect cropRect = self.scanView.frame;
    CGSize size = self.view.bounds.size;
    
    // 设置有效的扫描区域(为扫描框内的区域)
    CGRect rect = CGRectMake(cropRect.origin.y/(size.height+20),
                             
                             cropRect.origin.x/(size.width+20),
                             
                             cropRect.size.height/(size.height+20),
                             
                             cropRect.size.width/(size.width+20));
    
    
    weakifySelf
    self.scanNative = [[LBXScanNative alloc] initWithPreView:self.contentView ObjectType:nil  cropRect:rect success:^(NSArray<LBXScanResult *> *array) {
        strongifySelf
        LBXScanResult *scanResult = array[0];
        NSString*strResult = scanResult.strScanned;
        AudioServicesPlayAlertSound(1000);
        [self.scanNative stopScan];
        if (self.scanResultBlock) {
            self.scanResultBlock(strResult);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    self.scanNative.delegate = self;
    [self.scanNative setVideoScale:1.5];
}

- (void)animationScanLine {
    weakifySelf
    [UIView animateWithDuration:2.9 animations:^{
        [weakSelf.scanLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.scanView).with.offset(10);
            make.right.equalTo(weakSelf.scanView).with.offset(-10);
            make.bottom.equalTo(weakSelf.scanView).with.offset(-10);
            make.height.mas_equalTo(2);
        }];
        
        [weakSelf.scanLineView.superview layoutIfNeeded];//强制绘制
    } completion:^(BOOL finished) {
        [weakSelf.scanLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.scanView).with.offset(10);
            make.right.equalTo(weakSelf.scanView).with.offset(-10);
            make.top.equalTo(weakSelf.scanView).with.offset(10);
            make.height.mas_equalTo(2);
        }];
        [weakSelf.scanLineView.superview layoutIfNeeded];//强制绘制
    }];
}

- (void)setupView {
    self.navigationItem.title = @"扫一扫";
    
    
    UIView *translucentView = [UIView new];
    translucentView.frame = self.view.bounds;
    translucentView.backgroundColor = [UIColor blackColor];
    translucentView.alpha = 0.4;
    self.translucentView = translucentView;
    [self.view addSubview:translucentView];
    
    self.scanView = [[UIView alloc]init];
    [self.view addSubview:self.scanView];
    self.scanView.backgroundColor = [UIColor clearColor];
    self.scanView.layer.borderColor = [UIColor colorWithRed:255/255.0 green:72/255.0 blue:145/255.0 alpha:1.0].CGColor;
    self.scanView.layer.borderWidth = 1;
    
    weakifySelf
    [self.scanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view.mas_top).with.offset((162+225/2)/667.0*weakSelf.view.mj_h);
        make.centerX.equalTo(weakSelf.view);
        make.height.width.mas_equalTo(FIT_SCREEN(255));
    }];
    
    
    self.mindLabel = [[UILabel alloc]init];
    self.mindLabel.font = [UIFont systemFontOfSize:18];
    self.mindLabel.textColor = [UIColor whiteColor];
    self.mindLabel.textAlignment = NSTextAlignmentCenter;
    self.mindLabel.text = @"将二维码放入框中，即可扫描";
    [self.view addSubview:self.mindLabel];
    [self.mindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.scanView.mas_bottom).with.offset(3);
        make.height.mas_equalTo(25);
    }];
    
    self.torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.torchButton setTitle:@"轻点照亮" forState:UIControlStateNormal];
    [self.torchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.torchButton.backgroundColor = [UIColor clearColor];
    [self.scanView addSubview:self.torchButton];
    [self.scanView bringSubviewToFront:self.torchButton];
    [self.torchButton addTarget:self action:@selector(torchButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.torchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 60));
        make.bottom.equalTo(weakSelf.scanView);
        make.centerX.equalTo(weakSelf.scanView);
    }];
    
    UIImage *image = [UIImage imageNamed:@"backArrow@2x"];
    self.leftBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftBut addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.leftBut setImage:image forState:UIControlStateNormal];
    [self.leftBut setTitle:@"返回" forState:UIControlStateNormal];
    self.leftBut.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.leftBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.leftBut];
    [self.view bringSubviewToFront:self.leftBut];
    [self.leftBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(35);
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(22);
    }];
    [self.leftBut sizeToFit];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    self.gradientLayer = gradientLayer;
    
    self.gradientLayer.frame = self.scanLineView.bounds;
    self.gradientLayer.colors = @[
                             (__bridge id)[UIColor colorWithRed:255/255.0 green:72/255.0 blue:145/255.0 alpha:0.0].CGColor,
                             (__bridge id)[UIColor colorWithRed:255/255.0 green:72/255.0 blue:145/255.0 alpha:1.0].CGColor,
                             (__bridge id)[UIColor colorWithRed:255/255.0 green:72/255.0 blue:145/255.0 alpha:0].CGColor];
    self.gradientLayer.locations=@[@(0.0), @(0.5), @(1.0)];
    self.gradientLayer.startPoint = CGPointMake(0, 0.5);
    self.gradientLayer.endPoint = CGPointMake(1, 0.5);
    
    [self.scanLineView.layer addSublayer:gradientLayer];//加上渐变层
    
    [self.torchButton verticalImageAndTitle:5];
    
    [self setupSublayer];
}

- (void)setupSublayer {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:self.scanView.frame cornerRadius:0]];
    //    [path addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.view.bounds)/2) radius:50 startAngle:0 endAngle:M_PI *2 clockwise:YES];
    path.usesEvenOddFillRule = YES;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor= [UIColor blackColor].CGColor;  //其他颜色都可以，只要不是透明的
    shapeLayer.fillRule=kCAFillRuleEvenOdd;
    self.translucentView.layer.mask = shapeLayer;
    
}

- (void)torchButtonClick {
    [self.scanNative setTorch:!self.scanNative.isTorchOn];
    
}


#pragma mark - LBXScanNativeDelegate
- (void)brightnessValue:(CGFloat)brightnessValue {
    if (self.torchButton.hidden && brightnessValue < 0) {
        self.torchButton.hidden = NO;
    }
}




@end
