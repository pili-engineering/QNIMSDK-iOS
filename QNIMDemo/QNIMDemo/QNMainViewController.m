//
//  QNMainViewController.m
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/17.
//

#import "QNMainViewController.h"
#import <QNRTCKit/QNRTCKit.h>
#import <YYCategories/YYCategories.h>
#import "MBProgressHUD+QNShow.h"
#import "QNRoomUserView.h"
#import "QNNetworkUtil.h"
#import <QNIMSDK/QNIMSDK.h>
#import "QNChatRoomView.h"

@interface QNMainViewController ()<QNChatRoomViewDelegate,UIGestureRecognizerDelegate,QNIMChatServiceProtocol>

@property (nonatomic, strong) QNChatRoomView *chatRoomView;

@property (nonatomic, strong) UIButton *commentButton;

@end

@implementation QNMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[QNIMChatOption sharedOption] addDelegate:self];
    [self configureRTCEngine];
    [self setupButtons];
    [self setupChatView];
    [self joinChatRoom];
    
}

- (void)setupButtons {
    
    NSMutableArray *imageNames = [NSMutableArray arrayWithObjects:@"icon_quit",@"icon_chat", nil];
    NSMutableArray *selectors = [NSMutableArray arrayWithObjects:@"leaveRTCRoom",@"comment", nil];
    
    for (int i = 0; i < imageNames.count; i ++) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:imageNames[i]] forState:(UIControlStateNormal)];
        [button addTarget:self action:NSSelectorFromString(selectors[i]) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:button];
        
        if (i == 0) {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(40);
                make.left.equalTo(self.view).offset(30);
            }];
        } else {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(40);
                make.right.equalTo(self.view).offset(-30);
            }];
        }
        
    }
}

//点击评论
- (void)comment {
    UITapGestureRecognizer *resetBottomTapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetBottomGesture:)];
    resetBottomTapGesture.delegate = self;
    [self.view addGestureRecognizer:resetBottomTapGesture];
    [self.chatRoomView.inputBar setHidden:NO];
    [self.chatRoomView.inputBar  setInputBarStatus:QNBottomBarStatusKeyboard];
    
}

- (void)leaveRTCRoom {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.engine leaveRoom];
    [self leaveChatRoom];
}

- (void)resetBottomGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatRoomView setDefaultBottomViewStatus];
        [self.view removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)setupChatView {
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }

    self.chatRoomView = [[QNChatRoomView alloc] initWithFrame:CGRectMake(0, kScreenHeight - (237 +50)  - bottomExtraDistance, kScreenWidth, 237+50)];
    self.chatRoomView.delegate = self;
    
    self.chatRoomView.commentBtn = self.commentButton;
    [self.view insertSubview:self.chatRoomView atIndex:2];
    
}

- (void)configureRTCEngine {
    self.engine = [[QNRTCEngine alloc] init];
    self.engine.delegate = self;
    self.engine.sessionPreset = AVCaptureSessionPreset1280x720;
    self.engine.videoFrameRate = 25;
    [self.engine setBeautifyModeOn:YES];
    self.engine.encodeMirrorFrontFacing = YES;
    [self.renderBackgroundView addSubview:self.engine.previewView];
    [self.engine.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.engine startCapture];
    
    [self.engine joinRoomWithToken:self.roomToken];
    
}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    [self.chatRoomView receivedMessages:messages];
}

- (void)messageStatusChanged:(QNIMMessageObject *)message error:(QNIMError *)error {
    
}

//加入聊天室
- (void)joinChatRoom {
    
    NSLog(@"登录状态：%ld",[QNIMClient sharedClient].signInStatus);

    [[QNIMGroupOption sharedOption] joinGroupWithGroupId:self.groupId completion:^(QNIMError * _Nonnull error) {
        if (error) {
            NSLog(@"❌join group errorCode : %ld \n errorMessage : %@",error.errorCode,error.errorMessage);
        }
            self.chatRoomView.conversationId = self.groupId.longLongValue;
            [self sendJoinMessage];
        
    }];
  
}

//退出聊天室
- (void)leaveChatRoom {
    
    [[QNIMGroupOption sharedOption] leaveGroupWithGroupId:self.groupId completion:^(QNIMError * _Nonnull error) {
        if (error) {
            NSLog(@"❌leave group errorCode : %ld \n errorMessage : %@",error.errorCode,error.errorMessage);
        }
    }];
    
}

//发送加入房间消息
- (void)sendJoinMessage {
    NSString *imUserId = [QNIMClient sharedClient].uid;
    QNIMMessageObject *messageModel = [[QNIMMessageObject alloc]initWithQNIMMessageText:@"加入了房间" fromId:imUserId.longLongValue toId:self.groupId.longLongValue type:QNIMMessageTypeGroup conversationId:self.groupId.longLongValue];

    [self.chatRoomView sendMessage:messageModel];
    
}

#pragma mark - QNRTCEngineDelegate 代理回调

