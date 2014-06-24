//
//  BBDatePickerView.h
//  BBClock
//
//  Created by FengZi on 14-1-3.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBDatePickerViewDelegate <NSObject>

- (void)selectedV1:(NSString*)v1 V2:(NSString*)v2;
- (void)removePicker;

@end

@interface BBDatePickerView : UIView<UIPickerViewDelegate, UIPickerViewDataSource>
{
@private
    UIPickerView        *_pickerView;
    NSMutableArray      *_minutesArr;
    NSArray             *_hourArr;
    UIToolbar           *toolBar;
    
    id <BBDatePickerViewDelegate> _delegate;
}

@property (nonatomic) id <BBDatePickerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame HourArr:(NSArray*)hourArr;
- (void)setInitValueC1:(NSString*)c1 C2:(NSString*)c2;

@end
