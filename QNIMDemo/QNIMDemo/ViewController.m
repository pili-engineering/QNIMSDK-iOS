//
//  ViewController.m
//  QNIMDemo
//
//  Created by 郭茜 on 2021/6/1.
//

#import "ViewController.h"
#import <QNRTCKit/QNRTCKit.h>
#import <YYCategories/YYCategories.h>
#import "MBProgressHUD+QNShow.h"
#import "QNRoomUserView.h"
#import "QNNetworkUtil.h"
#import <QNIMSDK/QNIMSDK.h>
#import "QNChatRoomView.h"
#import "QNMainViewController.h"
#import "QNCountdownButton.h"
#import "QNLoginInfoModel.h"
#import <MJExtension/MJExtension.h>

//登录token
#define QN_LOGIN_TOKEN_KEY @"QN_LOGIN_TOKEN"
//用户ID
#define QN_ACCOUNT_ID_KEY @"QN_ACCOUNT_ID"
//用户昵称
#define QN_NICKNAME_KEY @"QN_NICKNAME"
//手机号
#define QN_PHONE_KEY @"QN_PHONE"
//RTC appId
#define QN_APPID_KEY @"d8lk7l4ed"

@interface ViewController ()

@property (nonatomic, copy) NSString *roomName;

@property (nonatomic, copy) NSString *roomToken;

@property (nonatomic, strong) UITextField *phoneTf;

@property (nonatomic, strong) UITextField *codeTf;

@property (nonatomic, strong) QNCountdownButton *sendCodeButton;

@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomName = @"1234567890987654321";
    [self setUpUI];
}

- (void)setUpUI {
    [self phoneTf];
    [self codeTf];
    [self sendCodeButton];
    [self loginButton];
    
    UIView *topLineView = [[UIView alloc]init];
    topLineView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
    [self.view addSubview:topLineView];
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.phoneTf.mas_bottom).offset(5);
        make.height.mas_equalTo(1);
    }];
    
    UIView *bottomLineView = [[UIView alloc]init];
    bottomLineView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
    [self.view addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.codeTf.mas_bottom).offset(5);
        make.height.mas_equalTo(1);
    }];
}

//获取roomToken
- (void)requestRoomTokenWithRoomName:(NSString *)roomName appId:(NSString *)appId userId:(NSString *)userId {
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-demo.qnsdk.com/v1/rtc/token/admin/app/%@/room/%@/user/%@", appId, roomName, userId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        self.roomToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [self requestImAcountWithUserId:userId];
    }];
    [task resume];

}

//获取聊天室Id
- (void)requestImGroupIdWithRoomId:(NSString *)roomId {
    
    [[QNIMClient sharedClient]getGroupIdWithRoomId:roomId completion:^(NSString * _Nonnull groupId) {
        if (groupId) {
            [self gotoRTCVcWithRoomWithGroupId:groupId];
        } else {
//            [MBProgressHUD showText:@"获取聊天室id失败"];
        }
    }];

}

//请求IM登录信息
- (void)requestImAcountWithUserId:(NSString *)userId {
    
    [[QNIMClient sharedClient]signInByUserId:userId completion:^(QNIMError * _Nonnull qnImError) {
        if (qnImError) {
//            [MBProgressHUD showText:@"IM登录失败"];
        }
        [self requestImGroupIdWithRoomId:self.roomName];
    }];
}

- (void)gotoRTCVcWithRoomWithGroupId:(NSString *)groupId {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        QNMainViewController *vc = [QNMainViewController new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.roomToken = self.roomToken;
        vc.groupId = groupId;
        [self presentViewController:vc animated:YES completion:nil];
       
    });
    
}

//登录
- (void)loginButtonClick {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.phoneTf.text forKey:QN_PHONE_KEY];
    
    if (self.phoneTf.text.length == 0) {
        [MBProgressHUD showText:@"请填写手机号"];
        return;
    }
    
    if (self.codeTf.text.length == 0) {
        [MBProgressHUD showText:@"请填写验证码"];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = self.phoneTf.text;
    params[@"smsCode"] = self.codeTf.text;
    [QNNetworkUtil postLoginRequestWithAction:@"signUpOrIn" params:params success:^(NSDictionary *responseData) {
        
        QNLoginInfoModel *loginModel = [QNLoginInfoModel mj_objectWithKeyValues:responseData];
        [[NSUserDefaults standardUserDefaults] setObject:loginModel.nickname forKey:QN_NICKNAME_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:loginModel.loginToken forKey:QN_LOGIN_TOKEN_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:loginModel.accountId forKey:QN_ACCOUNT_ID_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self requestRoomTokenWithRoomName:self.roomName appId:QN_APPID_KEY userId:loginModel.accountId];
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD showText:@"登录失败"];
        
    }];

}

