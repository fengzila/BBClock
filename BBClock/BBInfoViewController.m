//
//  BBInfoViewController.m
//  BBClock
//
//  Created by FengZi on 14-1-2.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBInfoViewController.h"
#import "BBSettingViewController.h"
#import "BBMainViewController.h"
#import "MobClick.h"
#import "BBFunction.h"

@implementation BBInfoViewController

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
    UIView *baseView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    baseView.backgroundColor = [UIColor whiteColor];
    self.view = baseView;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger hasEvaluated = [ud integerForKey:kHasEvaluated];
    if (!hasEvaluated)
    {
        int rate = [[MobClick getConfigParams:@"evaluateAlertRate"] intValue];
        int value = (arc4random() % 100) + 0;
        if (value <= rate)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[MobClick getConfigParams:@"evaluateNotifyContent"] delegate:self cancelButtonTitle:[MobClick getConfigParams:@"evaluateAlertCancelTitle"] otherButtonTitles:[MobClick getConfigParams:@"evaluateAlertConfirmTitle"], nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kHasEvaluated];
        
        [BBFunction goToAppStoreEvaluate];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(pushSettingVC)];
    self.navigationItem.rightBarButtonItem = settingItem;

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)initData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger hasSettedInfo = [ud integerForKey:kHasSettedInfo];
    
    _section1Show = NO;
    _section2Show = NO;
    
    _morningTime = 7 * 60 * 60 + 0 * 60;
    _nightTime = 20 * 60 * 60 + 30 * 60;
    
    _morningLastTime = 15 * 60;
    _nightLastTime = 15 * 60;
    
    _morningSong = @"晨光";
    _nightSong = @"致爱丽丝";
    if (hasSettedInfo != 0)
    {
        // 设置过
        NSInteger morningOpen = [ud integerForKey:kMorningSwitchType];
        if (morningOpen == switchTypeOpen)
        {
            _section1Show = YES;
        }
        
        NSInteger nightOpen = [ud integerForKey:kNightSwitchType];
        if (nightOpen == switchTypeOpen)
        {
            _section2Show = YES;
        }
        
        NSInteger morningTime = [ud integerForKey:kMorningTime];
        if (morningTime != 0)
        {
            _morningTime = morningTime;
        }
        
        NSInteger nightTime = [ud integerForKey:kNightTime];
        if (nightTime != 0)
        {
            _nightTime = nightTime;
        }
        
        NSInteger morningLastTime = [ud integerForKey:kMorningLastTime];
        if (morningLastTime != 0)
        {
            _morningLastTime = morningLastTime;
        }
        
        NSInteger nightLastTime = [ud integerForKey:kNightLastTime];
        if (nightLastTime != 0)
        {
            _nightLastTime = nightLastTime;
        }
        
        NSString *morningSong = [ud objectForKey:kMorningSong];
        if (morningSong != nil)
        {
            _morningSong = morningSong;
        }
        
        NSString *nightSong = [ud objectForKey:kNightSong];
        if (nightSong != nil)
        {
            _nightSong = nightSong;
        }
    }
    
    _settingTitle = @[@"早上", @"晚上"];
    _dataList = @[@"时间",@"曲目", @"时长"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        return 6;
    }
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section % 2 == 0 || (section == 1 && !_section1Show) || (section == 3 && !_section2Show) || section > 3)
    {
        return nil;
    }
    return @"设置";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section > 3)
    {
        return 0;
    }
    if (section % 2 == 0)
    {
        return 1;
    }
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    if (section % 2 == 0)
    {
        static NSString *CellWithIdentifier = @"titleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            switchView.tag = section;
            [switchView setOn:YES animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            if (section == 0)
            {
                [switchView setOn:_section1Show animated:NO];
            }
            else if (section == 2)
            {
                [switchView setOn:_section2Show animated:NO];
            }
        }
        
        if (section == 0)
        {
            cell.textLabel.text = [_settingTitle objectAtIndex:0];
        }
        else if (section == 2)
        {
            cell.textLabel.text = [_settingTitle objectAtIndex:1];
        }
        
        return cell;
    }
    else
    {
        static NSString *CellWithIdentifier = @"contentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifier];
        }
        
        cell.textLabel.text = [_dataList objectAtIndex:row];
        NSInteger showTime;
        NSString *songName;
        NSInteger lastTime;
        if (section == 1)
        {
            showTime = _morningTime;
            songName = _morningSong;
            lastTime = _morningLastTime;
        }
        else
        {
            showTime = _nightTime;
            songName = _nightSong;
            lastTime = _nightLastTime;
        }
        if (row == 0)
        {
            cell.detailTextLabel.text = [self timeFormat:showTime];
        }
        else if (row == 1)
        {
            // 曲目
            cell.detailTextLabel.text = [BBFunction getShowNameByName:songName];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (row == 2)
        {
            // 时长
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d分钟", lastTime / 60];
        }
        
        if ((section == 1 && !_section1Show) || (section == 3 && !_section2Show))
        {
            cell.hidden = YES;
        }
        
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    if ((section == 1 && !_section1Show) || (section == 3 && !_section2Show))
    {
        return 0;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((section == 1 && !_section1Show) || (section == 3 && !_section2Show))
    {
        return 0;
    }
    return 25;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    if ((section == 1 && row == 0) || (section == 3 && row == 0))
    {
        NSArray *hourArr;
        if (section == 3)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            [UIView setAnimationDuration:0.2];
            [_tableView setFrame:CGRectMake(0, -246, kDeviceWidth, kDeviceHeight)];
            [UIView commitAnimations];
            
            hourArr = @[@"17", @"18", @"19", @"20"];
        }
        else
        {
            hourArr = @[@"5", @"6", @"7", @"8", @"9"];
        }
        
        if (_datePicker != nil)
        {
            [_datePicker removeFromSuperview];
        }
        _pickerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - _datePicker.height)];
        _pickerBgView.backgroundColor = [UIColor blackColor];
        _pickerBgView.alpha = 0.3;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePicker)];
        [_pickerBgView addGestureRecognizer:tap];
        [self.view addSubview:_pickerBgView];
        
        // 初始化UIDatePicker
        _datePicker = [[BBDatePickerView alloc] initWithFrame:CGRectMake(0, kDeviceHeight, kDeviceWidth, 216 + 44) HourArr:hourArr];
        _datePicker.delegate = self;
        _datePicker.tag = section;
        
        NSInteger selectTime;
        if (section == 1)
        {
            selectTime = _morningTime;
        }
        else
        {
            selectTime = _nightTime;
        }
        
        NSInteger h = floorf( selectTime/ (60 * 60));
        NSInteger m = floorf((selectTime - h * 60 * 60) / 60);

        [_datePicker setInitValueC1:[NSString stringWithFormat:@"%d", h] C2:[NSString stringWithFormat:@"%d", m]];
        [self.view addSubview:_datePicker];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.2];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        {
            [_datePicker setFrame:CGRectMake(0, kDeviceHeight - 216 - 44 - 60, kDeviceWidth, 216 + 44 + 60)];
        }
        else
        {
            [_datePicker setFrame:CGRectMake(0, kDeviceHeight - 216 - 44, kDeviceWidth, 216 + 44)];
        }
        
        [_pickerBgView setFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - _datePicker.height)];

        [UIView commitAnimations];
    }
    else if ((section == 1 && row == 1) || (section == 3 && row == 1))
    {
        BBSongViewController *songVC = [[BBSongViewController alloc] init];
        songVC.section = section;
        songVC.delegate = self;
        
        [self.navigationController pushViewController:songVC animated:YES];
    }
    else if ((section == 1 && row == 2) || (section == 3 && row == 2))
    {
        if (section == 3)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            [UIView setAnimationDuration:0.2];
            [_tableView setFrame:CGRectMake(0, -246, kDeviceWidth, kDeviceHeight)];
            [UIView commitAnimations];
        }
        if (_datePicker != nil)
        {
            [_datePicker removeFromSuperview];
        }
        
        _pickerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - _datePicker.height)];
        _pickerBgView.backgroundColor = [UIColor blackColor];
        _pickerBgView.alpha = 0.3;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeLastPicker)];
        [_pickerBgView addGestureRecognizer:tap];
        [self.view addSubview:_pickerBgView];
        
        // 初始化UIDatePicker
        _lastTimePicker = [[BBLastTimePickerView alloc] initWithFrame:CGRectMake(0, kDeviceHeight, kDeviceWidth, 216 + 44)];
        _lastTimePicker.delegate = self;
        _lastTimePicker.tag = section;
        
        NSInteger selectTime;
        if (section == 1)
        {
            selectTime = _morningLastTime;
        }
        else
        {
            selectTime = _nightLastTime;
        }
        
        [_lastTimePicker setInitValue:[NSString stringWithFormat:@"%d", selectTime / 60]];
        [self.view addSubview:_lastTimePicker];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.2];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        {
            [_lastTimePicker setFrame:CGRectMake(0, kDeviceHeight - 216 - 44 - 60, kDeviceWidth, 216 + 44 + 60)];
        }
        else
        {
            [_lastTimePicker setFrame:CGRectMake(0, kDeviceHeight - 216 - 44, kDeviceWidth, 216 + 44)];
        }
        
        [_pickerBgView setFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - _datePicker.height)];
        
        [UIView commitAnimations];

    }
}

