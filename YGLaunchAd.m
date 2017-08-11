//
//  YGLuanchAd.m
//  iOutletShopping
//
//  Created by Ray on 17/1/19.
//  Copyright © 2017年 aolaigo. All rights reserved.
//

#import "YGLaunchAd.h"
#import "YGLaunchAdView.h"

@interface YGLaunchAd()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) YGLaunchAdView *adView;

@end

@implementation YGLaunchAd
{
    dispatch_source_t _waitDataTimer; // 数据等待定时器
    dispatch_source_t _skipTimer; // 倒计时定时器
}

static YGLaunchAd *instance = nil;
+ (YGLaunchAd *)shareLaunchAd {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.enterForegroundLaunch = NO; // 从后台进入时二次开屏
        self.waitDataDuration = 3; // 数据等待默认时间 
        self.adDuration = 5; // 广告倒计时默认时间
        [self setupLaunchAd]; // 添加系统启动图
        [self startWaitDataTimer]; // 开始数据等待
        
        __weak typeof(self) weakSelf = self;
        // 从后台启动通知，二次开屏
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            if (weakSelf.enterForegroundLaunch) {
//                [self setupLaunchAd]; // 添加系统启动图
//                [self startWaitDataTimer]; // 开始数据等待
            }
        }];
    }
    return self;
}

-(void)setupLaunchAd {
    
    // 新的window，做到与业务视图无干扰
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.hidden = NO;
    window.alpha = 1;
    self.window = window;
    
    self.launchImageView = [[YGLaunchAdImageView alloc] init];
    //添加系统启动图
    [self.window addSubview:self.launchImageView];
}

- (void)showLaunchAdWithAdImage:(UIImage *)adImage {
    
    __weak typeof(self) weakSelf = self;
    
    // 添加广告
    self.adView = [[YGLaunchAdView alloc] initWithFrame:self.window.bounds adType:YGAdTypeFullScreen];
    self.adView.backgroundColor = [UIColor whiteColor];
    
    // 成功展示了广告
    self.adView.adViewShowBlock = ^(BOOL isShow){
        if (isShow) {
            // 开始倒计时
            [weakSelf startSkipTimer];
        } else {
            // 广告展示失败
            [weakSelf removeWindow];
        }
    };
    
    // 点击了倒计时或时间到
    self.adView.skipBlock = ^(){
        if (weakSelf.launchBlock) {
            weakSelf.launchBlock(YGLaunchSkipType);
        }
        [weakSelf removeAdViewAnimate];
    };
    
    // 点击了广告
    self.adView.adImageViewBlock = ^(){
        if (weakSelf.launchBlock) {
            weakSelf.launchBlock(YGLaunchAdType);
        }
        [weakSelf removeAdViewAnimate];
    };
    
    self.adView.adImage = adImage;
    [self.window addSubview:self.adView];
}

- (void)startWaitDataTimer {
    
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _waitDataTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_waitDataTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_waitDataTimer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_waitDataDuration < 0)
            {
                if (_waitDataTimer) {
                    dispatch_source_cancel(_waitDataTimer);
                }
                // 数据已经显示，skipTimer不为nil
                if (_skipTimer == nil)
                {
                    [self removeWindow];
                }
            }
            
            _waitDataDuration--;
        });
    });
    dispatch_resume(_waitDataTimer);
}

- (void)startSkipTimer
{
    if(_waitDataTimer) {
        dispatch_source_cancel(_waitDataTimer);
        _waitDataTimer = nil;
    }
    
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _skipTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_skipTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_skipTimer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(_adDuration < 0)
            {
                // 完成
                if (_launchBlock) {
                    _launchBlock(YGLaunchDoneType);
                }
                
                if (_skipTimer) {
                     dispatch_source_cancel(_skipTimer);
                }
                [self removeAdViewAnimate];
            }
            // 倒计时
            [_adView.skipBtn setTitle:[NSString stringWithFormat:@"%ld跳过", _adDuration] forState:UIControlStateNormal];
            
            _adDuration--;
        });
    });
    dispatch_resume(_skipTimer);
}

- (void)removeAdViewAnimate {
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.window.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        self.window.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self removeWindow];
    }];
}

- (void)removeWindow {
    
    if(_waitDataTimer)
    {
        dispatch_source_cancel(_waitDataTimer);
        _waitDataTimer = nil;
    }
    
    if(_skipTimer)
    {
        dispatch_source_cancel(_skipTimer);
        _skipTimer = nil;
    }
    
    // 移除window上的所有子控件
    [self.window.subviews.copy enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.launchImageView.hidden = YES;
    self.launchImageView = nil;
    self.window.hidden = YES;
    self.window = nil;
    // 销毁
    if (!self.enterForegroundLaunch) instance = nil;
}

- (void)dealloc {
//    NSLog(@"%@ 销毁了=============", NSStringFromClass([self class]));
}

@end
