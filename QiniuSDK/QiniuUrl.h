//
//  QiniuUrl.h
//  QiniuSDK
//
//  Created by 小六 on 14-5-10.
//  Copyright (c) 2014年 秀客. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  请求某个资源的url:过期重新请求或新的资源
 */
@interface QiniuUrl : NSObject

@property (nonatomic, copy, readonly) NSString *qiniuAccessKey;
@property (nonatomic, copy, readonly) NSString *qiniuSecretKey;
@property (nonatomic, copy, readonly) NSString *host;

/**
 *  初始化
 *
 *  @param secretKey 密码
 *  @param accessKey 凭证
 *  @param host      地址
 */
- (void)startWithSecretKey:(NSString *)secretKey
                 accessKey:(NSString *)accessKey
                      host:(NSString *)host;
/**
 *  资源url
 *
 *  @param name 资源名(2QReBSSf-E3kZ53-taOygl4K194=/lms1uDyono_DLY75WcVQzhFAnIWt)
 *
 *  @return url:带有时效性的
 */
- (NSString *)getUrlByName:(NSString *)name;
/**
 *  某个文件的token
 *
 *  @param name 文件名
 *
 *  @return token
 */
- (NSString *)getTokenByName:(NSString *)name;
@end
