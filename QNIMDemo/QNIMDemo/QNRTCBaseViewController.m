//
//  QNRTCBaseViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import "QNRTCBaseViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <QNRTCKit/QNRTCKit.h>
#import <Masonry.h>
#import "QNRoomUserView.h"
#import <YYCategories/YYCategories.h>
#import "MBProgressHUD+QNShow.h"

@interface QNRTCBaseViewController ()

@property (nonatomic, strong) NSMutableArray *logStringArray;
@property (nonatomic, strong) UIScrollView *contentBgView;//承载renderBackgroundView滑动
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只添加 renderView
@property (nonatomic, strong) NSMutableArray *userViewArray;
@property (nonatomic, strong) NSMutableDictionary *trackInfoDics;

@end

@implementation QNRTCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.logStringArray = [[NSMutableArray alloc] init];
    self.userViewArray = [[NSMutableArray alloc] init];
    self.trackInfoDics = [[NSMutableDictionary alloc] init];
    self.renderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view insertSubview:self.renderBackgroundView atIndex:0];
    
}

#pragma mark - 预览画面设置

- (void)resetRenderViews {
    @synchronized (self) {
        
        NSArray<QNRoomUserView *> *allRenderView = self.renderBackgroundView.subviews;
        
        if (1 == allRenderView.count) {
            [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
        } else if (2 == allRenderView.count) {
            QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackId];
            removeCameraView.showNameLabel = NO;
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(70);
                make.width.equalTo(@120);
                make.height.equalTo(@200);
            }];
            
            [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
        }else if (3 == allRenderView.count) {

            //对方屏幕分享
            QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackId];
            removeScreenView.showNameLabel = NO;
            //添加左滑手势
            UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe)];
            [leftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
            removeScreenView.userInteractionEnabled = YES;
            [removeScreenView addGestureRecognizer:leftRecognizer];
            [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            //自己的视图
            [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(70);
                make.width.equalTo(@120);
                make.height.equalTo(@200);
            }];
            
            //对方视图
            QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackId];
            removeCameraView.showNameLabel = NO;
            //添加右滑手势
            UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe)];
            [rightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
            removeCameraView.userInteractionEnabled = YES;
            [removeCameraView addGestureRecognizer:rightRecognizer];
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
            
        }
        
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)addRenderViewToSuperView:(QNRoomUserView *)renderView {
    @synchronized(self.renderBackgroundView) {
        if (![[self.renderBackgroundView subviews] containsObject:renderView]) {
            [self.renderBackgroundView addSubview:renderView];
            
            [self resetRenderViews];
        }
    }
}

- (void)removeRenderViewFromSuperView:(QNRoomUserView *)renderView {
    @synchronized(self.renderBackgroundView) {
        if ([[self.renderBackgroundView subviews] containsObject:renderView]) {
            [renderView removeFromSuperview];
            
            [self resetRenderViews];
        }
    }
}

- (QNRoomUserView *)createUserViewWithTrackId:(NSString *)trackId userId:(NSString *)userId {
    QNRoomUserView *userView = [[QNRoomUserView alloc] init];
    userView.userId = userId;
    userView.trackId = trackId;
    return userView;
}

- (QNRoomUserView *)userViewWithTrackId:(NSString *)trackId {
    @synchronized(self.userViewArray) {
        for (QNRoomUserView *userView in self.userViewArray) {
            if ([userView.trackId isEqualToString:trackId]) {
                return userView;
            }
        }
    }
    return nil;
}

/**
 * SDK 运行过程中发生错误会通过该方法回调，具体错误码的含义可以见 QNTypeDefines.h 文件
 */
