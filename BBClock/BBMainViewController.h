//
//  BBMainViewController.h
//  BBClock
//
//  Created by FengZi on 14-1-2.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BBMarqueeLabel.h"
#import "GADBannerView.h"

@interface BBMainViewController : UIViewController<AVAudioPlayerDelegate, UINavigationBarDelegate, UINavigationControllerDelegate>
{
@private
    AVAudioPlayer       *_audioPlayer;
    UIImageView         *_bgImgView;
    UIView              *_controllBgView;
    UIView              *_restView;
    UIButton            *_button;
    BBMarqueeLabel      *_musicNameLabel;
    NSString            *_curMusic;
    
    NSTimer             *_playerTimer;
    int                 _playerDuration;               //音乐的播放时间
    NSTimer             *_countDownTimer;
    NSInteger           _countDown;
    BOOL                _openCountDownTimer;
    NSTimer             *_changeBgImgTimer;
    
    NSInteger           _morningPlayTime;
    NSInteger           _nightPlayTime;
    
    UILabel             *_playingTimerLabel;
    UILabel             *_countDownLabel;
    UILabel             *_restTitleLabel;
    BBMarqueeLabel      *_restSongNameLabel;
    
    NSInteger           morningOpen;
    NSInteger           nightOpen;
    
    GADBannerView       *_adBannerView;
}

//@property (nonatomic) NSTimer *countDownTimer;

- (void)didReceiveLocalNotification;
- (void)applicationWillEnterForeground;
+ (BBMainViewController*) mainVCInstance;
@end
