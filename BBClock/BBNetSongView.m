//
//  BBNetSongView.m
//  BBClock
//
//  Created by FengZi on 14-1-9.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBNetSongView.h"
#import "MobClick.h"
#import "NetworkUtil.h"

#define DELETE_DONE 0

@implementation BBNetSongView

- (id)initWithFrame:(CGRect)frame Data:(NSMutableArray*)data
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.data = data;
        
        _frame = self.frame;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _frame.size.width, _frame.size.height - 120) style:UITableViewStylePlain];
//        _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_bg"]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        _btnBgView = [[UIView alloc] initWithFrame:CGRectMake(0, _frame.size.height - 64 - 45, _frame.size.width, 45)];
        _btnBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_btnBgView];
        
        UIView *downTapView = [[UIView alloc] initWithFrame:CGRectMake(_btnBgView.width / 2 - 45 / 2, 0, 45, 45)];
        downTapView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *downTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downLoadAction)];
        [downTapView addGestureRecognizer:downTap];
        [_btnBgView addSubview:downTapView];
        
        _downLoadBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        _downLoadBtn.frame=CGRectMake(_btnBgView.width / 2 - 25 / 2, _btnBgView.height / 2 - 25, 25, 25);
        [_downLoadBtn addTarget:self action:@selector(downLoadAction) forControlEvents:UIControlEventTouchUpInside];
        [_downLoadBtn setImage:[UIImage imageNamed:@"tabbar_download_noSelect"] forState:UIControlStateNormal];
        [_downLoadBtn setImage:[UIImage imageNamed:@"tabbar_download_highlight"] forState:UIControlStateHighlighted];
        [_btnBgView addSubview:_downLoadBtn];
        
        _downLoadLabel = [[UILabel alloc] initWithFrame:CGRectMake(_downLoadBtn.width / 2 - 50 / 2, _downLoadBtn.height - 5, 50, 25)];
        _downLoadLabel.backgroundColor = [UIColor clearColor];
        _downLoadLabel.textAlignment = NSTextAlignmentCenter;
        _downLoadLabel.textColor = [UIColor grayColor];
        _downLoadLabel.font = [UIFont boldSystemFontOfSize:12];
        _downLoadLabel.text = @"下载";
        [_downLoadBtn addSubview:_downLoadLabel];
        
        _percentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, _frame.size.height - 64 - 45 + kDeviceHeight, self.frame.size.width, 45)];
        _percentBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_percentBgView];
        
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_percentBgView.width / 2 - 100 / 2, _percentBgView.height / 2 - 13, 100, 25)];
        _percentLabel.backgroundColor = [UIColor clearColor];
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        _percentLabel.textColor = kBlue;
        _percentLabel.font = [UIFont boldSystemFontOfSize:18];
        [_percentBgView addSubview:_percentLabel];
        
        [self showBtnBgView];
        
        [self checkNetData];
        
        if ([self.data count] == 0)
        {
            [_tableView setHidden:YES];
            [_downLoadBtn setHidden:YES];
            [_downLoadLabel setHidden:YES];
            UILabel *tips = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, _frame.size.width, 50)];
            tips.backgroundColor = [UIColor clearColor];
            tips.textAlignment = NSTextAlignmentCenter;
            tips.textColor = [UIColor blackColor];
            tips.lineBreakMode = NSLineBreakByWordWrapping;
            tips.numberOfLines = 0;
            tips.text = @"抱歉哦，暂时没有可下载的胎教音乐啦，我们会加油持续更新^_^";
            tips.font = [UIFont boldSystemFontOfSize:14];
            [self addSubview:tips];
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    }
    return self;
}

