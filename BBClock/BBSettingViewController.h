//
//  BBSettingViewController.h
//  BBClock
//
//  Created by FengZi on 14-1-2.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
@private
    NSArray         *_bgArr;
    NSArray         *_otherArr;
}
@end
