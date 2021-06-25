//
//  QNIMMessageObject.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageConfig;

typedef enum {
    QNIMContentTypeText = 0,
    QNIMContentTypeImage,
    QNIMContentTypeVoice,
    QNIMContentTypeVideo,
    QNIMContentTypeFile,
    QNIMContentTypeLocation,
    QNIMContentTypeCommand,
    QNIMContentTypeForward,
}QNIMContentType;

typedef enum {
    QNIMMessageTypeSingle = 0, // 单聊消息
    QNIMMessageTypeGroup, // 群聊消息
    QNIMMessageTypeSystem, //系统消息
}QNIMMessageType;

@interface QNIMMessageObject : NSObject

@property (nonatomic, assign, readonly) long long msgId;

@property (nonatomic, assign) long long fromId;

@property (nonatomic, assign) long long toId;

@property (nonatomic, assign) long long conversationId;

@property (nonatomic, assign) QNIMMessageType messageType;

@property (nonatomic, assign) long long serverTimestamp;

@property (nonatomic, assign) long long clientTimestamp;

@property (nonatomic, assign) BOOL isReceiveMsg;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *extensionJson;

@property (nonatomic, assign) QNIMContentType contentType;

@property (nonatomic,copy) NSString *senderName;

//群消息AckCount数目
@property (nonatomic,assign) int groupAckCount;

/**
 创建文本消息

 @param content 内容
 @param fromId 发送id
 @param toId 接收id
 @param mtype 消息类型
 @param conversationId 会话id
 @return QNIMMessageObject
 */
- (instancetype)initWithQNIMMessageText:(NSString *)content
                                fromId:(long long )fromId
                                  toId:(long long)toId
                                  type:(QNIMMessageType)mtype
                        conversationId:(long long )conversationId;

/// 创建发送命令消息(命令消息通过content字段或者extension字段存放命令信息)
/// @param content 消息内容
/// @param fromId 消息发送者
/// @param toId 消息接收者
/// @param mtype 消息类型
/// @param conversationId 会话id
- (instancetype)initWithQNIMCommandMessageText:(NSString *)content
                                       fromId:(long long )fromId
                                         toId:(long long)toId
                                         type:(QNIMMessageType)mtype
                               conversationId:(long long )conversationId;

/**
 创建接收文本消息

 @param content 内容
 @param msgId 消息id
 @param fromId 发送id
 @param toId 接收id
 @param mtype 消息类型
 @param conversationId 会话id
 @param timeStamp 时间戳
 @return QNIMMessageObject
 */
- (instancetype)initWithRecieveQNIMMessageText:(NSString *)content
                                        msgId:(long long)msgId
                                       fromId:(long long )fromId
                                         toId:(long long)toId
                                         type:(QNIMMessageType)mtype
                               conversationId:(long long )conversationId
                                    timeStamp:(long long)timeStamp;



/// 创建收到的命令消息(命令消息通过content字段或者extension字段存放命令信息)
/// @param content 消息内容
/// @param msgId 消息id
/// @param fromId 消息发送者
/// @param toId 消息接收者
/// @param mtype 消息类型
/// @param conversationId 会话id
/// @param timeStamp 服务器时间戳
- (instancetype)initWithRecieveQNIMMessageCommandMessageText:(NSString *)content
                                                       msgId:(long long)msgId
                                                                fromId:(long long )fromId
                                                                  toId:(long long)toId
                                                                  type:(QNIMMessageType)mtype
                                                        conversationId:(long long )conversationId
                                                             timeStamp:(long long)timeStamp;                                                

@end

NS_ASSUME_NONNULL_END