- (void)checkNetData
{
    if ([NetworkUtil getNetWorkStatus])
    {
        // 有网络
        NSLog(@"have net to connect");
        NSString *staticConfigPath = [NSString stringWithFormat:@"%@/staticConfig.plist", kConfigPath];
        NSMutableDictionary *staticConfig = [[[NSMutableDictionary alloc] initWithContentsOfFile:staticConfigPath] objectForKey:@"configSrc"];
        NSString *curNetSongConfigVersion = [staticConfig objectForKey:@"netSongConfigVersion"];
        
        _newNetConfigVersion = [MobClick getConfigParams:@"musicVersion"];
        NSLog(@"newNetConfigVersion is %@", _newNetConfigVersion);
        if ([_newNetConfigVersion length] == 0 || [_newNetConfigVersion isEqualToString: curNetSongConfigVersion])
        {
            // 不需要更新netSongConfig文件
            return;
        }
        
        _downloader = nil;
        
        NSString *systemConfigPath = [NSString stringWithFormat:@"%@/systemConfig.plist", kConfigPath];
        NSMutableDictionary *systemConfig = [[[NSMutableDictionary alloc] initWithContentsOfFile:systemConfigPath] objectForKey:@"config"];
        NSString *urlFromConfig = [systemConfig objectForKey:@"netSongConfigRootUrl"];
        NSString *newNetConfigName = [NSString stringWithFormat:@"netSongConfig_%@.plist", _newNetConfigVersion];
        NSString *strUrl = [NSString stringWithFormat:@"%@%@", urlFromConfig, newNetConfigName];
        strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:strUrl];
        
        // 删除过期的netSongConfig文件
        _waitToDeleteNetSongConfigName = [NSString stringWithFormat:@"%@/netSongConfig_%@.plist", kConfigPath, curNetSongConfigVersion];
        
        _downloader = [[SGdownloader alloc] initWithURL:url timeout:60];
        [_downloader setDownLoadFileName:newNetConfigName];
        [_downloader startWithDelegate:self];
        
        _indicator = [self createLoadingLayer];
        
        [self addSubview:_indicator];
        
        //开始显示Loading动画
        [_indicator startAnimating];
    }
    else
    {
        NSLog(@"no net to connect");
    }
}

- (UIActivityIndicatorView*)createLoadingLayer
{
    UIActivityIndicatorView *ret = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    // 设置显示样式,见UIActivityIndicatorViewStyle的定义
    ret.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    ret.backgroundColor = [UIColor whiteColor];
    
    // 设置显示位置
    [ret setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    
    // 设置背景透明
    ret.alpha = 1;
    
    return ret;
}

- (void)removeLoadingLayer
{
    if (_indicator)
    {
        //停止显示Loading动画
        [_indicator stopAnimating];
        [_indicator removeFromSuperview];
    }
}

- (void)refresh:(NSMutableArray*)data
{
    self.data = data;
    [_tableView reloadData];
}

- (void)showBtnBgView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.4];
    [_btnBgView setFrame:CGRectMake(0, _frame.size.height - 64 - 45, _frame.size.width, 45)];
    [_percentBgView setFrame:CGRectMake(0, _frame.size.height - 64 - 45 + kDeviceHeight, _frame.size.width, 45)];
    [UIView commitAnimations];
}

- (void)showPercentBgView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.4];
    [_btnBgView setFrame:CGRectMake(0, _frame.size.height - 64 - 45 + kDeviceHeight, _frame.size.width, 45)];
    [_percentBgView setFrame:CGRectMake(0, _frame.size.height - 64 - 45, _frame.size.width, 45)];
    [UIView commitAnimations];

}
- (void)downLoadAction
{
    if (!_hasSelect)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选中一首歌曲" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([[MobClick getConfigParams:@"openIAP"] intValue] == 1) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSInteger hasPaid = [ud integerForKey:kHasPaid];
        if (hasPaid == 0) {
            // 没有购买过音乐
            if ([SKPaymentQueue canMakePayments]) {
                _indicator = [self createLoadingLayer];
                
                _indicator.alpha = .85;
                
                [self addSubview:_indicator];
                
                //开始显示Loading动画
                [_indicator startAnimating];
                [self getProductInfo];
                return;
            } else {
                NSLog(@"失败，用户禁止应用内付费购买.");
                return;
            }
        }
    }
    
    _downloader = nil;
    _downloader = [[SGdownloader alloc] initWithURL:[[self.data objectAtIndex:[_indexPath row]] objectForKey:@"url"] timeout:60];
    [_downloader setDownLoadFileName:_selectSongName];
    [_downloader startWithDelegate:self];
    
    [self showPercentBgView];
    
    [MobClick event:@"downLoad"];
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
    
    static NSString *CellWithIdentifier = @"netCell";
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
    _indexPath = indexPath;
    
    [_downLoadBtn setImage:[UIImage imageNamed:@"tabbar_download"] forState:UIControlStateNormal];
    _downLoadLabel.textColor = kBlue;
    
    _hasSelect = YES;
}

