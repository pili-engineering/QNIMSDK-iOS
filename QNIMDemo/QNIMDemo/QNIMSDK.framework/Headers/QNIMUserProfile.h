//
//  QNIMUserProfile.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMUserProfile : NSObject
/**
 用户id
 */
@property (nonatomic,assign) long long userId;

/**
 用户名
 */
@property (nonatomic,copy) NSString *userName;

/**
 昵称
 */
@property (nonatomic,copy) NSString *nickName;

/**
 头像url
 */
@property (nonatomic,copy) NSString *avatarUrl;

/**
 头像本地路径
 */
@property (nonatomic,copy) NSString *avatarPath;

/**
 头像缩略图url
 */
@property (nonatomic,copy) NSString *avatarThumbnailUrl;

/**
 头像缩略图本地路径
 */
@property (nonatomic,copy) NSString *avatarThumbnailPath;

/**
 手机号
 */
@property (nonatomic,copy) NSString *mobilePhone;

/**
  用户邮箱
 */
@property (nonatomic,copy) NSString *email;

/**
 公开信息
 */
@property (nonatomic,copy) NSString *publicInfoJson;

/**
 私密信息
 */
@property (nonatomic,copy) NSString *privateInfoJson;

/**
 自动接收群邀请
 */
@property (nonatomic,assign) BOOL isAutoAcceptGroupInvite;

@end

NS_ASSUME_NONNULL_END