- (void)RTCEngine:(QNRTCEngine *)engine didFailWithError:(NSError *)error {

    dispatch_async(dispatch_get_main_queue(), ^{
        switch (error.code) {
            case QNRTCErrorAuthFailed:
                [MBProgressHUD showText:@"鉴权失败，请检查鉴权"];
                break;
            case QNRTCErrorRoomIsFull:
                [MBProgressHUD showText:@"房间人数已满"];
                break;
            case QNRTCErrorTokenError:
                //关于 token 签算规则, 详情请参考【服务端开发说明.RoomToken 签发服务】https://doc.qnsdk.com/rtn/docs/server_overview#1
                [MBProgressHUD showText:@"roomToken 错误"];
                break;
            case QNRTCErrorTokenExpired:
                [MBProgressHUD showText:@"roomToken 过期"];
                break;
            case QNRTCErrorUserAlreadyExist:
                [MBProgressHUD showText:@"用户已存在"];
                break;
            case QNRTCErrorNoPermission:
                [MBProgressHUD showText:@"请检查用户是否有权限，如:合流"];
                break;
            case QNRTCErrorReconnectTokenError:
                [MBProgressHUD showText:@"重新进入房间超时，请务必调用 leaveRoom, 重新进入房间"];
                break;
            case QNRTCErrorPublishFailed:
                [MBProgressHUD showText:@"发布失败，请查看是否加入房间，并确定对于音频/视频 Track，分别最多只能有一路为 master"];
                break;
            case QNRTCErrorInvalidParameter:
                [MBProgressHUD showText:@"服务交互参数错误，请在开发时注意合流、踢人动作等参数的设置"];
                break;
            case QNRTCErrorRoomClosed:
                [MBProgressHUD showText:@"房间已被管理员关闭"];
                break;
                
            default:
                break;
        }
    });
}

/**
 * 房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可
 */
- (void)RTCEngine:(QNRTCEngine *)engine roomStateDidChange:(QNRoomState)roomState {
    
    NSDictionary *roomStateDictionary =  @{
                                           @(QNRoomStateIdle) : @"Idle",
                                           @(QNRoomStateConnecting) : @"Connecting",
                                           @(QNRoomStateConnected): @"Connected",
                                           @(QNRoomStateReconnecting) : @"Reconnecting",
                                           @(QNRoomStateReconnected) : @"Reconnected"
                                           };
    NSString *str = [NSString stringWithFormat:@"房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可:\nroomState: %@",  roomStateDictionary[@(roomState)]];
    NSLog(@"%@",str);
}

/**
 * 本地音视频发布到服务器的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishLocalTracks:(NSArray<QNTrackInfo *> *)tracks {
    NSString *str = [NSString stringWithFormat:@"本地 Track 发布到服务器的回调:\n%@", tracks];
    NSLog(@"%@",str);
}

/**
 * 远端用户加入房间的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didJoinOfRemoteUserId:(NSString *)userId userData:(NSString *)userData {
    NSString *str = [NSString stringWithFormat:@"远端用户加入房间的回调:\nuserId: %@, userData: %@",  userId, userData];
    NSLog(@"%@",str);
}

/**
 * 远端用户离开房间的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didLeaveOfRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 离开房间的回调", userId];
    NSLog(@"%@",str);
    
    [self clearUserInfo:userId];
}

/**
 * 订阅远端用户成功的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didSubscribeTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"订阅远端用户: %@ 成功的回调:\nTracks: %@", userId, tracks];
    NSLog(@"%@",str);
}

/**
 * 远端用户发布音/视频的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 发布成功的回调:\nTracks: %@",  userId, tracks];
    NSLog(@"%@",str);
}

/**
 * 远端用户取消发布音/视频的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didUnPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 取消发布的回调:\nTracks: %@",  userId, tracks];
    NSLog(@"%@",str);
}

/**
* 创建合流的回调
*/
- (void)RTCEngine:(QNRTCEngine *)engine didCreateMergeStreamWithJobId:(NSString *)jobId {
    NSString *str = [NSString stringWithFormat:@"创建合流的回调:\nJobId: %@",  jobId];
    NSLog(@"%@",str);
}

