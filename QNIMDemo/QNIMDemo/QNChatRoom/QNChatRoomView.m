//
//  QNChatRoomView.m
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/3.
//

#import "QNChatRoomView.h"
#import "QNTextMessageCell.h"
#import <SDWebImage/SDWebImage.h>
#import <MJExtension/MJExtension.h>
#import "MBProgressHUD+QNShow.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "QNInputBarControl.h"
#import <QNIMSDK/QNIMSDK.h>

#define SCREENSIZE [UIScreen mainScreen].bounds.size

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]

static NSString * const ConversationMessageCollectionViewCell = @"ConversationMessageCollectionViewCell";
/**
 *  文本cell标示
 */
static NSString *const textCellIndentifier = @"textCellIndentifier";

static NSString *const startAndEndCellIndentifier = @"startAndEndCellIndentifier";

static NSString * const banNotifyContent = @"您已被管理员禁言";

@interface QNChatRoomView ()<QNInputBarControlDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

/*!
 聊天内容的消息Cell数据模型的数据源
 
 @discussion 数据源中存放的元素为消息Cell的数据模型，即RCDLiveMessageModel对象。
 */
@property(nonatomic, strong) NSMutableArray<QNIMMessageObject *> *conversationDataRepository;

/**
 *  是否需要滚动到底部
 */
@property(nonatomic, assign) BOOL isNeedScrollToButtom;

/**
 *  滚动条不在底部的时候，接收到消息不滚动到底部，记录未读消息数
 */
@property (nonatomic, assign) NSInteger unreadNewMsgCount;

@end

@implementation QNChatRoomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGSize size = frame.size;
        CGFloat bottomExtraDistance  = 0;
        if (@available(iOS 11.0, *)) {
            bottomExtraDistance = [self getIPhonexExtraBottomHeight];
        }
        //  消息展示界面和输入框
        [self.messageContentView setFrame:CGRectMake(0, 0, size.width, size.height - 50)];
        [self addSubview:self.messageContentView];
        
        [self.messageContentView  addSubview:self.conversationMessageCollectionView];
        [self.conversationMessageCollectionView setFrame:CGRectMake(0, 0, size.width, self.messageContentView.frame.size.height - 50)];
        UICollectionViewFlowLayout *customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        customFlowLayout.minimumLineSpacing = 2;
        customFlowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 0.0f,5.0f, 0.0f);
        customFlowLayout.estimatedItemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 40);
        customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        [self.conversationMessageCollectionView setCollectionViewLayout:customFlowLayout animated:NO completion:nil];
        
        [self.messageContentView  addSubview:self.inputBar];
        [self.inputBar setBackgroundColor: [UIColor whiteColor]];
        [self.inputBar setFrame:CGRectMake(0, self.messageContentView.frame.size.height - 50, size.width , 50)];
        [self.inputBar setHidden:YES];
        
        //  底部按钮
        [self addSubview:self.bottomBtnContentView];
        [self.bottomBtnContentView setFrame:CGRectMake(0, size.height - 56, size.width, 50)];
        [self.bottomBtnContentView setBackgroundColor:[UIColor clearColor]];
               
        [self.commentBtn setFrame:CGRectMake(10, 10, 35, 35)];
        [self.closeButton setFrame:CGRectMake(self.bottomBtnContentView.frame.size.width - 35 - 10, 10, 35, 35)];
//        [self.closeButton setBackgroundColor:QN_COLOR_RGB(0, 0, 0, 0.8)];
        [self.closeButton.layer setCornerRadius:35/2];
        [self.closeButton.layer setMasksToBounds:YES];
        
        [self registerClass:[QNTextMessageCell class]forCellWithReuseIdentifier:textCellIndentifier];
        [self registerClass:[QNTextMessageCell class]forCellWithReuseIdentifier:startAndEndCellIndentifier];
        
        
    }
    return self;
    
}

#pragma mark - views init
/**
 *  注册cell
 *
 *  @param cellClass  cell类型
 *  @param identifier cell标示
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.conversationMessageCollectionView registerClass:cellClass
                               forCellWithReuseIdentifier:identifier];
}


/**
 发言按钮事件
 */
- (void)commentBtnPressed:(id)sender {
    [self.inputBar setHidden:NO];
    [self.inputBar  setInputBarStatus:QNBottomBarStatusKeyboard];
    
}

/**
 *  将消息加入本地数组
 */
