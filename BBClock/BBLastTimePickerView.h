//
//  BBLastTimePickerView.h
//  BBClock
//
//  Created by FengZi on 14-1-6.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBLastTimePickerViewDelegate <NSObject>

- (void)selectedLastTime:(NSString*)v;
- (void)removeLastPicker;


@end

@interface BBLastTimePickerView : UIView<UIPickerViewDelegate, UIPickerViewDataSource>
{
@private
    NSMutableArray      *_dataList;
    UIPickerView        *_pickerView;
    UIToolbar           *toolBar;
    
    id <BBLastTimePickerViewDelegate> _delegate;
}

@property (nonatomic) id <BBLastTimePickerViewDelegate> delegate;

- (void)setInitValue:(NSString*)v;

@end
