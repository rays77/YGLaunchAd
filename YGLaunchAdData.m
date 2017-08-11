//
//  YGLaunchAdData.m
//  iOutletShopping
//
//  Created by Ray on 2017/2/6.
//  Copyright © 2017年 aolaigo. All rights reserved.
//

#import "YGLaunchAdData.h"
#import "ALJumpToAnotherUI.h"
#import "NSDictionary+NullReplacement.h"
#import "NSObject+ModelUtil.h"
#import "YGLaunchAd.h"
#import "YiStatistics.h"
#import "YGFileManager.h"


NSString* const timeFormat = @"yyyy/MM/dd HH:mm:ss";

@implementation YGLaunchAdData

+ (void)addLaunchAdWithTime:(NSInteger)time {
    
    // 首页打开app不弹广告
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [userDefaults objectForKey:@"YGFirstLaunch"];
    
    if (!key) {
        [userDefaults setObject:@"ygFirst" forKey:@"YGFirstLaunch"];
        return;
    }
    
    // 初始化开屏广告
    [YGLaunchAd shareLaunchAd].waitDataDuration = 2; // 数据等待时间
    [YGLaunchAd shareLaunchAd].adDuration = time; // 倒计时时长
    
    // 获取网络广告
    [ALRequestDataFromServer postDataFromServerWithType:UrlLuanchAdType baseUrl:kWebMessageCenterUrl param:nil success:^(NSDictionary *result) {
        
        NSDictionary *resultBlock = result;
        if (result[@"data"] != nil || ![result[@"data"] isKindOfClass:[NSNull class]] )
        {
            ALClassModel *model = nil;
            
            // 解析
            resultBlock = [resultBlock dictionaryByReplacingNullsWithBlanks];
            resultBlock = resultBlock[@"data"];
            
            if ([resultBlock isKindOfClass:[NSArray class]]) {
                for (id obj in resultBlock) {
                    if (obj[@"cons"] != nil || ![obj[@"cons"] isKindOfClass:[NSNull class]]) {
                        for (id consObj in obj[@"cons"]) {
                            model = [ALClassModel mj_objectWithKeyValues:consObj];
                        }
                    }
                }
            }
            
            // 判断是否显示开屏广告
            NSDate *nowDate = [self getNowDate]; // 当前时间
            NSDate *startDate = [self dateWithString:model.ms_s_time]; // 开始时间
            NSDate *endDate = [self dateWithString:model.ms_e_time]; // 结束时间
            BOOL startBool = [nowDate compare:startDate] == NSOrderedDescending;
            BOOL endBool   = [nowDate compare:endDate] == NSOrderedAscending;
            
            if (startBool && endBool) {
                // 显示广告
                // 广告的url
                NSString *url = [NSString stringWithFormat:@"%@%@", kImageUrl, model.src];
                [self donwloadAdImageUrl:url completed:^{
                    //添加回调事件
                    [self YGLaunchViewWithModel:model];
                }];
            }
        }
        
    }failure:^(NSDictionary *error) {
        
    }];
}

+ (void)donwloadAdImageUrl:(NSString *)adImageUrl completed:(void(^)(void))completed {
    
    if (adImageUrl.length > 0) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        [manager downloadWithURL:[NSURL URLWithString:adImageUrl] options:0 progress:^(NSUInteger receivedSize, long long expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (finished && image) {
                [[YGLaunchAd shareLaunchAd] showLaunchAdWithAdImage:image]; // 添加开屏广告
                completed();
            }
        }];
    }
}

+ (void)YGLaunchViewWithModel:(ALClassModel *)model
{
    //各种回调
    [YGLaunchAd shareLaunchAd].launchBlock = ^(NSInteger tag) {
        switch (tag) {
            case YGLaunchAdType:
            {
                [[YiStatistics shareYiStatistics] onEvent:@"启动页广告" PageName:@"HomePage"];
                
                NSString *UIName = kUINamePlist[model.typeName];
                /*!AlDeanJumbParam类编辑参数param进行跳转*/
                NSDictionary *param = [AlDeanJumbParam getModelDtata:model];
                [ALJumpToAnotherUI pushToAnotherUI:UIName withNavCtrl:(UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController param:param];
            }
                break;
                
            case YGLaunchSkipType:
            {
                NSLog(@"点击跳过回调");
            }
                break;
                
            case YGLaunchDoneType:
            {
                NSLog(@"倒计时完成后的回调");
            }
                break;
                
            default:
                break;
        }
    };
}

+ (NSDate *)dateWithString:(NSString *)timeString
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    //    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:timeFormat];
    return [inputFormatter dateFromString:timeString];
}

/*
 * 获取当前时间格式:dd-MM-yyyy dd:MM:ss
 */
+ (NSDate *)getNowDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:timeFormat];
    return [formatter dateFromString:[formatter stringFromDate:date]];
}

/*
 * 时间比较
 */
+ (BOOL)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:timeFormat];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedDescending) {
        // dateA  is in the future
        return YES;
    }
    else if (result == NSOrderedAscending) {
        // dateB is in the past
        return NO;
    }
    // dateA == dateB
    return YES;
}

@end
