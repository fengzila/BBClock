//
//  BBLastTimePickerView.m
//  BBClock
//
//  Created by FengZi on 14-1-6.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBLastTimePickerView.h"

@implementation BBLastTimePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        for (int i = 10; i <= 60; i++)
        {
            [_dataList addObject:[NSString stringWithFormat:@"%d", i]];
        }
        
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pickerView];
        
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,44)];
        toolBar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target: self action: @selector(done)];
        UIBarButtonItem *leftButton  = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target: self action: @selector(docancle)];
        UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
        NSArray *array = [[NSArray alloc] initWithObjects: leftButton, fixedButton, fixedButton, rightButton, nil];
        [toolBar setItems: array];
        
        [self addSubview:toolBar];
    }
    return self;
}

- (void)setInitValue:(NSString*)v
{
    int selectedIndex = [_dataList indexOfObject:v];
    [_pickerView selectRow:selectedIndex inComponent:0 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_dataList count];
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", [_dataList objectAtIndex:row]];
}


-(void)done
{
    [self.delegate removeLastPicker];
    
    NSString *selectedValue = [_dataList objectAtIndex:[_pickerView selectedRowInComponent:0]];
    
    
    NSLog(@"selectedValue is %@", selectedValue);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedLastTime:)])
    {
        [self.delegate selectedLastTime:selectedValue];
    }
}

- (void)docancle
{
    [self.delegate removeLastPicker];
}

@end
