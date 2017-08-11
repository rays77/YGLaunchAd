//
//  YGLaunchAdView.m
//  iOutletShopping
//
//  Created by Ray on 2017/2/7.
//  Copyright © 2017年 aolaigo. All rights reserved.
//

#import "YGLaunchAdView.h"
#import "YGLaunchAd.h"
#import "UIImageView+WebCache.h"
#import "YGFileManager.h"

@interface YGLaunchAdView ()

@property (nonatomic, assign) YGAdType adType;
@property (nonatomic, strong) UIButton *touchBtn;

@end

@implementation YGLaunchAdView

- (instancetype)initWithFrame:(CGRect)frame adType:(YGAdType)type {
    if (self = [super initWithFrame:frame]) {
        
        _adType = type;
        
        // 启动广告
        _adImageView = ({
            UIImageView *imgView = [[UIImageView alloc] init];
            imgView.userInteractionEnabled = YES;
            CGRect rect = self.bounds;
            if (type == YGAdTypeLogo) {
                rect = CGRectMake(0, 0, YGMainWidth, YGMainHeight-100);
            }
            imgView.frame = rect;
            imgView;
        });
        [self addSubview:_adImageView];
        
        // 手势
        UITapGestureRecognizer *tap = ({
            UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adImageViewHandle:)];
            t;
        });
        [_adImageView addGestureRecognizer:tap];
        
        // 倒计时，跳过按钮
        _skipBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(YGMainWidth-20-36, 20, 36, 36);
            btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:11];
            btn.layer.cornerRadius = 18;
            btn.layer.masksToBounds = YES;
            btn;
        });
        [self addSubview:_skipBtn];
        
        _touchBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(YGMainWidth-10-70, 10, 70, 70);
            btn.backgroundColor = [UIColor clearColor];
            [btn addTarget:self action:@selector(skipHandle:) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self addSubview:_touchBtn];
    }
    return self;
}

- (void)setAdImage:(UIImage *)adImage {
    _adImage = adImage;
    if (_adImage) {
        self.adImageView.image = [self imageCompressForWidth:_adImage targetWidth:YGMainWidth];
    }
    
    if (_adViewShowBlock) {
        _adViewShowBlock(_adImage != nil);
    }
}

- (void)skipHandle:(UIButton *)sender {
    if (_skipBlock) {
        _skipBlock();
    }
}

- (void)adImageViewHandle:(UITapGestureRecognizer *)tap {
    if (_adImageViewBlock) {
        _adImageViewBlock();
    }
}

#pragma mark - 指定宽度按比例缩放
- (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)dealloc {
//    NSLog(@"%@ 销毁了=============", NSStringFromClass([self class]));
}

@end
