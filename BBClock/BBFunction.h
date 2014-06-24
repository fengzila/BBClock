//
//  BBFunction.h
//  BBClock
//
//  Created by FengZi on 14-1-15.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBFunction : NSObject
+ (void)goToAppStoreEvaluate;
+ (NSString*)getShowNameByName:(NSString*)s;
+ (NSString*)getFilePath:(NSString*)name type:(NSString*)type;
@end
