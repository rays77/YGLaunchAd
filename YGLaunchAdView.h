//
//  YGLaunchAdView.h
//  iOutletShopping
//
//  Created by Ray on 2017/2/7.
//  Copyright © 2017年 aolaigo. All rights reserved.
//
// 广告上的子控件(如跳过按钮等)

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YGAdType) {
    YGAdTypeLogo, // 带logo的广告
    YGAdTypeFullScreen, // 全屏的广告
};

typedef void(^YGLaunchAdViewSkip)();
typedef void(^YGLaunchAdViewAdImageViewTap)();
typedef void(^YGLaunchAdViewShowCompleted)(BOOL isShow);

@interface YGLaunchAdView : UIView

@property (nonatomic, strong) UIButton *skipBtn;
@property (nonatomic, strong) UIImageView *adImageView;
@property (nonatomic, strong) UIImage *adImage;

//@property (nonatomic, copy  ) NSString *adImageUrl;

@property (nonatomic, copy  ) YGLaunchAdViewSkip skipBlock;
@property (nonatomic, copy  ) YGLaunchAdViewAdImageViewTap adImageViewBlock;
@property (nonatomic, copy  ) YGLaunchAdViewShowCompleted adViewShowBlock;

- (instancetype)initWithFrame:(CGRect)frame
                       adType:(YGAdType)type;

@end