#pragma mark - DownloadProcess
- (void)SGDownloadProgress:(float)progress Percentage:(NSInteger)percentage
{
    NSLog(@"SGDownloadProgress - %d------", percentage);
    
    _percentLabel.text = [NSString stringWithFormat:@"%d%%", percentage];
}

- (void)SGDownloadFinished:(NSData*)fileData
{
    NSLog(@"SGDownloadFinished-------%d", fileData.length);
    NSString *downLoadFileName = _downloader.downLoadFileName;
    if ([downLoadFileName hasPrefix: @"netSongConfig"])
    {
        NSLog(@"netConfig-------");
        //将数据保存到本地指定位置
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", kConfigPath, downLoadFileName];
        [fileData writeToFile:filePath atomically:YES];
        
        // 删除过期的netSongConfig
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:_waitToDeleteNetSongConfigName error:nil];
        
        // 修改staticConfig
        NSString *staticConfigPath = [NSString stringWithFormat:@"%@/staticConfig.plist", kConfigPath];
        NSMutableDictionary *staticConfig = [[[NSMutableDictionary alloc] initWithContentsOfFile:staticConfigPath] objectForKey:@"configSrc"];
        [staticConfig setObject:_newNetConfigVersion forKey:@"netSongConfigVersion"];
        NSDictionary *saveData = [NSDictionary dictionaryWithObject:staticConfig forKey:@"configSrc"];
        [saveData writeToFile:staticConfigPath atomically:YES];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshView)])
        {
            [self.delegate refreshView];
        }
        
    }
    else
    {
        if (fileData.length > 5000)
        {
            //将数据保存到本地指定位置
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", kSongPath, downLoadFileName];
            [fileData writeToFile:filePath atomically:YES];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(refreshView)])
            {
                [self.delegate refreshView];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"糟糕，文件找不到网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    if (_indicator)
    {
        //停止显示Loading动画
        [_indicator stopAnimating];
        [_indicator removeFromSuperview];
    }
    [self showBtnBgView];
    _hasSelect = NO;
    
    [_downLoadBtn setImage:[UIImage imageNamed:@"tabbar_download_noSelect"] forState:UIControlStateNormal];
    _downLoadLabel.textColor = [UIColor grayColor];
}
- (void)SGDownloadFail:(NSError*)error
{
    
    [_indicator removeFromSuperview];
    NSLog(@"progressCellDownloadFail");
    [self showBtnBgView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"没找到网络哦>_<||| " delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
    if (_indicator)
    {
        //停止显示Loading动画
        [_indicator stopAnimating];
        [_indicator removeFromSuperview];
    }
    
    [_downLoadBtn setImage:[UIImage imageNamed:@"tabbar_download_noSelect"] forState:UIControlStateNormal];
    _downLoadLabel.textColor = [UIColor grayColor];

    return;
}

- (void)getProductInfo {
    NSSet * set = [NSSet setWithArray:@[@"bbAlarmPay_allMusic"]];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

// 以上查询的回调函数
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        NSLog(@"无法获取产品信息，购买失败。");
        return;
    }
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"商品添加进列表");
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self removeLoadingLayer];
    
    // 从支付队列里移除
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // 成功交易
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:1 forKey:kHasPaid];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    [self removeLoadingLayer];
    
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"购买失败, code:%d", transaction.error.code);
    } else {
        NSLog(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self removeLoadingLayer];
    
    // 对于已购商品，处理恢复购买的逻辑
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // 成功交易
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:1 forKey:kHasPaid];
}

- (void)viewDidDisappear
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
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
