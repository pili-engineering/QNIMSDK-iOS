//
//  QNIMChatServiceProtocol.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/7.
//

#import <Foundation/Foundation.h>

@class QNIMMessageObject;
@class QNIMError;

@protocol QNIMChatServiceProtocol <NSObject>


@optional

/**
 * 消息发送状态发生变化
 **/
- (void)messageStatusChanged:(QNIMMessageObject *)message
            error:(QNIMError *)error;

/**
 * 收到消息
 **/
- (void)receivedMessages:(NSArray<QNIMMessageObject*> *)messages;

@end



