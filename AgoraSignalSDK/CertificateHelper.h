//
// Created by WenDaoJiang on 2017/5/10.
// Copyright (c) 2017 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@interface CertificateHelper : NSObject

/**
 * 登录数据签名
 * @param appId
 * @param certificate
 * @param account
 * @param expiredTime
 * @return
 */
+ (NSString *)SignalingKeyByAppId: (NSString *) appId Certificate:(NSString *)certificate Account:(NSString*)account ExpiredTime:(unsigned)expiredTime;

/**
 * 获取当前账号
 * @return
 */
+ (NSString *)account;

@end
