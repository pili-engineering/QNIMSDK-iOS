//
//  QNIMGroup.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    /// 私有群组
    QNIMGroupTypePrivate,
    /// 公开群组(现在暂时没有开放次类型群组)
    QNIMGroupTypePublic,
    /// 聊天室
    QNIMGroupTypeChatroom,
} QNIMGroupType;

typedef enum {
    /// 群成员
    QNIMGroupMemberRoleTypeMember,
    /// 群管理员
    QNIMGroupMemberRoleTypeAdmin,
    /// 群主
    QNIMGroupMemberRoleTypeOwner,
    /// 非群成员
    QNIMGroupMemberRoleTypeNotGroupMember
} QNIMGroupMemberRoleType;

@interface QNIMGroup : NSObject
/**
 * 群Id
 **/
@property (nonatomic,assign) long long groupId;


@property (nonatomic, assign) QNIMGroupType groupType;

/**
 * 在群里的昵称
 **/
@property (nonatomic,copy) NSString *myNickName;

/**
 * 群名称
 **/
@property (nonatomic, copy, readonly) NSString *name;

/**
 * 群描述
 **/
@property (nonatomic, copy, readonly) NSString *groupDescription;

/**
 * 群头像
 **/
@property (nonatomic,copy, readonly) NSString *avatarUrl;

/**
 * 群头像下载后的本地路径
 **/
@property (nonatomic,copy, readonly) NSString *avatarPath;

/**
 * 群头像缩略图
 **/
@property (nonatomic,copy, readonly) NSString *avatarThumbnailUrl;

/**
 * 群头像缩略图下载后的本地路径
 **/
@property (nonatomic,copy, readonly) NSString *avatarThumbnailPath;

/**
 * 群创建时间
 **/
@property (nonatomic,readonly) long long creatTime;

/**
 * 群扩展信息
 **/
@property (nonatomic, copy, readonly) NSString *jsonextension;
/**
 * 群成员
 **/
@property (nonatomic, assign, readonly) NSInteger ownerId;

/**
 * 最大人数
 **/
@property (nonatomic, assign, readonly) NSInteger capactiy;

/**
 * 群成员数量，包含Owner，admins 和members
 **/
@property (nonatomic, assign, readonly) NSInteger membersCount;

/**
 是否可以加载显示历史聊天记录
 */
@property (nonatomic,assign) BOOL historyVisible;

@property (nonatomic,assign,readonly) BOOL isMember;

@property (nonatomic,assign) QNIMGroupMemberRoleType roleType;

@end

NS_ASSUME_NONNULL_END
