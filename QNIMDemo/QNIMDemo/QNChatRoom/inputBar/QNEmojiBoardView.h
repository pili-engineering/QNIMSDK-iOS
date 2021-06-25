//
//  QNEmojiBoardView.h
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNEmojiBoardView;

/**
 表情输入的回调
 */
@protocol QNEmojiViewDelegate <NSObject>
@optional

/**
 点击表情的回调
 
 @param emojiView 表情输入的View
 @param string    点击的表情对应的字符串编码
 */
- (void)didTouchEmojiView:(QNEmojiBoardView *)emojiView touchedEmoji:(NSString *)string;

/**
 点击发送按钮的回调

 */
- (void)didSendButtonEvent;

@end

@interface QNEmojiBoardView : UIView

/*!
 表情输入的回调
 */
@property(nonatomic, weak) id<QNEmojiViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
