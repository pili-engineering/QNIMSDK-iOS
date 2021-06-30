//
//  QNIMClient.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "QNIMUserProfile.h"
#import "QNIMError.h"
#import "QNSDKConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QNIMNetworkType) {
    QNIMNetworkTypeMobile,
    QNIMNetworkTypeWifi,
    QNIMNetworkTypeCable,
    QNIMNetworkTypeNone
};

typedef NS_ENUM(NSUInteger, QNIMConnectStatus) {
    QNIMConnectStatusDisconnected,
    QNIMConnectStatusConnected,
};

typedef NS_ENUM(NSUInteger, QNIMSignInStatus) {
    QNIMSignInStatusSignOut,
    QNIMSignInStatusSignIn,
};

typedef NS_ENUM(NSUInteger, QNIMLogLevel) {
    QNIMLogLevelError,
    QNIMLogLevelWarning,
    QNIMLogLevelDebug,
};

@class QNSDKConfig;

@interface QNIMClient : NSObject

+ (instancetype)sharedClient;

@property (nonatomic, strong) QNSDKConfig *sdkConfig;
//当前用户uid
@property (nonatomic, copy) NSString *uid;
//当前用户userName
@property (nonatomic, copy) NSString *userName;

- (void)registerWithSDKConfig:(QNSDKConfig *)config;

+ (NSString *)getCacheDir;

/**
 * 通过用户Id登录
 **/
- (void)signInByUserId:(NSString *)userId completion:(void (^)(QNIMError * _Nonnull qnImError))aCompletionBlock ;
/**
 * 获取RTC房间对应的聊天室ID
 **/
- (void)getGroupIdWithRoomId:(NSString *)roomId completion:(void(^)(NSString * groupId))completion ;
/**
 * 获取当前的登录状态
 **/
- (QNIMSignInStatus)signInStatus;

/**
 * 获取当前和服务器的连接状态
 **/
- (QNIMConnectStatus)connectStatus;

/**
 处理网络状态发送变化
 
 @param type 变化后的网络类型
 @param reconnect 网络是否需要重连
 */
- (void)networkDidChangedType:(QNIMNetworkType)type reconnect:(BOOL)reconnect;

/**
 强制重新连接
 */
- (void)reconnect;

/**
 断开网络连接
 */
- (void)disConnect;

/**
 更改SDK的appId，本操作会同时更新QNIMConfig中的appId。
 
 @param appID  新变更的appId
 */
- (void)changeAppID:(NSString *)appID
         completion:(void (^)(QNIMError *error))aCompletionBlock;

/**
 获取app的服务器网络配置，在初始化SDK之后登陆之前调用，可以提前获取服务器配置加快登陆速度。

 @param isLocal 为true则使用本地缓存的dns配置，为false则从服务器获取最新的配置。
 */
- (void)initializeServerConfig:(BOOL)isLocal;

@end

NS_ASSUME_NONNULL_END
