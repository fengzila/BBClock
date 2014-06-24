//
//  BBMainViewController.m
//  BBClock
//
//  Created by FengZi on 14-1-2.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBMainViewController.h"
#import "BBInfoViewController.h"
#import "MobClick.h"
#import "BBFunction.h"

BBMainViewController *instance = nil;
@interface BBMainViewController ()
// 加载控制区
- (void)loadControllView;
@end

@implementation BBMainViewController

+ (BBMainViewController*)mainVCInstance
{
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LocalNotification" message:@"ttttt" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
    NSLog(@"loadMainView======");
    
    UIView *baseView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    baseView.backgroundColor = [UIColor clearColor];
    self.view = baseView;
    
    self.navigationController.delegate = self;
    
    // 添加背景图
    _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    _bgImgView.image = [UIImage imageNamed:@"bg_7"];
    [self.view addSubview:_bgImgView];
    [self changeBgImg];
    
    [self loadControllView];
    
    [self loadRestView];
    
    [self loadAdBanner];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(reloadViewData)];
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)changeBgImg
{
    int randValue = (arc4random() % 10) + 1;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:1.5];
    [_bgImgView setAlpha:0.3];
    [_bgImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_%d", randValue]]];
    [_bgImgView setAlpha:1];
    [UIView commitAnimations];
    
    if (_changeBgImgTimer)
    {
        [_changeBgImgTimer invalidate];
    }
    // 30s变换一次背景图片
    _changeBgImgTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(changeBgImg) userInfo:nil repeats:NO];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self)
    {
        // 只有主场景不显示导航条
        [navigationController setNavigationBarHidden:YES animated:animated];

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSInteger dataModified = [ud integerForKey:kDataModified];
        if (dataModified != 0)
        {
            // 通过导航返回主场景的，判断数据是否有过更改，如果有则刷新主场景视图
            [self refresh];
            [ud setInteger:0 forKey:kDataModified];
        }
    }
    else if ([navigationController isNavigationBarHidden])
    {
        [navigationController setNavigationBarHidden:NO animated:animated];
    }
}

// 获取当前的凌晨时间戳
- (NSInteger)nowTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:[NSDate date]];
    int hour = [comps hour];
    int min = [comps minute];
    int sec = [comps second];
    
    // 当前零点时间差
    return hour * 60 * 60 + min * 60 + sec;
}

// 刷新数据 基于设定的当前时间
- (void)refreshDataByNowTime:(NSInteger)nowTime
{
    _openCountDownTimer = NO;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    morningOpen = [ud integerForKey:kMorningSwitchType];
    nightOpen = [ud integerForKey:kNightSwitchType];
    
    if (morningOpen != switchTypeOpen && nightOpen != switchTypeOpen)
    {
        // 早晚都没有开启闹钟功能
        return;
    }
    
    _openCountDownTimer = YES;
    
    // 早上播放时间
    NSInteger morningTime = [ud integerForKey:kMorningTime];
    // 晚上播放时间
    NSInteger nightTime = [ud integerForKey:kNightTime];
    // 早上播放歌曲
    NSString *morningSong = [ud objectForKey:kMorningSong];
    // 晚上播放歌曲
    NSString *nightSong = [ud objectForKey:kNightSong];
    // 早上音乐播放时间
    NSInteger morningLastTime = [ud integerForKey:kMorningLastTime];
    // 晚上音乐播放时间
    NSInteger nightLastTime = [ud integerForKey:kNightLastTime];
    
    NSLog(@"morningSong is %@, nightSong is %@", morningSong, nightSong);
    
    if (nowTime == 0)
    {
        // 当前零点时间差 即真实时间
        nowTime = [self nowTime];
    }
    // 距离早上播放的时间差
    _morningPlayTime = [self computeTimeDiffSinceNow:morningTime nowTime:nowTime];
    // 距离晚上播放的时间差
    _nightPlayTime = [self computeTimeDiffSinceNow:nightTime nowTime:nowTime];
    
    if (morningOpen == switchTypeOpen && nightOpen != switchTypeOpen)
    {
        // 只开启早上
        _countDown = _morningPlayTime;
        _curMusic = morningSong;
        _playerDuration = morningLastTime;
    }
    else if (morningOpen != switchTypeOpen && nightOpen == switchTypeOpen)
    {
        // 只开启晚上
        _countDown = _nightPlayTime;
        _curMusic = nightSong;
        _playerDuration = nightLastTime;
    }
    else
    {
        if (_morningPlayTime < _nightPlayTime)
        {
            // 向早上倒计时
            _countDown = _morningPlayTime;
            _curMusic = morningSong;
            _playerDuration = morningLastTime;
        }
        else
        {
            _countDown = _nightPlayTime;
            _curMusic = nightSong;
            _playerDuration = nightLastTime;
        }
    }
    
    NSLog(@"morningTime is %d, nightTime is %d, curMusic is %@, playerDuration is %d, countDown is %d, _morningPlayTime is %d, _nightPlayTime is %d", morningTime, nightTime, _curMusic, _playerDuration, _countDown, _morningPlayTime, _nightPlayTime);
}

