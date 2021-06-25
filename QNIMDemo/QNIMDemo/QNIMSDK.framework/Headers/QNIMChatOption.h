//
//  QNIMChatOption.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/15.
//

#import <Foundation/Foundation.h>
#import "QNIMChatServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject,QNIMError;

@interface QNIMChatOption : NSObject

- (void)addDelegate:(id<QNIMChatServiceProtocol>)aDelegate;

+ (instancetype)sharedOption;

- (void)sendMessage:(QNIMMessageObject *)message;

/**
 * 读取一条消息
 **/
- (void)getMessage:(NSInteger)messageId
        completion:(void(^)(QNIMMessageObject *message, QNIMError *error))aCompletionBlock;
@end

NS_ASSUME_NONNULL_END
