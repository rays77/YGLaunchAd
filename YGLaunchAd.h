//
//  YGLuanchAd.h
//  iOutletShopping
//
//  Created by Ray on 17/1/19.
//  Copyright © 2017年 aolaigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGLaunchAdView.h"
#import "YGLaunchAdImageView.h"

#define YGLaunchAdType       1100 // 点击广告
#define YGLaunchSkipType     1101 // 点击跳过
#define YGLaunchDoneType     1102 // 倒计时完成

#define YGMainHeight      [[UIScreen mainScreen] bounds].size.height
#define YGMainWidth       [[UIScreen mainScreen] bounds].size.width

typedef void (^YGLaunchAdBlock) (NSInteger tag);

@interface YGLaunchAd : NSObject

@property (nonatomic, strong) YGLaunchAdImageView *launchImageView;
// 回调事件
@property (nonatomic, copy  ) YGLaunchAdBlock launchBlock;
// 倒计时总时长，默认5秒
@property (nonatomic, assign) NSInteger adDuration;
// 数据等待时长，默认3秒
@property (nonatomic, assign) NSInteger waitDataDuration;
// 从后台进入时二次开屏，默认NO
@property (nonatomic, assign) BOOL enterForegroundLaunch;

/*!
 * 开屏广告单利
 */
+ (YGLaunchAd *)shareLaunchAd;

/*!
 * 设置广告的url
 */
- (void)showLaunchAdWithAdImage:(UIImage *)adImage;

@end
