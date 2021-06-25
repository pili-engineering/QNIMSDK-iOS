//
//  QNRTCBaseViewController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRoomUserView;
@interface QNRTCBaseViewController : UIViewController
<
QNRTCEngineDelegate
>
@property (nonatomic, readonly) NSMutableArray *logStringArray;
@property (nonatomic, readonly) UIView *renderBackgroundView;//上面只能添加 renderView，不然会影响布局
@property (nonatomic, readonly) NSMutableArray *userViewArray;

@property (nonatomic, strong) QNRTCEngine *engine;
@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *appId;
@property (nonatomic, readonly) NSString *roomName;
@property (nonatomic, readonly) BOOL isAdmin;
@property (nonatomic, strong) QNTrackInfo *screenTrackInfo;
@property (nonatomic, strong) QNTrackInfo *cameraTrackInfo;
@property (nonatomic, strong) QNTrackInfo *audioTrackInfo;

@property (nonatomic, strong) QNTrackInfo *remoteScreenTrack;
@property (nonatomic, strong) QNTrackInfo *remoteCameraTrack;
@property (nonatomic, strong) QNTrackInfo *remoteAudioTrack;

- (void)resetRenderViews;
- (QNRoomUserView *)createUserViewWithTrackId:(NSString *)trackId userId:(NSString *)userId;
- (QNRoomUserView *)userViewWithTrackId:(NSString *)trackId;
- (void)addRenderViewToSuperView:(QNRoomUserView *)renderView;
- (void)removeRenderViewFromSuperView:(QNRoomUserView *)renderView;

// 用户退出房间的时候，清除掉用户的所有信息
- (void)clearUserInfo:(NSString *)userId;

- (void)clearAllRemoteUserInfo;

- (BOOL)isAdminUser:(NSString *)userId;

// 大小窗口切换
- (void)exchangeWindowSize;

- (void)leftSwipe;

- (void)rightSwipe;

- (void)checkSelfPreviewGesture;
@end

NS_ASSUME_NONNULL_END