- (void)getSmsCode {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = self.phoneTf.text;
    [QNNetworkUtil postLoginRequestWithAction:@"getSmsCode" params:params success:^(NSDictionary *responseData) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)sendCodeMsgButtonClick {
    [self getSmsCode];
    __weak typeof(self) weakSelf = self;
    [_sendCodeButton countDownWithDuration:60 completion:^(BOOL finished) {
        [weakSelf.sendCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        weakSelf.sendCodeButton.selected = NO;
        weakSelf.sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [weakSelf.sendCodeButton setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
    }];
}

- (UITextField *)phoneTf {
    if (!_phoneTf) {
        _phoneTf = [[UITextField alloc]init];
        _phoneTf.font = [UIFont systemFontOfSize:15];
        _phoneTf.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
        _phoneTf.leftViewMode = UITextFieldViewModeAlways;
        _phoneTf.textColor = [UIColor blackColor];
        _phoneTf.textAlignment = NSTextAlignmentLeft;
        NSAttributedString *placeHolderStr = [[NSAttributedString alloc]initWithString:@"请输入手机号" attributes:@{
            NSForegroundColorAttributeName:[UIColor lightGrayColor],
            NSFontAttributeName:_phoneTf.font
        }];
        _phoneTf.attributedPlaceholder = placeHolderStr;
        
        NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:QN_PHONE_KEY];
        if (phone.length > 0) {
            _phoneTf.text = phone;
        }
        [self.view addSubview:_phoneTf];
        [_phoneTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(40);
            make.right.equalTo(self.view).offset(-40);
            make.top.equalTo(self.view).offset(300);
            make.height.mas_equalTo(30);
        }];
    }
    return _phoneTf;
}

- (UITextField *)codeTf {
    if (!_codeTf) {
        _codeTf = [[UITextField alloc]init];
        _codeTf.font = [UIFont systemFontOfSize:15];
        _codeTf.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
        _codeTf.leftViewMode = UITextFieldViewModeAlways;
        _codeTf.textColor = [UIColor blackColor];
        _codeTf.textAlignment = NSTextAlignmentLeft;
        _codeTf.layer.cornerRadius = 10;
        NSAttributedString *placeHolderStr = [[NSAttributedString alloc]initWithString:@"请输入验证码" attributes:@{
            NSForegroundColorAttributeName:[UIColor lightGrayColor],
            NSFontAttributeName:_codeTf.font
        }];
        _codeTf.attributedPlaceholder = placeHolderStr;
        [self.view addSubview:_codeTf];
        [_codeTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right .equalTo(self.phoneTf);
            make.top.equalTo(self.phoneTf.mas_bottom).offset(30);
            make.height.mas_equalTo(30);
        }];
    }
    return _codeTf;
}

- (QNCountdownButton *)sendCodeButton {
    if (!_sendCodeButton) {
        _sendCodeButton = [[QNCountdownButton alloc]init];
        [_sendCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        _sendCodeButton.selected = NO;
        _sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendCodeButton setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
        [_sendCodeButton addTarget:self action:@selector(sendCodeMsgButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.codeTf addSubview:_sendCodeButton];
        
        [_sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.codeTf.mas_right).offset(-5);
            make.centerY.equalTo(self.codeTf);
        }];
    }
    return _sendCodeButton;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[UIButton alloc]init];
        _loginButton.backgroundColor = [UIColor colorWithHexString:@"007AFF"];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 4;
        [self.view addSubview:_loginButton];
        [_loginButton addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(50);
            make.right.equalTo(self.view).offset(-50);
            make.top.equalTo(self.sendCodeButton.mas_bottom).offset(80);
            make.height.mas_offset(40);
        }];
    }
    return _loginButton;
}


@end