// 计算时间差
- (NSInteger)computeTimeDiffSinceNow:(NSInteger)t nowTime:(NSInteger)nowTime
{
//    int curTime = t;
    
    if (nowTime <= t)
    {
        return t - nowTime;
    }
    return t + 24 * 60 * 60 - nowTime;
}

// 刷新视图
- (void)refreshView
{
    NSLog(@"refreshView-------");
    
    [self animationViewOut:_controllBgView];
    [self animationViewIn:_restView];
    
    // 取消全部通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (!_openCountDownTimer)
    {
        // 没有开启
        _countDownLabel.text = @"还没有开启哦-_-|||";
        return;
    }
    
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownUpdate) userInfo:nil repeats:YES];
    
    // 开启通知
    if (morningOpen == switchTypeOpen)
    {
        [self beginNotifyTime:_morningPlayTime alertStr:@"早上好，美妙的一天开始啦，呼唤宝宝起床^_^"];
    }
    if (nightOpen == switchTypeOpen)
    {
        [self beginNotifyTime:_nightPlayTime alertStr:@"晚上好，告诉宝宝该睡觉啦^_^"];
    }
    
    _restSongNameLabel.text = [NSString stringWithFormat:@"%@", [BBFunction getShowNameByName:_curMusic]];

}

- (void)beginNotifyTime:(NSInteger)t alertStr:(NSString*)s
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification == nil)
    {
        return;
    }
    
    NSDate *now=[NSDate new];
    notification.fireDate=[now dateByAddingTimeInterval:t]; //提前0s钟
    notification.timeZone=[NSTimeZone defaultTimeZone];
    notification.repeatInterval = kCFCalendarUnitDay;
    notification.repeatCalendar = [NSCalendar autoupdatingCurrentCalendar];
    // 提示信息 弹出提示框
    notification.alertBody = s;
//    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.soundName= @"甜美舞曲.caf";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)loadControllView
{
    _controllBgView = [[UIView alloc] initWithFrame:CGRectMake(kDeviceWidth - 500, kDeviceHeight - 200, kDeviceWidth - 100, 120)];
    _controllBgView.backgroundColor = [UIColor colorWithRed:55/255.0 green:90/255.0 blue:84/255.0 alpha:0.4];
    [self.view addSubview:_controllBgView];
    
    // 添加播放暂停按钮
    _button= [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame=CGRectMake(10, 15, 30, 30);
    //[button setTitle:@"播放" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_button setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_controllBgView addSubview:_button];
    
    _musicNameLabel = [[BBMarqueeLabel alloc] initWithFrame:CGRectMake(40, 22, 170, 20) rate:15.0f andFadeLength:10.0f];
    _musicNameLabel.numberOfLines = 1;
    _musicNameLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    _musicNameLabel.backgroundColor = [UIColor clearColor];
    _musicNameLabel.textAlignment = NSTextAlignmentLeft;
    _musicNameLabel.textColor = [UIColor whiteColor];
    _musicNameLabel.font = [UIFont boldSystemFontOfSize:16];
//    _musicNameLabel.shadowColor = [UIColor grayColor];
    [_controllBgView addSubview:_musicNameLabel];
    
    _playingTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, _controllBgView.width - 30, 20)];
    _playingTimerLabel.backgroundColor = [UIColor clearColor];
    _playingTimerLabel.textAlignment = NSTextAlignmentLeft;
    _playingTimerLabel.textColor = [UIColor whiteColor];
    _playingTimerLabel.font = [UIFont boldSystemFontOfSize:16];
    [_controllBgView addSubview:_playingTimerLabel];
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setFrame:CGRectMake(180, 35, 43, 50)];
    [settingBtn addTarget:self action:@selector(pushInfoVC) forControlEvents:UIControlEventTouchUpInside];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"info_highlight"] forState:UIControlStateHighlighted];
    [_controllBgView addSubview:settingBtn];
}

