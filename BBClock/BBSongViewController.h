//
//  BBSongViewController.h
//  BBClock
//
//  Created by FengZi on 14-1-3.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBLocalSongView.h"
#import "BBNetSongView.h"

@protocol BBSongViewControllerDelegate <NSObject>

- (void)setSongName:(NSString*)songName Section:(NSInteger)section;

@end
@interface BBSongViewController : UIViewController<BBLocalSongViewDelegate, BBNetSongViewDelegate>
{
    NSArray                 *_nameArr;
    NSArray                 *_descArr;
    NSMutableArray          *_urlArr;
    UITableView             *_tableView;
    NSString                *_selectSongName;
    NSMutableArray          *_localData;
    NSMutableArray          *_netData;
    
    BBLocalSongView         *_localView;
    BBNetSongView           *_netView;
    
    NSInteger               _paddingTop;
    
    id <BBSongViewControllerDelegate> _delegate;
}

@property (nonatomic) id <BBSongViewControllerDelegate> delegate;
@property (nonatomic) NSUInteger section;

@end
