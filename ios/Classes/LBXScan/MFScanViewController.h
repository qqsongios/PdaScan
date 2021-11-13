//
//  MFScanViewController.h
//  ceshi
//
//  Created by 张宇 on 2020/4/15.
//  Copyright © 2020 张宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ScanResultBlock)(NSString *result);

@interface MFScanViewController : UIViewController
@property (nonatomic, copy) ScanResultBlock scanResultBlock;

@end

NS_ASSUME_NONNULL_END
