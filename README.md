# QNIMSDK-iOS

# 七牛IM 

### 初始化IM

```

NSString* dataDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"ChatData"];
NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"UserCache"];
NSString *userAgent = [NSString stringWithFormat:@"设备名称:%@;%@;%@;%@", phoneName,localizedModel,systemName,phoneVersion];

QNSDKConfig *config = [[QNSDKConfig alloc]initConfigWithDataDir:dataDir cacheDir:cacheDir pushCertName:@"推送证书名" userAgent:userAgent];
config.appID = @"";
[[QNIMClient sharedClient] registerWithSDKConfig:config];

```

## QNIMClient 核心类

### 注册新用户

```

/**
 注册新用户，username和password是必填参数

 @param userName 用户名
 @param password 密码
 @param aCompletionBlock 注册成功后从该函数处获取新注册用户的Profile信息，初始传入指向为空的shared_ptr对象即可。
 */
- (void)signUpNewUser:(NSString *)userName password:(NSString *)password completion:(void (^)(QNIMUserProfile *profile, QNIMError *error))aCompletionBlock;
          
```

### 登录IM

```

/**
 * 通过用户名登录
 **/
- (void)signInByName:(NSString *)userName password:(NSString *)password completion:(void(^)(QNIMError *error))aCompletionBlock;
          
```

```

/**
 * 通过用户ID登录
 **/
- (void)signInById:(long long)userId password:(NSString *)password completion:(void(^)(QNIMError *error))aCompletionBlock;

```

### 退出登录

```

- (void)signOutID:(NSInteger)userID ignoreUnbindDevice:(BOOL)ignoreUnbindDevice completion:(void(^)(QNIMError *error))aCompletionBlock;


```


## 创建群的配置 QNIMCreatGroupOption


```

/**
 是否聊天室
 */
@property (nonatomic, assign) BOOL isChatroom;

/**
 创建群配置实体

 @param name 必填
 @param groupDescription 非必填
 @return QNIMCreatGroupOption
 */
- (instancetype)initWithGroupName:(NSString *)name
                 groupDescription:(NSString *)groupDescription
                         isPublic:(BOOL)isPublic;

```

## 群操作 QNIMGroupService

```

/**
 加入群
 */
- (void)joinGroupWithGroupId:(NSString *)groupId
          message:(NSString *)message
       completion:(void(^)(QNIMError *error))aCompletionBlock;

```

```
/**
 退出聊天室
 */
- (void)leaveGroupWithGroupId:(NSString *)groupId
        completion:(void(^)(QNIMError *error))aCompletionBlock;

```


```
/**
 获取聊天室信息

 @param groupId  群id
 @param forceRefresh 如果设置了forceRefresh则从服务器拉取
 @param aCompletionBlock 群
 */
- (void)getGroupInfoByGroupId:(long long)groupId
                 forceRefresh:(BOOL)forceRefresh
                   completion:(void(^)(QNIMGroup *group,
                                       QNIMError *error))aCompletionBlock;

```


```
/**
 创建群

 @param option QNIMCreatGroupOption
 @param aCompletionBlock Group info ,Error
 */
- (void)creatGroupWithCreateGroupOption:(QNIMCreatGroupOption *)option
                             completion:(void(^)(QNIMGroup *group,
                                                 QNIMError *error))aCompletionBlock;

```

## 群监听  QNIMGroupServiceProtocol

```
/**
 退出了某群
 */
- (void)groupLeft:(QNIMGroup *)group reason:(NSString *)reason;

/**
 * 加入新成员
 **/
- (void)groupMemberJoined:(QNIMGroup *)group
                 memberId:(NSInteger)memberId
                  inviter:(NSInteger)inviter;
                  
/**
 * 群成员退出
 **/
- (void)groupMemberLeft:(QNIMGroup *)group
               memberId:(NSInteger)memberId
                reason:(NSString *)reason;

```


## 消息实体

```

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
                        
```

## 聊天 QNIMChatService

```

/**
 发送消息，消息状态变化会通过listener通知
 **/
- (void)sendMessage:(QNIMMessageObject *)message;

/**
 * 读取一条消息
 **/
- (void)getMessage:(NSInteger)messageId
        completion:(void(^)(QNIMMessageObject *message, QNIMError *error))aCompletionBlock;
        
/**
 重新发送消息，消息状态变化会通过listener通知
 **/
- (void)resendMessage:(QNIMMessageObject *)message
           completion:(void(^)(QNIMMessageObject *message, QNIMError *error))aCompletionBlock;

/**
 撤回消息，消息状态变化会通过listener通知
 **/
- (void)recallMessage:(QNIMMessageObject *)message
           completion:(void(^)(QNIMMessageObject *message, QNIMError *error))aCompletionBlock;

/**
 * 发送已读回执
 **/
- (void)ackMessage:(QNIMMessageObject *)message;

/**
 * 标记此消息为未读，该消息同步到当前用户的所有设备
 **/
- (void)readCancel:(QNIMMessageObject *)message;

/**
 * 标记此消息及之前全部消息为已读，该消息同步到当前用户的所有设备
 **/
- (void)readAllMessage:(QNIMMessageObject *)message;

/**
 * 插入消息
 **/

- (void)insetMessages:(NSArray<QNIMMessageObject *> *)list
            completion:(void(^)(QNIMError *error))aCompletionBlock;

```

