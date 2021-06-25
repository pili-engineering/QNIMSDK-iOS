//
//  QNIMGroupServiceProtocol.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/7.
//

#import <Foundation/Foundation.h>
#import "QNIMGroup.h"

@protocol QNIMGroupServiceProtocol <NSObject>

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

@end

