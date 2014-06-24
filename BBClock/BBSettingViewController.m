//
//  BBSettingViewController.m
//  BBClock
//
//  Created by FengZi on 14-1-2.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBSettingViewController.h"
#import "BBAboutUsViewController.h"
#import "BBFunction.h"

@interface BBSettingViewController ()

@end

@implementation BBSettingViewController

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
    [self initData];
    
    UIView *baseView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    baseView.backgroundColor = [UIColor whiteColor];
    self.view = baseView;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)initData
{
//    _bgArr = @[@"自定义背景图片"];
    _otherArr = @[@"关于我们", @"去给我们一个评价吧^_^"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [_otherArr count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    if(section == 0)
    {
        static NSString *CellWithIdentifier = @"otherSetting";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = [_otherArr objectAtIndex:row];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    if (section == 0)
    {
        if (row == 0)
        {
            BBAboutUsViewController *aboutVC = [[BBAboutUsViewController alloc] init];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
        else if (row == 1)
        {
            [BBFunction goToAppStoreEvaluate];
        }
    }
    
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

@end
