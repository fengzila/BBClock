//
//  BBInfoViewController.h
//  BBClock
//
//  Created by FengZi on 14-1-2.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBDatePickerView.h"
#import "BBSongViewController.h"
#import "BBLastTimePickerView.h"

@interface BBInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, BBDatePickerViewDelegate, BBSongViewControllerDelegate, UIScrollViewDelegate, BBLastTimePickerViewDelegate, UIAlertViewDelegate>
{
@private
    NSArray             *_dataList;
    NSArray             *_settingTitle;
    UITableView         *_tableView;
    BOOL                _section1Show;
    BOOL                _section2Show;
    BBDatePickerView    *_datePicker;
    UIView              *_pickerBgView;
    BBLastTimePickerView *_lastTimePicker;
    
    NSInteger           _morningTime;
    NSInteger           _nightTime;
    
    NSInteger           _morningLastTime;
    NSInteger           _nightLastTime;
    
    NSString            *_morningSong;
    NSString            *_nightSong;
}

typedef enum{
    switchTypeOpen = 1,
    switchTypeClosed
}switchType;
@end
