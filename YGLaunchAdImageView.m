//
//  YGLaunchAdImageView.m
//  iOutletShopping
//
//  Created by Ray on 2017/2/7.
//  Copyright © 2017年 aolaigo. All rights reserved.
//

#import "YGLaunchAdImageView.h"

@implementation YGLaunchAdImageView

- (instancetype)init
{
    if (self = [super init]) {
        
        self.frame = [UIScreen mainScreen].bounds;
        self.userInteractionEnabled = YES;
                self.image = [self launchImage];
//        self.image = [self createImage];
    }
    return self;
}

- (void)dealloc {
//    NSLog(@"%@ 销毁了=============", NSStringFromClass([self class]));
}

// 绘制一张白色图片
- (UIImage *)createImage
{
    UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, [UIScreen mainScreen].bounds);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIImage *)launchImage
{
    UIImage *imageP = [self launchImageWithType:@"Portrait"];
    if(imageP) return imageP;
    UIImage *imageL = [self launchImageWithType:@"Landscape"];
    if(imageL) return imageL;
    NSLog(@"获取LaunchImage失败!请检查是否添加启动图,或者规格是否有误.");
    return nil;
}
- (UIImage *)launchImageWithType:(NSString *)type
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = type;
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if([viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            if([dict[@"UILaunchImageOrientation"] isEqualToString:@"Landscape"])
            {
                imageSize = CGSizeMake(imageSize.height, imageSize.width);
            }
            if(CGSizeEqualToSize(imageSize, viewSize))
            {
                launchImageName = dict[@"UILaunchImageName"];
                UIImage *image = [UIImage imageNamed:launchImageName];
                return image;
            }
        }
    }
    return nil;
}

@end
