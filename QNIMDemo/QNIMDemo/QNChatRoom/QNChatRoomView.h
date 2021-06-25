//
//  QNChatRoomView.h
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/3.
//

#import <UIKit/UIKit.h>
#import "QNInputBarControl.h"
#import <QNIMSDK/QNIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@protocol QNChatRoomViewDelegate <NSObject>

//-(void)didReceiveQuitMessageWithMessageModel:(QNMessageModel *)model;
//
//-(void)didReceiveMessageUserBackground:(RCChatroomSignal *)model;
//
//- (void)didReceiveIMSignalMessage:(RCTextMessage *)message;

@end

@interface QNChatRoomView : UIView

@property(nonatomic, weak) id<QNChatRoomViewDelegate> delegate;

@property (nonatomic,assign) long long conversationId;//会话ID
/*!
 消息列表CollectionView和输入框都在这个view里
 */
@property(nonatomic, strong) UIView *messageContentView;

/*!
 会话页面的CollectionView
 */
@property(nonatomic, strong) UICollectionView *conversationMessageCollectionView;

/**
 输入工具栏
 */
@property(nonatomic,strong) QNInputBarControl *inputBar;



/**
 底部按钮容器，底部的四个按钮都添加在此view上
 */
@property(nonatomic, strong) UIView *bottomBtnContentView;

/**
 *  评论按钮
 */
@property(nonatomic,strong)UIButton *commentBtn;


// 自定义事件按钮
@property (nonatomic, strong) UIButton *closeButton;


- (void)sendMessage:(QNIMMessageObject *)messageContent;

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages;

- (void)alertErrorWithTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setDefaultBottomViewStatus;


@end

NS_ASSUME_NONNULL_END
