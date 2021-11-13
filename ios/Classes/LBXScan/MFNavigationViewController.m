//
//  MFNavigationViewController.m
//  Masonry
//
//  Created by 张宇 on 2020/4/16.
//

#import "MFNavigationViewController.h"

#define UIColorFromRGB(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])


@interface MFNavigationViewController ()

@end

@implementation MFNavigationViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
}







@end
