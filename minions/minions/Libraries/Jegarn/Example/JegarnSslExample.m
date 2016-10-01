//
// Created by Yao Guai on 16/10/1.
// Copyright (c) 2016 minions.jegarn.com. All rights reserved.
//

#import "JegarnSslExample.h"
#import "JegarnListener.h"
#import "JegarnClient.h"
#import "JegarnSecurityPolicy.h"
#import "JegarnPacketWriter.h"


@implementation JegarnSslExample

- (void) connectToServer
{
    JegarnSecurityPolicy *securityPolicy = [JegarnSecurityPolicy policyWithPinningMode:JegarnSSLPinningModeCertificate];
    NSString *certificate = [[NSBundle bundleForClass:[self class]] pathForResource:@"server" ofType:@"cer"];
    securityPolicy.pinnedCertificates = @[[NSData dataWithContentsOfFile:certificate]];
    securityPolicy.allowInvalidCertificates = NO;
    securityPolicy.validatesCertificateChain = NO;

    NSString *p12File = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
    NSString *p12Password = @"111111";
    NSArray *certificates = [JegarnSecurityPolicy clientCertsFromP12:p12File passphrase:p12Password];

    _client = [[JegarnClient alloc] init];
    _client.account = @"";
    _client.password = @"";
    _client.host = @"";
    _client.port = 7773;
    _client.listener = [[JegarnListener alloc] init];
    _client.runLoop = [NSRunLoop currentRunLoop];
    _client.runLoopMode = NSDefaultRunLoopMode;
    _client.enableSsl = true;
    _client.securityPolicy = securityPolicy;
    _client.certificates = certificates;
    [_client connect];
    NSTimer *sendMsgTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(sslTransportSendMessageHandler) userInfo:nil repeats:YES];
    [sendMsgTimer setFireDate:[NSDate distantPast]];
}

- (void)sslTransportSendMessageHandler {
    [_client.packetWriter send:[@"hello world" dataUsingEncoding:NSUTF8StringEncoding]];
}

@end