/*房间内状态变化的回调*/
- (void)RTCEngine:(QNRTCEngine *)engine roomStateDidChange:(QNRoomState)roomState {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (QNRoomStateConnected == roomState) {
            // 音频
            QNTrackInfo *audioTrack = [[QNTrackInfo alloc] initWithSourceType:QNRTCSourceTypeAudio master:YES];
            // 视频
            QNTrackInfo *cameraTrack = [[QNTrackInfo alloc] initWithSourceType:QNRTCSourceTypeCamera tag:@"" master:YES bitrateBps:400*1000 videoEncodeSize:CGSizeMake(480, 640)];
            // 发布音视频
            [self.engine publishTracks:@[audioTrack, cameraTrack]];
                                                            
        } else if (QNRoomStateReconnecting == roomState) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showText:@"正在重新连接..."];
            });
        }  else if (QNRoomStateReconnected == roomState) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showText:@"重新连接成功"];
            });
        }

    });
}

/* 发布本地音/视频成功的回调 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishLocalTracks:(NSArray<QNTrackInfo *> *)tracks {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (QNTrackInfo *trackInfo in tracks) {
            
            if (trackInfo.kind == QNTrackKindAudio) {
                self.audioTrackInfo = trackInfo;
            }
            
            if (trackInfo.kind == QNTrackKindVideo) {
                self.cameraTrackInfo = trackInfo;
            }
        }
    });
    
}

/* 远端用户发布音/视频的回调*/
- (void)RTCEngine:(QNRTCEngine *)engine didPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    
    dispatch_async(dispatch_get_main_queue(), ^{
                
        for (QNTrackInfo *trackInfo in tracks) {
            
            QNRoomUserView *userView = [self userViewWithTrackId:trackInfo.trackId];
            QNTrackInfo *tempInfo = [userView trackInfoWithTrackId:trackInfo.trackId];
                        
            if (trackInfo.kind == QNTrackKindAudio) {
                self.remoteAudioTrack = trackInfo;
            }
            
            if (trackInfo.kind == QNTrackKindVideo) {
                
                self.remoteCameraTrack = trackInfo;
                
                if (!userView) {
                    userView = [self createUserViewWithTrackId:trackInfo.trackId userId:userId];
                    userView.showImageView = NO;
                    __weak typeof(self) weakSelf = self;
                    userView.changeSizeBlock = ^{
                        [weakSelf exchangeWindowSize];
                    };
                    [self.userViewArray addObject:userView];
                }
            }
            if (nil == userView.superview) {
                [self addRenderViewToSuperView:userView];
            }
            
            if (tempInfo) {
                [userView.traks removeObject:tempInfo];
            }
            [userView.traks addObject:trackInfo];
            [userView showCameraView];
        }
    });
}

/* 远端用户视频状态变更的回调 */
- (void)RTCEngine:(QNRTCEngine *)engine didVideoMuted:(BOOL)muted ofTrackId:(nonnull NSString *)trackId byRemoteUserId:(nonnull NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        QNRoomUserView *userView = [self userViewWithTrackId:trackId];
        userView.showImageView = muted;
    });
}

/* 被踢出房间的回调 */
- (void)RTCEngine:(QNRTCEngine *)engine didKickoutByUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

/* 远端用户取消发布音/视频的回调 */
- (void)RTCEngine:(QNRTCEngine *)engine didUnPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (QNTrackInfo *trackInfo in tracks) {
            QNRoomUserView *userView = [self userViewWithTrackId:trackInfo.trackId];
            QNTrackInfo *tempInfo = [userView trackInfoWithTrackId:trackInfo.trackId];
                       
            if (tempInfo) {
                [userView.traks removeObject:tempInfo];
                
                if (0 == userView.traks.count) {
                    [self removeRenderViewFromSuperView:userView];
                }
            }
        }
    });
}

/* 远端用户离开房间的回调 */
- (void)RTCEngine:(QNRTCEngine *)engine didLeaveOfRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
    
}

/* @abstract 远端用户发生重连的回调。*/
- (void)RTCEngine:(QNRTCEngine *)engine didReconnectingRemoteUserId:(NSString *)userId{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showText:@"对方正在重新连接..."];
    });
    
}

/* @abstract 远端用户重连成功的回调。*/
- (void)RTCEngine:(QNRTCEngine *)engine didReconnectedRemoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showText:@"对方已经重新连接"];
    });
}

/* 远端用户首帧解码后的回调（仅在远端用户发布视频时会回调） */
- (QNVideoRender *)RTCEngine:(QNRTCEngine *)engine firstVideoDidDecodeOfTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
    QNRoomUserView *userView = [self userViewWithTrackId:trackId];
    userView.contentMode = UIViewContentModeScaleAspectFit;
    QNVideoRender *render = [[QNVideoRender alloc] init];
    render.renderView = userView.cameraView;
    return render;
}

/*远端用户视频取消渲染到 renderView 上的回调 */
- (void)RTCEngine:(QNRTCEngine *)engine didDetachRenderView:(UIView *)renderView ofTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        QNRoomUserView *userView = [self userViewWithTrackId:trackId];
        if (userView) {
            [self removeRenderViewFromSuperView:userView];
        }
    });
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}


@end
