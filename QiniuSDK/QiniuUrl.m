//
//  QiniuUrl.m
//  QiniuSDK
//
//  Created by 小六 on 14-5-10.
//  Copyright (c) 2014年 秀客. All rights reserved.
//

#import "QiniuUrl.h"
#import <CommonCrypto/CommonHMAC.h>
@interface QiniuUrl ()

@property (nonatomic, copy, readwrite) NSString *qiniuAccessKey;
@property (nonatomic, copy, readwrite) NSString *qiniuSecretKey;
@property (nonatomic, copy, readwrite) NSString *host;
@property (nonatomic, retain) NSString  *tmpUrl;

@end

@implementation QiniuUrl

- (void)startWithSecretKey:(NSString *)secretKey accessKey:(NSString *)accessKey host:(NSString *)host  {
    self.qiniuAccessKey = accessKey;
    self.qiniuSecretKey = secretKey;
    self.host           = host;
}

- (NSString *)getUrlByName:(NSString *)name {
    NSString *token = [self getTokenByName:name];
    self.tmpUrl = [self.tmpUrl stringByAppendingFormat:@"&token=%@",token];
    return self.tmpUrl;
}

- (NSString *)getTokenByName:(NSString *)name   {
    if ([self.host hasSuffix:@"/"]) {
        self.tmpUrl = [self.host stringByAppendingString:name];
    }else   {
        self.tmpUrl = [self.host stringByAppendingFormat:@"/%@",name];
    }
    NSTimeInterval expires = [[NSDate date] timeIntervalSince1970] +7200;
    self.tmpUrl = [self.tmpUrl stringByAppendingFormat:@"?e=%d",(int)expires];
    const char *cKey = [self.qiniuSecretKey cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self.tmpUrl cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *signature = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *token = [NSString stringWithFormat:@"%@:%@",self.qiniuAccessKey,signature];
    return token;
}


@end
