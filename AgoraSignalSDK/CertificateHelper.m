//
// Created by WenDaoJiang on 2017/5/10.
// Copyright (c) 2017 ___FULLUSERNAME___. All rights reserved.
//

#import "CertificateHelper.h"


@implementation CertificateHelper

+ (NSString *)SignalingKeyByAppId: (NSString *) appId Certificate:(NSString *)certificate Account:(NSString*)account ExpiredTime:(unsigned)expiredTime {
    //return [[self new] SignalingKeyByAppId:appId Certificate:certificate Account:account ExpiredTime:expiredTime];
    NSString * sign = [self MD5:[NSString stringWithFormat:@"%@%@%@%d", account, appId, certificate, expiredTime]];
    return [NSString stringWithFormat:@"1:%@:%d:%@", appId, expiredTime, sign];
}

//- (NSString *) SignalingKeyByAppId:(NSString *)_appID Certificate:(NSString *)certificate Account:(NSString*)account ExpiredTime:(unsigned)expiredTime {
//    //1:appId:expiredTime:md5(account + appId + appCertificate + expiredTime)
//
//    NSString * sign = [self MD5:[NSString stringWithFormat:@"%@%@%@%d", account, _appID, certificate, expiredTime]];
//    return [NSString stringWithFormat:@"1:%@:%d:%@", _appID, expiredTime, sign];
//}


+ (NSString*)MD5:(NSString*)s
{
    // Create pointer to the string as UTF8
    const char *ptr = [s UTF8String];

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (uint32_t)strlen(ptr), md5Buffer);

    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];

    return output;
}

+ (NSString *)account {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"account.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *_account;
    if ([fileManager fileExistsAtPath:filePath]){
        NSError *error;
        _account = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: &error];
        if (error == nil){
            return _account;
        }
    }

    int value = arc4random() % 8999 + 1000;
    _account = [NSString stringWithFormat:@"%d", value];
    [fileManager createFileAtPath:filePath contents:[_account dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    return _account;
}

@end