- (void)appendAndDisplayMessage:(QNIMMessageObject *)message {
    if (!message) {
        return;
    }
    if ([self appendMessageModel:message]) {
        NSIndexPath *indexPath =
        [NSIndexPath indexPathForItem:self.conversationDataRepository.count - 1
                            inSection:0];
        if ([self.conversationMessageCollectionView numberOfItemsInSection:0] !=
            self.conversationDataRepository.count - 1) {
            return;
        }
        //  view刷新
        [self.conversationMessageCollectionView
         insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        if ([self isAtTheBottomOfTableView] || self.isNeedScrollToButtom) {
            [self scrollToBottomAnimated:YES];
            self.isNeedScrollToButtom=NO;
        }
    }
    return;
}

/**
 *  消息滚动到底部
 *
 *  @param animated 是否开启动画效果
 */
- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.conversationMessageCollectionView numberOfSections] == 0) {
        return;
    }
    NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
    if (0 == finalRow) {
        return;
    }
    NSIndexPath *finalIndexPath =
    [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath
                                                   atScrollPosition:UICollectionViewScrollPositionTop
                                                           animated:animated];
}


/**
 *  如果当前会话没有这个消息id，把消息加入本地数组
 */
- (BOOL)appendMessageModel:(QNIMMessageObject *)model {

    if (!model.content) {
        return NO;
    }
    
    if (self.conversationDataRepository.count > 0) {
        QNIMMessageObject *message = self.conversationDataRepository.firstObject;
        if (message.msgId == model.msgId) {
            return YES;
        }
    }
    
    [self.conversationDataRepository addObject:model];
    return YES;
}


/**
 *  判断消息是否在collectionView的底部
 *
 *  @return 是否在底部
 */
- (BOOL)isAtTheBottomOfTableView {
    if (self.conversationMessageCollectionView.contentSize.height <= self.conversationMessageCollectionView.frame.size.height) {
        return YES;
    }
    if(self.conversationMessageCollectionView.contentOffset.y +200 >= (self.conversationMessageCollectionView.contentSize.height - self.conversationMessageCollectionView.frame.size.height)) {
        return YES;
    }else{
        return NO;
    }
}

/**
 *  更新底部新消息提示显示状态
 */
- (void)updateUnreadMsgCountLabel{
    
}


#pragma mark - QNInputBarControlDelegate
//  根据inputBar 回调来修改页面布局
- (void)onInputBarControlContentSizeChanged:(CGRect)frame withAnimationDuration:(CGFloat)duration andAnimationCurve:(UIViewAnimationCurve)curve ifKeyboardShow:(BOOL)ifKeyboardShow {
    CGRect originFrame = self.frame;
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        CGFloat bottomExtraDistance  = 0;
        if (@available(iOS 11.0, *)) {
            bottomExtraDistance = [self getIPhonexExtraBottomHeight];
        }
        if (ifKeyboardShow) {
            [weakSelf setFrame:CGRectMake(0, frame.origin.y - originFrame.size.height + 50 , originFrame.size.width, originFrame.size.height)];
        }else {
            [weakSelf setFrame:CGRectMake(0, frame.origin.y - originFrame.size.height - bottomExtraDistance , originFrame.size.width, originFrame.size.height)];
        }
        [UIView commitAnimations];
    }];
}

//  发送消息
- (void)onTouchSendButton:(NSString *)text {
    
    NSString *imUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_IM_UID"];
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:text fromId:imUserId.longLongValue toId:self.conversationId type:QNIMMessageTypeGroup conversationId:self.conversationId];
    [self sendMessage:message];
    
}
/**
 发送消息

 @param messageContent 消息
 */

- (void)sendMessage:(QNIMMessageObject *)messageContent {

    if (messageContent == nil) {
        return;
    }
    [[QNIMChatService sharedOption] sendMessage:messageContent];
    
    [self appendAndDisplayMessage:messageContent];
    [self.inputBar clearInputView];
    self.inputBar.hidden = YES;
    [[IQKeyboardManager sharedManager] resignFirstResponder];

}

/**
 接收消息

 @param messages 消息
 */
- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    
    QNIMMessageObject *message = messages.firstObject;
    
    [self appendAndDisplayMessage:message];
    if (![self isAtTheBottomOfTableView]) {
        self.unreadNewMsgCount ++ ;
        [self updateUnreadMsgCountLabel];
    }
}

#pragma mark <UIScrollViewDelegate,UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.conversationDataRepository.count;
}

/**
 *  接收到消息的回调
 */
