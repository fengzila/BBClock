//
//  BBDescViewController.m
//  BBClock
//
//  Created by FengZi on 14-1-10.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBDescViewController.h"

@interface BBDescViewController ()

@end

@implementation BBDescViewController

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
    UIScrollView *baseView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    baseView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    baseView.delegate = self;
    self.view = baseView;
    
    NSInteger height = 0;
    
    NSString *metaDesc = [self.data objectForKey:@"desc"];
    NSString *metaOpportunity = [self.data objectForKey:@"opportunity"];
    NSArray *descArr = [metaDesc componentsSeparatedByString:@"\\n"];
    
    NSString *desc;
    
    for (int i = 0; i < [descArr count]; i++)
    {
        if (i == 0)
        {
            desc = [NSString stringWithFormat:@"    %@", [descArr objectAtIndex:i]];
        }
        else
        {
            desc = [NSString stringWithFormat:@"%@\n    %@", desc, [descArr objectAtIndex:i]];
        }
    }
    
    UILabel *descTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    descTitleLabel.textColor = kBlue;
    descTitleLabel.backgroundColor = [UIColor clearColor];
    descTitleLabel.text = @"乐曲简介";
    descTitleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:descTitleLabel];
    
    height += descTitleLabel.size.height;
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    descLabel.textColor = [UIColor blackColor];
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.text = desc;
    descLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:15];
    descLabel.adjustsFontSizeToFitWidth = YES;
    //设置一个行高上限
    CGSize size = CGSizeMake(kDeviceWidth, 2000);
    // 计算实际frame大小，并将label的frame变成实际大小
    CGSize labelSize = [desc sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    [descLabel setFrame:CGRectMake(20, height, kDeviceWidth - 40, labelSize.height)];
    [self.view addSubview:descLabel];
    
    height += descLabel.size.height;
    
    if ([metaOpportunity length] != 0)
    {
        NSArray *opportunityArr = [metaOpportunity componentsSeparatedByString:@"\\n"];
        
        NSString *opportunity;
        
        for (int i = 0; i < [opportunityArr count]; i++)
        {
            if (i == 0)
            {
                opportunity = [NSString stringWithFormat:@"    %@", [opportunityArr objectAtIndex:i]];
            }
            else
            {
                opportunity = [NSString stringWithFormat:@"%@\n    %@", desc, [opportunityArr objectAtIndex:i]];
            }
        }
        
        UILabel *opportunityTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height + 5, 300, 30)];
        opportunityTitleLabel.textColor = kBlue;
        opportunityTitleLabel.backgroundColor = [UIColor clearColor];
        opportunityTitleLabel.text = @"妈妈知道";
        opportunityTitleLabel.font = [UIFont systemFontOfSize:18];
        [self.view addSubview:opportunityTitleLabel];
        
        height += opportunityTitleLabel.size.height;
        
        UILabel *opportunityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        opportunityLabel.textColor = [UIColor blackColor];
        opportunityLabel.backgroundColor = [UIColor clearColor];
        opportunityLabel.text = opportunity;
        opportunityLabel.lineBreakMode = NSLineBreakByWordWrapping;
        opportunityLabel.numberOfLines = 0;
        opportunityLabel.font = [UIFont systemFontOfSize:15];
        opportunityLabel.adjustsFontSizeToFitWidth = YES;
        //设置一个行高上限
        CGSize opportunitySize = CGSizeMake(kDeviceWidth, 2000);
        // 计算实际frame大小，并将label的frame变成实际大小
        CGSize opportunityLabelSize = [opportunity sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:opportunitySize lineBreakMode:NSLineBreakByWordWrapping];
        [opportunityLabel setFrame:CGRectMake(20, height, kDeviceWidth - 40, opportunityLabelSize.height)];
        [self.view addSubview:opportunityLabel];
        
        height += opportunityLabel.size.height;
    }
    
    height += 20;
    
    baseView.contentSize = CGSizeMake(kDeviceWidth, height);
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