/**
 * 被 userId 踢出的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didKickoutByUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"被远端用户: %@ 踢出的回调",  userId];
    NSLog(@"%@",str);
}

/**
 * 远端用户音频状态变更为 muted 的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didAudioMuted:(BOOL)muted ofTrackId:(NSString *)trackId byRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 音频状态变更为: %d 的回调",  userId, trackId, muted];
    NSLog(@"%@",str);
}

/**
 * 远端用户视频状态变更为 muted 的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didVideoMuted:(BOOL)muted ofTrackId:(NSString *)trackId byRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 视频状态变更为: %d 的回调",  userId, trackId, muted];
    NSLog(@"%@",str);
}

/**
 * 远端用户视频首帧解码后的回调，如果需要渲染，则需要返回一个带 renderView 的 QNVideoRender 对象
 */
- (QNVideoRender *)RTCEngine:(QNRTCEngine *)engine firstVideoDidDecodeOfTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 视频首帧解码后的回调",  userId, trackId];
    NSLog(@"%@",str);

    return nil;
}

/**
 * 远端用户视频取消渲染到 renderView 上的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didDetachRenderView:(UIView *)renderView ofTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 视频取消渲染到 renderView 上的回调",  userId, trackId];
    NSLog(@"%@",str);
}

/**
 * 远端用户视频数据的回调
 *
 * 注意：回调远端用户视频数据会带来一定的性能消耗，如果没有相关需求，请不要实现该回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didGetPixelBuffer:(CVPixelBufferRef)pixelBuffer ofTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
    static int i = 0;
    if (i % 300 == 0) {
        NSString *str = [NSString stringWithFormat:@"远端用户视频数据的回调:\nuserId: %@ size: %zux%zu", userId, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer)];
        //        [self addLogString:str];
        NSLog(@"%@",str);
    }
    i ++;
    
}

/**
 * 远端用户音频数据的回调
 *
 * 注意：回调远端用户音频数据会带来一定的性能消耗，如果没有相关需求，请不要实现该回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine
didGetAudioBuffer:(AudioBuffer *)audioBuffer
    bitsPerSample:(NSUInteger)bitsPerSample
       sampleRate:(NSUInteger)sampleRate
        ofTrackId:(NSString *)trackId
     remoteUserId:(NSString *)userId {
    static int i = 0;
    if (i % 500 == 0) {
        NSString *str = [NSString stringWithFormat:@"远端用户音频数据的回调:\nuserId: %@\nbufferCount: %d\nbitsPerSample:%lu\nsampleRate:%lu,dataLen = %u",  userId, i, (unsigned long)bitsPerSample, (unsigned long)sampleRate, (unsigned int)audioBuffer->mDataByteSize];
        NSLog(@"%@",str);
    }
    i ++;
}

/**
 * 获取到摄像头原数据时的回调, 便于开发者做滤镜等处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致编码帧率下降
 */
- (void)RTCEngine:(QNRTCEngine *)engine cameraSourceDidGetSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    static int i = 0;
    if (i % 300 == 0) {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        NSString *str = [NSString stringWithFormat:@"获取到摄像头原数据时的回调:\nbufferCount: %d, size = %zux%zu",  i, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer)];
        NSLog(@"%@",str);
    }
    i ++;
}

/**
 * 获取到麦克风原数据时的回调，需要注意的是这个回调在 AU Remote IO 线程，请不要做过于耗时的操作，否则可能阻塞该线程影响音频输出或其他未知问题
 */
- (void)RTCEngine:(QNRTCEngine *)engine microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer {
    static int i = 0;
    if (i % 500 == 0) {
        NSString *str = [NSString stringWithFormat:@"获取到麦克风原数据时的回调:\nbufferCount: %d, dataLen = %u",  i, (unsigned int)audioBuffer->mDataByteSize];
        NSLog(@"%@",str);
    }
    i ++;
}

/**
 *统计信息回调，回调的时间间隔由 statisticInterval 参数决定，statisticInterval 默认为 0，即不回调统计信息
 */
