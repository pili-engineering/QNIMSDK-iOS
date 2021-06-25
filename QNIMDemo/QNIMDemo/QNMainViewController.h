//
//  QNMainViewController.h
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/17.
//

#import <UIKit/UIKit.h>
#import "QNRTCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNMainViewController : QNRTCBaseViewController

@property (nonatomic, copy) NSString *roomToken;

@property (nonatomic, copy) NSString *groupId;

@end

NS_ASSUME_NONNULL_END
