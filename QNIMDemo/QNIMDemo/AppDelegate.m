//
//  AppDelegate.m
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/1.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <QNIMSDK/QNIMSDK.h>
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "MBProgressHUD+QNShow.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initializeQNIM];
    
    return YES;
}

//初始化QNIM
- (void)initializeQNIM{
    NSString* dataDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"ChatData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dataDir]) {
        [fileManager createDirectoryAtPath:dataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"UserCache"];
    if (![fileManager fileExistsAtPath:cacheDir]) {
        [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"dataDir = %@", dataDir);
    NSLog(@"cacheDir = %@", cacheDir);
  
    NSString* phoneName = [[UIDevice currentDevice] name];
    NSString* localizedModel = [[UIDevice currentDevice] localizedModel];
    NSString* systemName = [[UIDevice currentDevice] systemName];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
  
    NSString *phone = [NSString stringWithFormat:@"设备名称:%@;%@;%@;%@", phoneName,localizedModel,systemName,phoneVersion];

    QNSDKConfig *config = [[QNSDKConfig alloc]initConfigWithDataDir:dataDir cacheDir:cacheDir userAgent:phone];
    config.appID = @"dxdjbunzmxiu";
    config.appSecret = @"47B13PBIAPDARZKD";
    [[QNIMClient sharedClient] registerWithSDKConfig:config];
    
}


@end
