//
//  QNInputBarControl.h
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 输入工具栏的输入模式
 */
typedef NS_ENUM(NSInteger, QNBottomBarStatus) {
    /**
     初始状态
     */
    QNBottomBarStatusDefault = 0,
    /**
     文本输入状态
     */
    QNBottomBarStatusKeyboard,
    /**
     表情输入模式
     */
    QNBottomBarStatusEmoji
};

/**
 输入工具栏的点击监听器
 */
@protocol QNInputBarControlDelegate <NSObject>

@optional
#pragma mark - 输入框及外部区域事件

/**
 输入工具栏尺寸（高度）发生变化的回调
 
 @param frame 输入工具栏最终需要显示的Frame
 */
- (void)onInputBarControlContentSizeChanged:(CGRect)frame
                      withAnimationDuration:(CGFloat)duration
                          andAnimationCurve:(UIViewAnimationCurve)curve
                                      ifKeyboardShow:(BOOL)ifKeyboardShow;
/**
 输入框中内容发生变化的回调
 
 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)onInputTextView:(UITextView *)inputTextView
shouldChangeTextInRange:(NSRange)range
        replacementText:(NSString *)text;

#pragma mark - 输入框事件

/**
 *  点击键盘回车或者emoji表情面板的发送按钮执行的方法
 
 *  @param text      输入框的内容
 */
- (void)onTouchSendButton:(NSString *)text;

@end

@interface QNInputBarControl : UIView

@property(nonatomic, weak) id<QNInputBarControlDelegate> delegate;

/**
 设置输入工具栏状态

 */
-(void)setInputBarStatus:(QNBottomBarStatus)Status;

/**
 重新调整页面布局时需要调用这个方法来设置输入框的frame
 
 @param frame       显示的Frame
 */
-(void)changeInputBarFrame:(CGRect)frame;

/**
 清除输入框内容
 */
-(void)clearInputView;

- (id)initWithStatus:(QNBottomBarStatus)status;

@end

NS_ASSUME_NONNULL_END
