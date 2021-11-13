#import "PdaScanPlugin.h"
#import "MFScanViewController.h"
#import "MFNavigationViewController.h"

@interface PdaScanPlugin()
@property (nonatomic, strong) UIWindow *window;

@end

@implementation PdaScanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/missfresh.qrcode"
            binaryMessenger:[registrar messenger]];
  PdaScanPlugin* instance = [[PdaScanPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"scan" isEqualToString:call.method]){
      [self jumpScanVc:result];
  }else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)jumpScanVc:(FlutterResult)result{
    MFScanViewController *scanViewController = [[MFScanViewController alloc]init];
    scanViewController.scanResultBlock = ^(NSString * _Nonnull value) {
        result(value);
    };
     
      UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
      while (topRootViewController.presentedViewController)
      {
      topRootViewController = topRootViewController.presentedViewController;
      }
      scanViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext&UIModalPresentationOverFullScreen;
      [topRootViewController presentViewController:scanViewController animated:YES completion:nil];
}


@end
