//
//  BBSongViewController.m
//  BBClock
//
//  Created by FengZi on 14-1-3.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBSongViewController.h"
#import "BBInfoViewController.h"
#import "BBDescViewController.h"
#import "MobClick.h"
#import "BBFunction.h"

#define DELETE_DONE 0

@interface BBSongViewController ()

@end

@implementation BBSongViewController

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
    
    NSInteger segPaddingTop;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        _paddingTop = 55;
        segPaddingTop = 10;
    }
    else
    {
        _paddingTop = 55 + 66;
        segPaddingTop = 70;
    }
    
    NSDictionary *normalDic = [NSDictionary dictionaryWithObjectsAndKeys:kBlue,UITextAttributeTextColor,  [UIFont fontWithName:@"Helvetica" size:15.f],UITextAttributeFont, nil];
    NSDictionary *selectedDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,  [UIFont fontWithName:@"Helvetica" size:15.f],UITextAttributeFont, nil];
    
    NSArray *segmentedArray = @[@"本地音乐", @"网络音乐"];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedControl.frame = CGRectMake(kDeviceWidth / 2 - 250 / 2, segPaddingTop, 250, 40);
    [segmentedControl setTitleTextAttributes:normalDic forState:UIControlStateNormal];
    [segmentedControl setTitleTextAttributes:selectedDic forState:UIControlStateSelected];

    segmentedControl.selectedSegmentIndex = 0;//设置默认选择项索引
//    segmentedControl.tintColor = [UIColor redColor];
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;//设置样式
    [segmentedControl addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    [self refreshData];
    
    _localView = [[BBLocalSongView alloc] initWithFrame:CGRectMake(kDeviceWidth + 100, _paddingTop, kDeviceWidth, kDeviceHeight - 66) Data:_localData];
    _localView.delegate = self;
    [self.view addSubview:_localView];
    
    _netView = [[BBNetSongView alloc] initWithFrame:CGRectMake(kDeviceWidth + 100, _paddingTop, kDeviceWidth, kDeviceHeight - 66) Data:_netData];
    _netView.delegate = self;
    [self.view addSubview:_netView];
    
    [self showLocalView];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = backItem;
}


- (void)refreshData
{
    NSString *staticConfigPath = [NSString stringWithFormat:@"%@/staticConfig.plist", kConfigPath];
    NSMutableDictionary *staticConfig = [[[NSMutableDictionary alloc] initWithContentsOfFile:staticConfigPath] objectForKey:@"configSrc"];
    NSString *netSongVersion = [staticConfig objectForKey:@"netSongConfigVersion"];
    
    NSString *plistPath = [NSString stringWithFormat:@"%@/netSongConfig_%@.plist", kConfigPath, netSongVersion];
    NSMutableDictionary *data = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] objectForKey:@"list"];
    
    _localData = nil;
    _localData = [[NSMutableArray alloc] init];
    
    _netData = nil;
    _netData = [[NSMutableArray alloc] init];
    
    for (id v in data)
    {
        NSString *name = [v objectForKey:@"name"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [BBFunction getFilePath:name type:@"mp3"];
        if(![fileManager fileExistsAtPath:filePath])
        {
            // 不在本地
            NSString *strUrl = [NSString stringWithFormat:@"%@/%@.mp3", [v objectForKey:@"url"], name];
            strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:strUrl];
            
            NSDictionary *insertValue = v;
            [insertValue setValue:url forKey:@"url"];
            [_netData addObject:insertValue];
        }
        else
        {
            [_localData addObject:v];
        }
        
    }
}

- (void)segmentAction:(UISegmentedControl *)seg
{
    switch (seg.selectedSegmentIndex)
    {
        case 0:
            [self showLocalView];
            break;
            
        case 1:
            [self showNetView];
            break;
            
        default:
            break;
    }
}

- (void)showLocalView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.4];
    [_localView setFrame:CGRectMake(0, _paddingTop, kDeviceWidth, kDeviceHeight)];
    [_netView setFrame:CGRectMake(kDeviceWidth + 500, _paddingTop, kDeviceWidth, kDeviceHeight)];
    [UIView commitAnimations];
}

- (void)showNetView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.4];
    [_localView setFrame:CGRectMake(kDeviceWidth + 500, _paddingTop, kDeviceWidth, kDeviceHeight)];
    [_netView setFrame:CGRectMake(0, _paddingTop, kDeviceWidth, kDeviceHeight)];
    [UIView commitAnimations];
}

- (void)selectString:(NSString *)s
{   
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(setSongName:Section:)])
    {
        NSLog(@"popInfoVC");
        [self.delegate setSongName:s Section:_section];
    }
}

- (void)refreshView
{
    [self refreshData];
    [_localView refresh:_localData];
    [_netView refresh:_netData];
}

- (void)pushDescVC:(NSDictionary*)data
{
    
    BBDescViewController *descVC = [[BBDescViewController alloc] init];
    descVC.data = data;
    
    [self.navigationController pushViewController:descVC animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_localView.audioPlayer)
    {
        [_localView.audioPlayer stop];
        _localView.audioPlayer = nil;
    }
    
    [_netView viewDidDisappear];
}

@end