// 时间控件选中事件处理
- (void)selectedV1:(NSString*)v1 V2:(NSString*)v2
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key;
    NSInteger t = [v1 intValue] * 60 * 60 + [v2 intValue] *60;
    if (_datePicker.tag == 1)
    {
        // 早上
        key = kMorningTime;
        _morningTime = t;
    }
    else if(_datePicker.tag == 3)
    {
        // 晚上
        key = kNightTime;
        _nightTime = t;
    }
    [ud setInteger:t forKey:key];
    [ud setInteger:1 forKey:kDataModified];
    [ud synchronize];
    
    [_tableView reloadData];
}

// 持续时间
- (void)selectedLastTime:(NSString*)v
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key;
    NSInteger t = [v intValue] * 60;
    if (_lastTimePicker.tag == 1)
    {
        // 早上
        key = kMorningLastTime;
        _morningLastTime = t;
    }
    else if(_lastTimePicker.tag == 3)
    {
        // 晚上
        key = kNightLastTime;
        _nightLastTime = t;
    }
    [ud setInteger:t forKey:key];
    [ud setInteger:1 forKey:kDataModified];
    [ud synchronize];
    
    [_tableView reloadData];
}

- (void)removePicker
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2];
    [_datePicker setFrame:CGRectMake(0, kDeviceHeight, kDeviceWidth, 216 + 44)];
    [_tableView setFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    [UIView commitAnimations];
    
    [_pickerBgView removeFromSuperview];
}