- (void)didReceiveMessageNotification:(NSNotification *)notification {
//    __block RCMessage *rcMessage = notification.object;
//    QNMessageModel *model = [[QNMessageModel alloc] initWithMessage:rcMessage];
//    model.userInfo = rcMessage.content.senderUserInfo;
//
//    if ([model.targetId isEqual:self.model.roomId]) {
//        __weak typeof(&*self) __blockSelf = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            // 收到用户进入后台的回调
//            if ([model.content isMemberOfClass:[RCChatroomSignal class]]) {
//                RCChatroomSignal * background = (RCChatroomSignal *)rcMessage.content;
//                if ([self.delegate respondsToSelector:@selector(didReceiveMessageUserBackground:)]) {
//                    [self.delegate didReceiveMessageUserBackground:background];
//                }
//            }
//            if (rcMessage) {
//                 if ([rcMessage.content isMemberOfClass:[RCChatroomWelcome class]]) {
//                    //  过滤自己发送的欢迎消息
//                    if ([rcMessage.senderUserId isEqualToString:[QNRongCloudIMManager sharedQNRongCloudIMManager].currentUserInfo.userId]) {
//                        return;
//                    }
//                }
//
//                NSDictionary *leftDic = notification.userInfo;
//                if (leftDic && [leftDic[@"left"] isEqual:@(0)]) {
//                    __blockSelf.isNeedScrollToButtom = YES;
//                }
//                [__blockSelf appendAndDisplayMessage:rcMessage];
//                UIMenuController *menu = [UIMenuController sharedMenuController];
//                menu.menuVisible=NO;
//                //如果消息不在最底部，收到消息之后不滚动到底部，加到列表中只记录未读数
//                if (![__blockSelf isAtTheBottomOfTableView]) {
//                    __blockSelf.unreadNewMsgCount ++ ;
//                    [__blockSelf updateUnreadMsgCountLabel];
//                }
//            }
//        });
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([rcMessage.senderUserId isEqualToString:@"qlive-system"]) {
//            if ([self.delegate respondsToSelector:@selector(didReceiveIMSignalMessage:)]) {
//                [self.delegate didReceiveIMSignalMessage:rcMessage.content];
//            }
//        }
//    });
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QNIMMessageObject *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    QNMessageBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ConversationMessageCollectionViewCell forIndexPath:indexPath];;
        QNTextMessageCell *__cell = [collectionView dequeueReusableCellWithReuseIdentifier:textCellIndentifier forIndexPath:indexPath];
        [__cell setDataModel:model];
        cell = __cell;
    
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout *)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    QNMessageModel *model = self.conversationDataRepository[indexPath.row];
//    if ([model.content isKindOfClass:[RCChatroomStart class]] || [model.content isKindOfClass:[RCChatroomEnd class]]) {
//        return CGSizeMake(self.bounds.size.width,70);
//    }
//    return CGSizeMake(self.bounds.size.width,40);
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return -5.f;
}

#pragma mark - gesture and button action
- (void)resetBottomGesture:
(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setDefaultBottomViewStatus];
    }
}

- (void)setDefaultBottomViewStatus {
    [self.inputBar setInputBarStatus:QNBottomBarStatusDefault];
    [self.inputBar setHidden:YES];
}

- (void)alertErrorWithTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:ok style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
    });
    
}

#pragma mark - getter setter

- (UIView *)bottomBtnContentView {
    if (!_bottomBtnContentView) {
        _bottomBtnContentView = [[UIView alloc] init];
        [_bottomBtnContentView setBackgroundColor:[UIColor clearColor]];
    }
    return _bottomBtnContentView;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] init];
        [_commentBtn addTarget:self
                        action:@selector(commentBtnPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        [_commentBtn setImage:[UIImage imageNamed:@"feedback"] forState:UIControlStateNormal];
    }
    return _commentBtn;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    }
    return _closeButton;

}

- (UIView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
        [_messageContentView setBackgroundColor: [UIColor clearColor]];
    }
    return _messageContentView;
}

- (UICollectionView *)conversationMessageCollectionView {
    if (!_conversationMessageCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _conversationMessageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_conversationMessageCollectionView setDelegate:self];
        [_conversationMessageCollectionView setDataSource:self];
        [_conversationMessageCollectionView setBackgroundColor: [UIColor clearColor]];
        [_conversationMessageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ConversationMessageCollectionViewCell];
    }
    return _conversationMessageCollectionView;
}

- (QNInputBarControl *)inputBar {
    if (!_inputBar) {
        _inputBar = [[QNInputBarControl alloc] initWithStatus:QNBottomBarStatusDefault];
        [_inputBar setDelegate:self];
    }
    return _inputBar;
}

- (NSMutableArray *)conversationDataRepository {
    if (!_conversationDataRepository) {
           _conversationDataRepository = [[NSMutableArray alloc] init];
       }
       return _conversationDataRepository;
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}


@end