// 加载休息视图
- (void)loadRestView
{
    _restView = [[UIView alloc] initWithFrame:CGRectMake(100, kDeviceHeight - 200, kDeviceWidth - 100, 120)];
    _restView.backgroundColor = [UIColor colorWithRed:55/255.0 green:90/255.0 blue:84/255.0 alpha:0.6];
    [self.view addSubview:_restView];
    
    _restTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, _restView.width - 30, 20)];
    _restTitleLabel.backgroundColor = [UIColor clearColor];
    _restTitleLabel.textAlignment = NSTextAlignmentLeft;
    _restTitleLabel.textColor = [UIColor whiteColor];
    _restTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    _restTitleLabel.text = @"休息中...";
    [_restView addSubview:_restTitleLabel];
    
    _restSongNameLabel = [[BBMarqueeLabel alloc] initWithFrame:CGRectMake(90, 15, 125, 20) rate:15.0f andFadeLength:10.0f];
    _restSongNameLabel.numberOfLines = 1;
    _restSongNameLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    _restSongNameLabel.backgroundColor = [UIColor clearColor];
    _restSongNameLabel.textAlignment = NSTextAlignmentLeft;
    _restSongNameLabel.textColor = [UIColor whiteColor];
    _restSongNameLabel.font = [UIFont boldSystemFontOfSize:16];
    [_restView addSubview:_restSongNameLabel];
    
    _countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 45, _restView.width - 30, 20)];
    _countDownLabel.backgroundColor = [UIColor clearColor];
    _countDownLabel.textAlignment = NSTextAlignmentLeft;
    _countDownLabel.textColor = [UIColor whiteColor];
    _countDownLabel.font = [UIFont boldSystemFontOfSize:16];
//    showLabel.shadowColor = [UIColor grayColor];
    _countDownLabel.text = @"";
    [_restView addSubview:_countDownLabel];
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setFrame:CGRectMake(180, 30, 43, 50)];
    [settingBtn addTarget:self action:@selector(pushInfoVC) forControlEvents:UIControlEventTouchUpInside];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"info_highlight"] forState:UIControlStateHighlighted];
    [_restView addSubview:settingBtn];
}

- (void)loadAdBanner
{
    int rand = (arc4random() % 100) + 0;
    NSLog(@"rand = %d", rand);
    if (rand > [[MobClick getConfigParams:@"openIADRate"] intValue]) {
        return;
    }
    
    _adBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad unit ID.
    _adBannerView.adUnitID = MY_BANNER_UNIT_ID;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    _adBannerView.rootViewController = self;
    [self.view addSubview:_adBannerView];
    
    // Initiate a generic request to load it with an ad.
    [_adBannerView loadRequest:[GADRequest request]];
}

//封装系统加载函数
- (void)loadMusic:(NSString*)name type:(NSString*)type
{
    NSString *filePath = [BBFunction getFilePath:name type:type];

    //播放本地音乐
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    
    _audioPlayer.delegate = self;
    _audioPlayer.volume = 0.5;
    // 单曲循环
    _audioPlayer.numberOfLoops = -1;
    [_audioPlayer prepareToPlay];
    
    NSLog(@"songName is %@", name);
}

- (void)animationViewOut:(UIView*) view
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.6];
    [view setFrame:CGRectMake(800, kDeviceHeight - 180, kDeviceWidth - 100, 80)];
    [UIView commitAnimations];
}

- (void)animationViewIn:(UIView*) view
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.6];
    [view setFrame:CGRectMake(kDeviceWidth - 540, kDeviceHeight - 180, 540, 80)];
    [UIView commitAnimations];
}

- (void)countDownUpdate
{
    _countDown--;
    if (_countDown <= 0)
    {
        [self timerPlay];
    }
    else
    {
        _countDownLabel.text = [NSString stringWithFormat:@"%@", [self timeFormat:_countDown]];
    }
}

- (NSString*)timeFormat:(NSInteger)t
{
    NSInteger h = floorf(t / (60 * 60));
    NSInteger m = floorf((t - h * 60 * 60) / 60);
    NSInteger s = floorf(t - h * 60 * 60 - m * 60);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
}

- (void)timerPlay
{
    [self loadMusic:_curMusic type:@"mp3"];
    
    [self animationViewIn:_controllBgView];
    [self animationViewOut:_restView];
    [_button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    _musicNameLabel.text = _curMusic;

    [_controllBgView addSubview:_musicNameLabel];
    [_audioPlayer play];

    // 开启时间周期
    _playerTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
    
    if (_countDownTimer)
    {
        [_countDownTimer invalidate];
    }
}

- (void)timerUpdate
{
    if (!_audioPlayer.playing)
    {
        return;
    }
    _playerDuration -= 1;
    _playingTimerLabel.text = [NSString stringWithFormat:@"%@", [self timeFormat:_playerDuration]];
    if (_playerDuration <= 0)
    {
        [self timerStop];
//        [self refreshView];
        [self refresh];
    }
}

- (void)timerStop
{
    NSLog(@"timer stop========");
    [self animationViewIn:_restView];
    [self animationViewOut:_controllBgView];
    _playingTimerLabel.text = nil;
    [_audioPlayer stop];
    
    [_playerTimer invalidate];
}

//播放
- (void)play:(UIButton*)button
{
    
    if(_audioPlayer.playing)
    {
        // 暂停
        [button setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [_audioPlayer pause];
    }
    else
    {
        // 播放
        [button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_audioPlayer play];
    }
    
}

#pragma mark - Target Action
- (void)pushInfoVC
{
    BBInfoViewController *infoVC = [[BBInfoViewController alloc] init];

    [self.navigationController pushViewController:infoVC animated:YES];

}

#pragma mark -
#pragma mark yaoyiyao
- (BOOL)canBecomeFirstResponder
{
    return YES;// default is NO
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self changeBgImg];
    NSLog(@"开始摇动手机");
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
//    [self play:_button];
    NSLog(@"stop");
}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
//    [self play:_button];
    NSLog(@"取消");
}