## 聊天监听  QNIMChatServiceProtocol

```

/**
 * 消息发送状态发生变化
 **/
- (void)messageStatusChanged:(QNIMMessageObject *)message
            error:(QNIMError *)error;

/**
 * 收到消息
 **/
- (void)receivedMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 附件上传进度发送变化
 **/
- (void)messageAttachmentUploadProgressChanged:(QNIMMessageObject *)message
                                percent:(int)percent;

/**
 * 消息撤回状态发送变化
 **/
- (void)messageRecallStatusDidChanged:(QNIMMessageObject *)message
                      error:(QNIMError *)error;

/**
 * 收到命令消息
 **/
- (void)receivedCommandMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到系统通知消息
 **/
- (void)receivedSystemMessages:(NSArray<QNIMMessageObject*> *)messages;


/**
 * 收到消息已读回执
 **/
- (void)receivedReadAcks:(NSArray<QNIMMessageObject*> *)messages;


/**
 * 收到消息已送达回执
 **/
- (void)receivedDeliverAcks:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到撤回消息
 **/
- (void)receivedRecallMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到消息已读取消（多设备其他设备同步消息已读状态变为未读）
 **/
- (void)receiveReadCancelsMessages:(NSArray<QNIMMessageObject*> *)messages;

/**
 * 收到消息全部已读（多设备同步某消息之前消息全部设置为已读）
 **/
- (void)receiveReadAllMessages:(NSArray<QNIMMessageObject*> *)messages;


```

## 会话 QNIMConversation

```

/**
 会话Id
 */
@property (nonatomic,assign, readonly) long long conversationId;

/**
 会话类型
 */
@property (nonatomic,assign, readonly) QNIMConversationType type;

/**
 最新消息
 */
@property (nonatomic, strong, readonly) QNIMMessageObject *lastMessage;

/**
 未读消息数量
 */
@property (nonatomic,assign, readonly) NSInteger unreadNumber;

/**
 会话中所有消息数量
 */
@property (nonatomic,assign, readonly) NSInteger messageCount;


/**
 是否提醒用户消息,不提醒的情况下会话总未读数不会统计该会话计数。
 */
@property (nonatomic,assign) BOOL isMuteNotication;

/**
 扩展信息
 */
@property (nonatomic,copy) NSString *extensionJson;

/**
 * 编辑消息
 **/
@property (nonatomic,copy) NSString *editMessage;


/**
 设置消息播放状态（只对语音/视频消息有效）

 @param message message
 @param status 播放状态
 @param aCompletionBlock Result
 */
- (void)setMessagePlayedStatus:(QNIMMessageObject *)message
                        status:(bool)status
                    completion:(void (^)(QNIMMessageObject *aMessage, QNIMError *error))aCompletionBlock;

/**
 设置消息未读状态，更新未读消息数, 本地

 @param message message
 @param status 是否已读
 @param aCompletionBlock Result
 */
- (void)setMessageReadStatus:(QNIMMessageObject *)message
                              status:(BOOL)status
                  completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 把所有消息设置为已读，更新未读消息数
 */
- (void)setAllMessagesReadCompletion:(void(^)(QNIMError *error))aCompletionBlock;


/// 更新一条数据库存储消息的扩展字段信息
/// @param message 需要更改扩展信息的消息此时msg部分已经更新扩展字椴信息
/// @param aCompletionBlock 更新结果
- (void)updateMessageExtension:(QNIMMessageObject *)message
                    completion:(void(^)(QNIMError *error))aCompletionBlock;
/**
 插入一条消息

 @param msg message
 @param aCompletionBlock Result
 */
- (void)insertMessage:(QNIMMessageObject *)msg
           completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 读取一条消息

 @param msgId msgId
 @param aCompletionBlock Result
 */
- (void)loadMessage:(long long)msgId
completion:(void(^)(QNIMMessageObject *message))aCompletionBlock;



/**
 删除会话中的所有消息

 @param aCompletionBlock Result
 */
- (void)removeAllMessagescompletion:(void(^)(QNIMError *error))aCompletionBlock;


/**
 加载消息，从参考消息向前加载，如果不指定则从最新消息开始

 @param reMsgId 参考消息Id
 @param size size
 @param aCompletionBlock Result：MessageList
 */
- (void)loadMessageFromMessageId:(long long)reMsgId
                            size:(NSUInteger)size
                      completion:(void(^)(NSArray*messageList,
                                          QNIMError *error))aCompletionBlock;

/**
 * 搜索消息，如果不指定则从最新消息开始
 **/
- (void)searchMessagesByKeyWords:(NSString *)keywords
               refTime:(NSTimeInterval)refTime
                  size:(NSUInteger)size
         directionType:(QNIMMessageDirection)directionType
            completion:(void (^)(NSArray <QNIMMessageObject *>*messageList, QNIMError *error))aCompletionBlock;

/**
 * 按照类型搜索消息，如果不指定则从最新消息开始
 **/
- (void)searchMessagesBycontentType:(QNIMContentType)contentType
                            refTime:(NSTimeInterval)refTime
                               size:(NSUInteger)size
                      directionType:(QNIMMessageDirection)directionType
                         completion:(void (^)(NSArray <QNIMMessageObject *>*messageList, QNIMError *error))aCompletionBlock;

```
