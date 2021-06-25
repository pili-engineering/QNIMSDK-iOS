//
//  QNInputBarControl.m
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/3.
//

#import "QNInputBarControl.h"
#import "QNInputView.h"
#import "QNUtilities.h"
#import "QNEmojiBoardView.h"

#define HeightEmojBoardView 220.0f

@interface QNInputBarControl ()<QNInputViewDelegate, QNEmojiViewDelegate>

/*!
 当前输入框状态
 */
@property(nonatomic) QNBottomBarStatus currentBottomBarStatus;

/*!
 输入框
 */
@property(nonatomic, strong) QNInputView *inputBoxView;

/*!
 表情View
 */
@property(nonatomic, strong) QNEmojiBoardView *emojiBoardView;

@end

@implementation QNInputBarControl

//  初始化
- (id)initWithStatus:(QNBottomBarStatus)status {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self initializedSubViews];
        [self registerNotification];
        [self setCurrentBottomBarStatus:status];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_inputBoxView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

-(void)setInputBarStatus:(QNBottomBarStatus)Status {
    [self setCurrentBottomBarStatus:Status];
    //  弹出键盘
    if (Status == QNBottomBarStatusKeyboard) {
        [_inputBoxView.emojiButton setSelected:NO];
        [_inputBoxView.inputTextView becomeFirstResponder];
    } else {
        if (Status == QNBottomBarStatusEmoji) {
            [_inputBoxView.emojiButton setSelected:YES];
        } else {
            [_inputBoxView.emojiButton setSelected:NO];
        }
        //  其他状态隐藏键盘
        if (_inputBoxView.inputTextView.isFirstResponder) {
            [_inputBoxView.inputTextView resignFirstResponder];
        }
    }
    
    if (Status != QNBottomBarStatusEmoji) {
        //  非emoji状态设置输入框InputView为nil
        [_inputBoxView.inputTextView setInputView:nil];
    }
}

-(void)changeInputBarFrame:(CGRect)frame{
    
}

#pragma mark - Notification action
- (void) KeyboardWillShow:(NSNotification*)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    if ([self.delegate respondsToSelector:@selector(onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:ifKeyboardShow:)]) {
        [self.delegate onInputBarControlContentSizeChanged:keyboardBounds withAnimationDuration:0.5 andAnimationCurve:curve ifKeyboardShow:YES];
    }
//
//    self.currentFrame = self.frame;
//    self.currentInputBarHeight = self.frame.size.height;
//    [self chatSessionInputBarControlContentSizeChanged:self.chatSessionInputBarControl.frame];
}

- (void)KeyboardWillHide:(NSNotification*)notification {
    if ([self.delegate respondsToSelector:@selector(onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:ifKeyboardShow:)]) {
        //  目前只使用y值即可
        CGRect frame ;
        frame.origin.y = [[UIScreen mainScreen] bounds].size.height;
        if (ISX) {
            frame.origin.y -= 34;
        }
        [self.delegate onInputBarControlContentSizeChanged:frame withAnimationDuration:0.1 andAnimationCurve:0 ifKeyboardShow:NO];
    }
//    [self animationLayoutBottomBarWithStatus:RCDLiveBottomBarDefaultStatus animated:YES];
//    self.currentFrame = self.frame;
//    self.KeyboardFrame = CGRectZero;
//    self.currentInputBarHeight = self.frame.size.height;
//    [self chatSessionInputBarControlContentSizeChanged:self.chatSessionInputBarControl.frame];
}

#pragma mark - QNInputViewDelegate
//  点击表情按钮
- (void)didTouchEmojiButton:(UIButton *)sender {
    [_inputBoxView.inputTextView becomeFirstResponder];
    if (!sender.selected) {
        [_inputBoxView.inputTextView setInputView:nil];
    } else {
        [_inputBoxView.inputTextView setInputView:self.emojiBoardView];
        if (!(_emojiBoardView.frame.size.width > 0)) {
         CGFloat bottomExtraDistance  = 0;
          if (@available(iOS 11.0, *)) {
              bottomExtraDistance = [self getIPhonexExtraBottomHeight];
          }
            [_emojiBoardView setFrame:CGRectMake(0, 0, self.bounds.size.width,  HeightEmojBoardView + bottomExtraDistance)];
        }
//        [_emojiBoardView setBackgroundColor:[UIColor blueColor]];
    }
    [_inputBoxView.inputTextView reloadInputViews];
}

//  点击发送
- (void)didTouchKeyboardReturnKey:(QNInputView *)inputControl text:(NSString *)text {
    if([self.delegate respondsToSelector:@selector(onTouchSendButton:)]){
        [self.delegate onTouchSendButton:text];
    }
}

//  输入框内容变换
- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([self.delegate respondsToSelector:@selector(onInputTextView:shouldChangeTextInRange:replacementText:)]){
        [self.delegate onInputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
    }
}

#pragma mark - QNEmojiViewDelegate
//  发送表情
- (void)didSendButtonEvent {
    NSString *sendText = self.inputBoxView.inputTextView.text;
    
    NSString *formatString = [sendText
                               stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];    //去掉空格
    if (0 == [formatString length]) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(onTouchSendButton:)]){
        [self.delegate onTouchSendButton:sendText];
    }
}

- (void)didTouchEmojiView:(QNEmojiBoardView *)emojiView touchedEmoji:(NSString *)string {
//    NSString *replaceString = string;
    if (string == nil) {
        [self.inputBoxView.inputTextView deleteBackward];
    } else {
        [self.inputBoxView.inputTextView setText:[self.inputBoxView.inputTextView.text stringByAppendingString:string]];
    }
}

#pragma mark - UI

- (void)initializedSubViews {
    [self addSubview:self.inputBoxView];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (QNInputView *)inputBoxView {
    if (!_inputBoxView) {
        _inputBoxView = [[QNInputView alloc] initWithStatus:QNBottomBarStatusDefault];
        [_inputBoxView setDelegate:self];
    }
    return _inputBoxView;
}

//表情区域控件
- (QNEmojiBoardView *)emojiBoardView {
    if (!_emojiBoardView) {
        _emojiBoardView = [[QNEmojiBoardView alloc] init];
        _emojiBoardView.delegate = self;
    }
    return _emojiBoardView;
}

- (void)clearInputView {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.inputBoxView clearInputText];
    });
    
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
