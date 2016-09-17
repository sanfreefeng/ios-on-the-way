//
// Created by Yao Guai on 16/7/24.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

#import "MNChatViewController.h"
#import "YGCommonMicro.h"
#import "MNChatViewModel.h"
#import "MNChatTableViewCell.h"
#import "MNChatMessageModel.h"
#import "MNUserModel.h"
#import "MNWidgetUtil.h"
#import "YYKeyboardManager.h"
#import "MNLoginUserManager.h"
#import "MNLoginUserModel.h"


@implementation MNChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                                                                            target:self action:@selector(backBtnClick)];

    UIColor *commonColor = [UIColor colorWithRed:155 / 255.0 green:155 / 255.0 blue:155 / 255.0 alpha:1];
    UIColor *commonHighlightColor = [UIColor colorWithRed:155 / 255.0 green:155 / 255.0 blue:155 / 255.0 alpha:0.44];

    _loginUser = [MNLoginUserManager sharedInstance].loginUser;
    _viewModel = [[MNChatViewModel alloc] init];

    _contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, YGWindowWidth, YGWindowHeight - 40) style:UITableViewStylePlain];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];

    _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, YGWindowHeight - 39, YGWindowWidth - 95, 30)];
    _inputTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _inputTextField.layer.borderWidth = 1.0;
    _inputTextField.delegate = self;
    [_inputTextField becomeFirstResponder];
    [self.view addSubview:_inputTextField];

    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(YGWindowWidth - 82, YGWindowHeight - 42, 80, 36)];
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_sendButton setTitleColor:commonColor forState:UIControlStateNormal];
    [_sendButton setTitleColor:commonHighlightColor forState:UIControlStateHighlighted];
    [_sendButton setTitleColor:commonHighlightColor forState:UIControlStateSelected];
    _sendButton.layer.borderColor = commonColor.CGColor;
    _sendButton.layer.borderWidth = 1.0;
    _sendButton.layer.cornerRadius = 10.0;
    [_sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_sendButton];

    YYKeyboardManager *manager = [YYKeyboardManager defaultManager];
    [manager addObserver:self];
}

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    YYKeyboardManager *manager = [YYKeyboardManager defaultManager];
    CGRect toFrame = [manager convertRect:transition.toFrame toView:self.view];
    BOOL toVisible = transition.toVisible;
    if (toVisible) {
        _contentTableView.frame = CGRectMake(0, 0, YGWindowWidth, YGWindowHeight - 40 - toFrame.size.height);
        _inputTextField.frame = CGRectMake(5, YGWindowHeight - 39 - toFrame.size.height, YGWindowWidth - 95, 30);
        _sendButton.frame = CGRectMake(YGWindowWidth - 82, YGWindowHeight - 42 - toFrame.size.height, 80, 36);
    } else {
        _contentTableView.frame = CGRectMake(0, 0, YGWindowWidth, YGWindowHeight - 40);
        _inputTextField.frame = CGRectMake(5, YGWindowHeight - 39, YGWindowWidth - 95, 30);
        _sendButton.frame = CGRectMake(YGWindowWidth - 82, YGWindowHeight - 42, 80, 36);
    }
}

- (void)backBtnClick {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)sendButtonClick {
    NSString *content = _inputTextField.text;
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (YGIsEmptyString(content)) {
        [MNWidgetUtil alertWithController:self title:@"Alter" mssage:@"content can not be empty"];
        return;
    }

    MNChatMessageModel *chatMessageModel = [[MNChatMessageModel alloc] init];
    chatMessageModel.user = _loginUser;
    chatMessageModel.content = content;
    NSIndexPath *indexPath = [_viewModel appendChatMessageModel:chatMessageModel];
    [_contentTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    _inputTextField.text = @"";
    [_inputTextField becomeFirstResponder];
    if ([_viewModel count] > 0) {
        [_contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_viewModel count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendButtonClick];
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_viewModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    MNChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MNChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    MNChatMessageModel *chatMessage = [_viewModel chatMessageForRowAtIndexPath:indexPath];
    [cell renderFromChatMessage:chatMessage isLoginUser:[chatMessage.user.uid isEqualToString:_loginUser.uid]];
    [MNChatTableViewCell storageHeight:cell.height ForRowAtIndexPath:indexPath];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MNChatTableViewCell heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

@end