- (void)RTCEngine:(QNRTCEngine *)engine
  didGetStatistic:(NSDictionary *)statistic
        ofTrackId:(NSString *)trackId
           userId:(NSString *)userId {
    NSString *str = nil;
    if (statistic[QNStatisticAudioBitrateKey] && statistic[QNStatisticAudioPacketLossRateKey]) {
        int audioBitrate = [[statistic objectForKey:QNStatisticAudioBitrateKey] intValue];
        float audioPacketLossRate = [[statistic objectForKey:QNStatisticAudioPacketLossRateKey] floatValue];
        int audioRtt = [[statistic objectForKey:QNStatisticRttKey] floatValue];
        if ([self.userId isEqualToString:userId]) {
            str = [NSString stringWithFormat:@"音频码率：%dbps\n 音频丢包率：%3.1f%%\n本地 rtt：%d\n", audioBitrate, audioPacketLossRate,audioRtt];
        }else{
            int audioRemotePacketLossRate = [[statistic objectForKey:QNStatisticAudioRemotePacketLossRateKey] floatValue];
            str = [NSString stringWithFormat:@"音频码率：%dbps\n 远端服务器音频丢包率：%3.1f%%\n远端user音频丢包率：%3.1f%%\n远端 rtt：%d\n", audioBitrate, audioPacketLossRate,audioRemotePacketLossRate,audioRtt];
        }
    }
    else {
        int videoBitrate = [[statistic objectForKey:QNStatisticVideoBitrateKey] intValue];
        float videoPacketLossRate = [[statistic objectForKey:QNStatisticVideoPacketLossRateKey] floatValue];
        int videoFrameRateKey = [[statistic objectForKey:QNStatisticVideoFrameRateKey] intValue];
        int videoRtt = [[statistic objectForKey:QNStatisticRttKey] floatValue];
        if ([self.userId isEqualToString:userId]) {
            str = [NSString stringWithFormat:@"视频码率：%dbps\n 本地视频丢包率：%3.1f%%\n视频帧率：%d\n本地 rtt：%d\n", videoBitrate, videoPacketLossRate, videoFrameRateKey,videoRtt];
        }else{
            int videoRemotePacketLossRate = [[statistic objectForKey:QNStatisticVideoRemotePacketLossRateKey] floatValue];
            str = [NSString stringWithFormat:@"视频码率：%dbps\n 远端服务器视频丢包率：%3.1f%%\n视频帧率：%d\n远端user视频丢包率：%3.1f%%\n远端 rtt：%d\n", videoBitrate, videoPacketLossRate, videoFrameRateKey,videoRemotePacketLossRate,videoRtt];
        }
    }
    NSString *logStr = [NSString stringWithFormat:@"统计信息回调:userId: %@ trackId: %@\n%@", userId, trackId, str];
    NSLog(@"%@",logStr);
}

/**
 *本地用户离开房间的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didLeaveOfLocalSuccess:(BOOL)success {
    NSString *logStr = [NSString stringWithFormat:@"本地用户离开房间 success %d", success];
    NSLog(@"%@",logStr);
}

/**
 *单路转推创建成功的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didCreateForwardJobWithJobId:(nonnull NSString *)jobId {
    NSString *logStr = [NSString stringWithFormat:@"单路转推任务 jobId: %@", jobId];
    NSLog(@"%@",logStr);
}

/**
* 远端用户发生重连
*/
- (void)RTCEngine:(QNRTCEngine *)engine didReconnectingRemoteUserId:(NSString *)userId {
    NSString *logStr = [NSString stringWithFormat:@"userId 为 %@ 的远端用户发生了重连！", userId];
    NSLog(@"%@",logStr);
}

/**
* 远端用户重连成功
*/
- (void)RTCEngine:(QNRTCEngine *)engine didReconnectedRemoteUserId:(NSString *)userId {
    NSString *logStr = [NSString stringWithFormat:@"userId 为 %@ 的远端用户重连成功了！", userId];
    NSLog(@"%@",logStr);
}


@end
