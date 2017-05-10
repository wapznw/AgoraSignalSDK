//
//  ViewController.m
//  AgoraSignalSDK
//
//  Created by WenDaoJiang on 2017/5/10.
//  Copyright (c) 2017 WenDaoJiang. All rights reserved.
//


#import "ViewController.h"


#import "CertificateHelper.h"

#define AppId @""
#define certificate1 @""
#define channelName @"test1to1"


@interface ViewController ()

@property(nonatomic, strong) AgoraAPI *agoraApi;
@property BOOL isLogin;
@property UIButton *loginBtn;
@property UIButton *callBtn;
@property UITextField *numberInput;
@property NSString *myAccount; // 当前账号
@property NSString *toAccount; // 对方账号
@property UIView *callingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _myAccount = [CertificateHelper account];

    UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, 50, 100, 30)];
    accountLabel.textAlignment = NSTextAlignmentCenter;
    accountLabel.font = [UIFont systemFontOfSize:28];
    [accountLabel setText:_myAccount];
    [self.view addSubview:accountLabel];


    // Do any additional setup after loading the view, typically from a nib.
    _loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(onLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    _loginBtn.frame = CGRectMake(0, 0, 60, 30);
    _loginBtn.center = CGPointMake(self.view.center.x, accountLabel.center.y + 40);
    [self.view addSubview:_loginBtn];


    _numberInput = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 30)];
    _numberInput.center = CGPointMake(self.view.center.x, _loginBtn.center.y + 40);
    _numberInput.borderStyle = UITextBorderStyleRoundedRect;
    _numberInput.placeholder = @"请输入对方号码";
    _numberInput.clearButtonMode = UITextFieldViewModeAlways;
    _numberInput.keyboardType = UIKeyboardTypeNumberPad;
    _numberInput.layer.hidden = YES;
    [self.view addSubview:_numberInput];

    _callBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_callBtn setTitle:@"Call" forState:UIControlStateNormal];
    [_callBtn addTarget:self action:@selector(onCallClick:) forControlEvents:UIControlEventTouchUpInside];
    _callBtn.frame = CGRectMake(0, 0, 60, 30);
    _callBtn.center = CGPointMake(_loginBtn.center.x, _numberInput.center.y + 40);
    _callBtn.layer.hidden = YES;
    [self.view addSubview:_callBtn];


    _callingView = [[UIView alloc] initWithFrame:self.view.frame];
    _callingView.backgroundColor = [UIColor grayColor];
    _callingView.layer.hidden = YES;
    //_callingView.layer.zPosition = 1;
    [self.view addSubview:_callingView];

    UILabel *callingText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    callingText.center = _callingView.center;
    callingText.text = @"正在通话中...";
    callingText.textColor = [UIColor whiteColor];
    [_callingView addSubview:callingText];

    UIButton *hangUp = [UIButton buttonWithType:UIButtonTypeCustom];
    [hangUp setTitle:@"挂断" forState:UIControlStateNormal];
    [hangUp setBackgroundColor:[UIColor redColor]];
    hangUp.frame = CGRectMake(0, 0, 60, 60);
    hangUp.center = CGPointMake(callingText.center.x, callingText.center.y + 100);
    hangUp.layer.cornerRadius = 30;
    [hangUp addTarget:self action:@selector(onHangUpClick:) forControlEvents:UIControlEventTouchUpInside];

    [_callingView addSubview:hangUp];

    [self initAgoraSignal];
    [self loginByAccount:_myAccount];
}

