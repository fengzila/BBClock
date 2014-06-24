//
//  BBFunction.m
//  BBClock
//
//  Created by FengZi on 14-1-15.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBFunction.h"

@implementation BBFunction

+ (void)goToAppStoreEvaluate
{
    NSURL *url;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        url = [NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=795761890"];
    }
    else
    {
        url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id795761890?at=10l6dK"];
    }
    [[UIApplication sharedApplication] openURL:url];
}

+ (NSString*)getShowNameByName:(NSString*)s
{
    
    return s;
//    NSString *staticConfigPath = [NSString stringWithFormat:@"%@/staticConfig.plist", kConfigPath];
//    NSMutableDictionary *staticConfig = [[[NSMutableDictionary alloc] initWithContentsOfFile:staticConfigPath] objectForKey:@"configSrc"];
//    NSString *netSongVersion = [staticConfig objectForKey:@"netSongConfigVersion"];
//    
//    NSString *plistPath = [NSString stringWithFormat:@"%@/netSongConfigEnglish_%@.plist", kConfigPath, netSongVersion];
//    NSMutableDictionary *data = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] objectForKey:@"list"];
//    
//    for (id v in data)
//    {
//        NSString *name = [v objectForKey:@"name"];
//        
//        if ([name isEqualToString:s]) {
//            return [v objectForKey:@"showName"];
//        }
//    }
//    
//    return nil;
}

+ (NSString*)getFilePath:(NSString*)name type:(NSString*)type
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    
    BOOL existed = [fileManager fileExistsAtPath:resourcePath];
    if ( existed )
    {
        return resourcePath;
    }
    
    return [NSString stringWithFormat:@"%@/%@.%@", kSongPath, name, type];
}
@end
