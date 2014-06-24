//
//  NetworkUtil.h
//  BBClock
//
//  Created by FengZi on 14-1-10.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkUtil : NSObject
{
    
}

+ (BOOL)getNetWorkStatus;
+ (NSString *)getNetWorkType;

@end
