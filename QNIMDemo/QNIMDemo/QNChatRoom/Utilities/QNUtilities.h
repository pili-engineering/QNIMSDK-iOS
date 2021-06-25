//
//  QNUtilities.h
//  ChatRoom
//
//  Created by 孙承秀 on 2018/5/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ISX [UIScreen mainScreen].bounds.size.height == 812

@interface QNUtilities : NSObject
+ (instancetype)instance;
- (void)blockRoom:(NSString *)roomId duration:(int)duration;
- (BOOL)isLockedRoom:(NSString *)roomId;
+ (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2;
+ (NSString *)getDemoVersion;
@end
