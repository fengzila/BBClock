//
//  BBLocalSongView.h
//  BBClock
//
//  Created by FengZi on 14-1-9.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol BBLocalSongViewDelegate <NSObject>

- (void)selectString:(NSString*)s;

- (void)pushDescVC:(NSDictionary*)data;

@end

@interface BBLocalSongView : UIView<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>
{
@private
    NSString                *_selectSongName;
    UITableView             *_tableView;
    UIButton                *_audioBtn;
    UIButton                *_selectBtn;
    UILabel                 *_audioLabel;
    UILabel                 *_selectLabel;
    
    AVAudioPlayer           *_audioPlayer;
    
    id <BBLocalSongViewDelegate> _delegate;
}

@property (nonatomic) id <BBLocalSongViewDelegate> delegate;
@property (nonatomic) NSMutableArray* data;
@property (nonatomic) AVAudioPlayer* audioPlayer;

- (id)initWithFrame:(CGRect)frame Data:(NSMutableArray*)data;
- (void)refresh:(NSMutableArray*)data;
@end
