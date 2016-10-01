//
// Created by Yao Guai on 16/9/30.
// Copyright (c) 2016 minions.jegarn.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JegarnCFSocketDecoder.h"

@class JegarnSecurityPolicy;


@interface JegarnCFSslSocketDecoder : JegarnCFSocketDecoder

@property(strong, nonatomic) JegarnSecurityPolicy *securityPolicy;
@property(strong, nonatomic) NSString *securityDomain;

@end