- (void)initAgoraSignal {

    self.agoraApi = [AgoraAPI getInstanceWithoutMedia:AppId];


    id __weak weak_self = self;
    _agoraApi.onLoginSuccess = ^(uint32_t uid, int fd) {
        [weak_self setLoginState:YES];
        NSLog(@"Login successfully ");
    };

    _agoraApi.onLoginFailed = ^(AgoraEcode code) {
        NSLog(@"Login failed, code: %d", code);
    };

    _agoraApi.onLogout = ^(AgoraEcode code) {
        [weak_self setLoginState:NO];
        if (code == AgoraEcode_LOGOUT_E_USER) {
            NSLog(@"Logout successfully");
        } else {
            NSLog(@"Logout, code %d", code);
        }
    };

    // 加入 channel
    _agoraApi.onChannelJoined = ^(NSString *channelID) {
        NSLog(@"onChannelJoined %@", channelID);
    };

    // 收到呼叫邀请回调(onInviteReceived)
    AgoraAPI *__weak weak_agora = _agoraApi;
    _agoraApi.onInviteReceived = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
        [weak_self setToAccount:account];
        NSLog(@"收到呼叫邀请回调 %@", account);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通话邀请"
                                                                           message:[NSString stringWithFormat:@"%@邀请您视频通话", account]
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"接通" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [weak_self callingView].layer.hidden = NO;
                [weak_agora channelInviteAccept:channelID account:account uid:uid];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [weak_agora channelInviteRefuse:channelID account:account uid:uid extra:nil];
            }];

            [alert addAction:okAction];
            [alert addAction:cancelAction];

            [weak_self presentViewController:alert animated:YES completion:nil];
        });
    };

    //远端已接受呼叫回调(onInviteAcceptedByPeer)
    _agoraApi.onInviteAcceptedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
        NSLog(@"onInviteAcceptedByPeer: %@", account);
        [weak_self setToAccount:account];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weak_self callingView].layer.hidden = NO;
        });
    };

    //对方已拒绝呼叫回调(onInviteRefusedByPeer)
    _agoraApi.onInviteRefusedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
        NSLog(@"对方已拒绝呼叫回调 %@", account);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通话邀请"
                                                                           message:[NSString stringWithFormat:@"%@已拒绝您的视频通话邀请", account]
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];

            [alert addAction:okAction];

            [weak_self presentViewController:alert animated:YES completion:nil];

        });
    };

    //对方endCall回调(onInviteEndByPeer)
    _agoraApi.onInviteEndByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
        [weak_self setToAccount:account];
        NSLog(@"对方endCall回调 %@", account);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通话邀请"
                                                                           message:[NSString stringWithFormat:@"%@已挂断", account]
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [weak_self callingView].layer.hidden = YES;
            }];

            [alert addAction:okAction];

            [weak_self presentViewController:alert animated:YES completion:nil];
        });
    };

    //本地已结束呼叫回调(onInviteEndByMyself)
    _agoraApi.onInviteEndByMyself = ^(NSString *channelID, NSString *account, uint32_t uid) {
        NSLog(@"onInviteEndByMyself: %@", account);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weak_self callingView].layer.hidden = YES;
        });
    };

    // 当呼叫失败时触发。
    [_agoraApi setOnInviteFailed:^(NSString *channelID, NSString *account, uint32_t uid, AgoraEcode ecode, NSString *extra) {
        NSLog(@"呼叫失败 %@ , code: %d", account, ecode);
    }];

    _agoraApi.onLog = ^(NSString *text) {
        NSLog(@"__LOG__: %@", text);
    };

}

- (void)loginByAccount:(NSString *)account {
    if (self.agoraApi != nil) {
        unsigned expiredTime = (unsigned) [[NSDate date] timeIntervalSince1970] + 3600;
        NSString *token = [CertificateHelper SignalingKeyByAppId:AppId
                                                     Certificate:certificate1
                                                         Account:account
                                                     ExpiredTime:expiredTime];

        [self.agoraApi login2:AppId account:account token:token uid:0 deviceID:@"" retry_time_in_s:60 retry_count:5];
    }
}

- (void)onLoginClick:(UIButton *)sender {
    if (_isLogin) {
        [self.agoraApi logout];
    } else {
        [self loginByAccount:_myAccount];
    }
}

- (void)onCallClick:(UIButton *)sender {
    if (_agoraApi.isOnline) {
        [self callAccount:_numberInput.text];
    }
}

- (void)onHangUpClick:(UIButton *)sender {
    [_agoraApi channelInviteEnd:channelName account:[self toAccount] uid:0];
}

- (void)setLoginState:(BOOL)state {
    _isLogin = state;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loginBtn setTitle:state ? @"登出" : @"登录" forState:UIControlStateNormal];
        if (state) {
            [_agoraApi channelJoin:channelName]; // 登录成功后加入房间
            _numberInput.layer.hidden = NO;
            _callBtn.layer.hidden = NO;
        } else {
            [_agoraApi channelLeave:channelName]; // 退出后离开房间
            _numberInput.layer.hidden = YES;
            _callBtn.layer.hidden = YES;
        }
    });
}

- (void)callAccount:(NSString *)account {
    NSLog(@"channelInviteUser: %@", account);
    _toAccount = account;
    [_agoraApi channelInviteUser:channelName account:account uid:0]; // 呼叫用户
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
