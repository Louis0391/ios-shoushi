//
//  VcView.m
//  手势解锁01(基本界面搭界)
//
//  Created by hqc on 15/11/15.
//  Copyright © 2015年 hqc. All rights reserved.
//

#import "VcView.h"

@implementation VcView

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"Home_refresh_bg"];
    [image drawInRect:rect];
}


@end
