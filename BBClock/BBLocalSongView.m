//
//  BBLocalSongView.m
//  BBClock
//
//  Created by FengZi on 14-1-9.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBLocalSongView.h"
#import "MobClick.h"
#import "BBFunction.h"

@implementation BBLocalSongView

- (id)initWithFrame:(CGRect)frame Data:(NSMutableArray*)data
{
    self = [super initWithFrame:frame];
    if (self) {
        self.data = data;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 120) style:UITableViewStylePlain];
//        _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_bg"]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        UIView *tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 64 - 45, self.frame.size.width, 45)];
        tabbarView.backgroundColor = [UIColor whiteColor];
        [self addSubview:tabbarView];
        
        UIView *audioTapView = [[UIView alloc] initWithFrame:CGRectMake(tabbarView.width / 4 - 45 / 2, 0, 45, 45)];
        audioTapView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *audioTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(prePlay)];
        [audioTapView addGestureRecognizer:audioTap];
        [tabbarView addSubview:audioTapView];
        
        _audioBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        _audioBtn.frame=CGRectMake(tabbarView.width / 4 - 25 / 2 + 5, tabbarView.height / 2 - 25, 25, 25);
        [_audioBtn addTarget:self action:@selector(prePlay) forControlEvents:UIControlEventTouchUpInside];
        [_audioBtn setImage:[UIImage imageNamed:@"tabbar_play"] forState:UIControlStateNormal];
        [_audioBtn setImage:[UIImage imageNamed:@"tabbar_play_highlight"] forState:UIControlStateHighlighted];
        [tabbarView addSubview:_audioBtn];
        
        _audioLabel = [[UILabel alloc] initWithFrame:CGRectMake(_audioBtn.width / 2 - 50 / 2 - 5, _audioBtn.height - 5, 50, 25)];
        _audioLabel.backgroundColor = [UIColor clearColor];
        _audioLabel.textAlignment = NSTextAlignmentCenter;
        _audioLabel.textColor = kBlue;
        _audioLabel.font = [UIFont boldSystemFontOfSize:12];
        _audioLabel.text = @"试听";
        [_audioBtn addSubview:_audioLabel];
        
        UIView *selectTapView = [[UIView alloc] initWithFrame:CGRectMake(tabbarView.width * 3 / 4 - 45 / 2, 0, 45, 45)];
        selectTapView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBtnAction)];
        [selectTapView addGestureRecognizer:selectTap];
        [tabbarView addSubview:selectTapView];

        _selectBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.frame=CGRectMake(tabbarView.width * 3 / 4 - 30 / 2, tabbarView.height / 2 - 30, 30, 30);
        [_selectBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectBtn setImage:[UIImage imageNamed:@"tabbar_noSelect"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"tabbar_select_highlight"] forState:UIControlStateHighlighted];
        [tabbarView addSubview:_selectBtn];
        
        _selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(_selectBtn.width / 2 - 50 / 2, _selectBtn.height - 5, 50, 25)];
        _selectLabel.backgroundColor = [UIColor clearColor];
        _selectLabel.textAlignment = NSTextAlignmentCenter;
        _selectLabel.textColor = [UIColor grayColor];
        _selectLabel.font = [UIFont boldSystemFontOfSize:12];
        _selectLabel.text = @"选中";
        [_selectBtn addSubview:_selectLabel];
    }
    return self;
}

- (void)selectBtnAction
{
    if (!_selectSongName)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选中一首歌曲" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectString:)])
    {
        [self.delegate selectString:_selectSongName];
    }
    
    [_audioPlayer stop];
}

- (void)refresh:(NSMutableArray*)data
{
    self.data = data;
    [_tableView reloadData];
}


//播放
- (void)prePlay
{
    if (!_selectSongName)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选中一首歌曲" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if(_audioBtn.tag == 1)
    {
        // 停止
        [_audioBtn setImage:[UIImage imageNamed:@"tabbar_play"] forState:UIControlStateNormal];
        [_audioBtn setImage:[UIImage imageNamed:@"tabbar_play_highlight"] forState:UIControlStateHighlighted];
        _audioLabel.frame = CGRectMake(_audioBtn.width / 2 - 50 / 2 - 5, _audioBtn.height - 5, 50, 25);
        _audioBtn.tag = 2;
        [_audioPlayer stop];
//        [MobClick endEvent:@"music" primarykey:@"playMusic"];
    }
    else
    {
        NSString *filePath = [BBFunction getFilePath:_selectSongName type:@"mp3"];
        
        if (_audioPlayer)
        {
            _audioPlayer = nil;
        }
        //播放本地音乐
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        
        _audioPlayer.delegate = self;
        _audioPlayer.volume = 0.5;
        [_audioPlayer prepareToPlay];
        // 播放
        [_audioBtn setImage:[UIImage imageNamed:@"tabbar_pause"] forState:UIControlStateNormal];
        [_audioBtn setImage:[UIImage imageNamed:@"tabbar_pause_highlight"] forState:UIControlStateHighlighted];
        _audioLabel.frame = CGRectMake(_audioBtn.width / 2 - 50 / 2, _audioBtn.height - 5, 50, 25);
        _audioBtn.tag = 1;
        
        [_audioPlayer play];
        
        // 统计
        [MobClick event:@"playMusic"];
//        [MobClick beginEvent:@"music" primarykey:@"playMusic" attributes:[NSDictionary dictionaryWithObjectsAndKeys:_selectSongName, @"name", nil]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
//    {
//        return 2;
//    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 0)
    {
        return 0;
    }
    return [self.data count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 55;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section != 0)
//    {
//        return 55;
//    }
//    return 0;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    static NSString *CellWithIdentifier = @"localCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellWithIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [infoBtn setFrame:CGRectMake(0, 0, 25, 25)];
        [infoBtn addTarget:self action:@selector(infoBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        [infoBtn setBackgroundImage:[UIImage imageNamed:@"table_info"] forState:UIControlStateNormal];
        [infoBtn setBackgroundImage:[UIImage imageNamed:@"table_info_highlight"] forState:UIControlStateHighlighted];
        
        cell.accessoryView = infoBtn;
    }
    
    NSDictionary *data = [self.data objectAtIndex:row];
    
    if ([[data objectForKey:@"desc"] length] != 0)
    {
        cell.accessoryView.tag = row;
        [cell.accessoryView setHidden:NO];
    }
    else
    {
        [cell.accessoryView setHidden:YES];
    }
    
    cell.textLabel.text = [data objectForKey:@"name"];
    cell.detailTextLabel.text = [[data objectForKey:@"desc"] stringByReplacingOccurrencesOfString: @"\\n" withString:@" "];
    
    return cell;
}

- (void)infoBtnTouch:(id)sender
{
    UIButton *btn = sender;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushDescVC:)])
    {
        [self.delegate pushDescVC:[self.data objectAtIndex:btn.tag]];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    _selectSongName = [[self.data objectAtIndex:row] objectForKey:@"name"];
    
    [_selectBtn setImage:[UIImage imageNamed:@"tabbar_select"] forState:UIControlStateNormal];
    _selectLabel.textColor = kBlue;
    
    // 停止
    [_audioBtn setImage:[UIImage imageNamed:@"tabbar_play"] forState:UIControlStateNormal];
    [_audioBtn setImage:[UIImage imageNamed:@"tabbar_play_highlight"] forState:UIControlStateHighlighted];
    _audioLabel.frame = CGRectMake(_audioBtn.width / 2 - 50 / 2 - 5, _audioBtn.height - 5, 50, 25);
    _audioBtn.tag = 2;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
