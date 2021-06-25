//
//  QNIMGroupOption.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/15.
//

#import <Foundation/Foundation.h>
#import "QNIMGroupServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class QNIMGroup,QNIMError;

@interface QNIMGroupOption : NSObject

- (void)addDelegate:(id<QNIMGroupServiceProtocol>)aDelegate;

+ (instancetype)sharedOption;

/**
 加入聊天室
 */
- (void)joinGroupWithGroupId:(NSString *)groupId completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
 退出聊天室
 */
- (void)leaveGroupWithGroupId:(NSString *)groupId
        completion:(void(^)(QNIMError *error))aCompletionBlock;

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


@end

NS_ASSUME_NONNULL_END