- (void)removeLastPicker
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2];
    [_lastTimePicker setFrame:CGRectMake(0, kDeviceHeight, kDeviceWidth, 216 + 44)];
    [_tableView setFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    [UIView commitAnimations];
    
    [_pickerBgView removeFromSuperview];
}

- (void)switchChanged:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    UISwitch *switchControl = sender;
    NSInteger value = switchControl.on ? switchTypeOpen : switchTypeClosed;
    if (switchControl.tag == 0)
    {
        _section1Show = switchControl.on;
        [ud setInteger:value forKey:kMorningSwitchType];
        [ud setInteger:_morningTime forKey:kMorningTime];
        [ud setInteger:_morningLastTime forKey:kMorningLastTime];
        [ud setObject:_morningSong forKey:kMorningSong];
    }
    else if (switchControl.tag == 2)
    {
        _section2Show = switchControl.on;
        [ud setInteger:value forKey:kNightSwitchType];
        [ud setInteger:_nightTime forKey:kNightTime];
        [ud setInteger:_nightLastTime forKey:kNightLastTime];
        [ud setObject:_nightSong forKey:kNightSong];
    }
    
    [ud setInteger:1 forKey:kDataModified];
    // 设置为已更改过
    [ud setInteger:1 forKey:kHasSettedInfo];
    [ud synchronize];

    [_tableView reloadData];
    
}

- (void)setSongName:(NSString*)songName Section:(NSInteger)section
{
    NSLog(@"setSongNameType is %@, %d", songName, section);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [BBFunction getFilePath:songName type:@"mp3"];
    if(![fileManager fileExistsAtPath:filePath])
    {
        //如果不存在
        NSLog(@"%@ is not exist", songName);
        return;
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (section == 1)
    {
        // 早上
        _morningSong = songName;
        [ud setObject:_morningSong forKey:kMorningSong];
        
    }
    else
    {
        // 晚上
        _nightSong = songName;
        [ud setObject:_nightSong forKey:kNightSong];
    }
    
    [ud setInteger:1 forKey:kDataModified];
    [ud synchronize];
    [_tableView reloadData];
}

- (void)pushSettingVC
{
    BBSettingViewController *settingVC = [[BBSettingViewController alloc] init];
    
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (NSString*)timeFormat:(NSInteger)t
{
    NSInteger h = floorf(t / (60 * 60));
    NSInteger m = floorf((t - h * 60 * 60) / 60);
    
    NSString *str = [NSString stringWithFormat:@"%02d:%02d", h, m];
    return str;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