- (void)reloadViewData
{
    NSLog(@"reloadData");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    instance = self;
    
    NSLog(@"mainViewDidLoad");
	
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger newUser = [ud integerForKey:kNewUser];
    if (newUser == 0)
    {
        // 新安装用户
        // 创建音乐文件目录
        [self mkdir:kSongPath];
        
        [ud setInteger:1 forKey:kNewUser];
        
        // 拷贝song文件
        [self copyFileByName:@"晨光.mp3" Path:kSongPath];
        [self copyFileByName:@"致爱丽丝.mp3" Path:kSongPath];
        
        // 创建配置文件目录
        [self mkdir:kConfigPath];
        [self copyFileByName:@"systemConfig.plist" Path:kConfigPath];
        [self copyFileByName:@"netSongConfig_1.plist" Path:kConfigPath];
        [self copyFileByName:@"staticConfig.plist" Path:kConfigPath];
        
        NSInteger morningIsOpen = switchTypeOpen;
        NSInteger nightIsOpen = switchTypeOpen;
        
        int morningTime = 7 * 60 * 60 + 0 * 60;
        int nightTime = 20 * 60 * 60 + 30 * 60;
        
        int morningLastTime = 15 * 60;
        int nightLastTime = 15 * 60;
        
        NSString *morningSong = @"晨光";
        NSString *nightSong = @"致爱丽丝";
        
        [ud setInteger:morningIsOpen forKey:kMorningSwitchType];
        [ud setInteger:morningTime forKey:kMorningTime];
        [ud setInteger:morningLastTime forKey:kMorningLastTime];
        [ud setObject:morningSong forKey:kMorningSong];
        
        [ud setInteger:nightIsOpen forKey:kNightSwitchType];
        [ud setInteger:nightTime forKey:kNightTime];
        [ud setInteger:nightLastTime forKey:kNightLastTime];
        [ud setObject:nightSong forKey:kNightSong];
        
        // 设置为已更改过
        [ud setInteger:1 forKey:kHasSettedInfo];
        [ud synchronize];
    }
    
    [self refresh];
}

- (void)mkdir:(NSString*)path
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        // 创建Song文件夹
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)copyFileByName:(NSString*)name Path:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获取程序包中相应文件的路径
    NSString *file1Path = [path stringByAppendingPathComponent:name];
    NSString *data1Path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:[NSString stringWithFormat:@"/%@", name]];
    NSError *error1;
    if([fileManager copyItemAtPath:data1Path toPath:file1Path error:&error1])
    {
        NSLog(@"copy %@ success", name);
//        [fileManager removeItemAtPath:data1Path error:nil];
    }
    else
    {
        NSLog(@"%@", error1);
    }
}

- (void)refresh
{
    NSLog(@"refresh-----------");
    
    if(_audioPlayer.playing)
    {
        return;
    }
    // 关闭定时器
    if(_countDownTimer)
    {
        [_countDownTimer invalidate];
        _countDownTimer = nil;
    }
    
    // 重新计算数据
    // 向前推一个小时计算时间最近的歌曲播放时间
    [self refreshDataByNowTime:[self nowTime] - 60 * 60];
    if (!_openCountDownTimer)
    {
        [self refreshView];
        return;
    }
    NSInteger playerDuration = _playerDuration;
    [self refreshDataByNowTime:[self nowTime] - playerDuration];
    if (_countDown <= playerDuration)
    {
        [self timerPlay];
    }
    else
    {
        // 超出歌曲的播放时间后再进入应用将不再播放
        [self refreshDataByNowTime:0];
        [self refreshView];
    }
}

// 接受通知
- (void)didReceiveLocalNotification
{
}

- (void)applicationWillEnterForeground
{
    NSLog(@"applicationWillEnterForeground----");
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
