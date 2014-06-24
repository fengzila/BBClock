//
//  NetworkUtil.m
//  BBClock
//
//  Created by FengZi on 14-1-10.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "NetworkUtil.h"

NSString *url = @"www.baidu.com";

@implementation NetworkUtil

//判断网络是否可用
+ (BOOL)getNetWorkStatus
{
    if ([[Reachability reachabilityWithHostName:url] currentReachabilityStatus] == NotReachable) {
        return NO;
    }else {
        return YES;
    }
}

/**
 获取网络类型
 return
 */
+ (NSString *)getNetWorkType
{
    Reachability *reachability = [Reachability reachabilityWithHostName:url];
    
    NSString *netWorkType;
    switch ([reachability currentReachabilityStatus]) {
        case ReachableViaWiFi:   //Wifi网络
            netWorkType = @"wifi";
            break;
        case ReachableViaWWAN:  //无线广域网
            netWorkType = @"wwan";
            break;
        default:
            netWorkType = @"no";
            break;
    }
    return netWorkType;
}

@end
