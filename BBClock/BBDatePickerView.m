//
//  BBDatePickerView.m
//  BBClock
//
//  Created by FengZi on 14-1-3.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBDatePickerView.h"

@implementation BBDatePickerView

- (id)initWithFrame:(CGRect)frame HourArr:(NSArray*)hourArr
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _hourArr = hourArr;
        
        _minutesArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < 60; i++)
        {
            [_minutesArr addObject:[NSString stringWithFormat:@"%d", i]];
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

- (void)setInitValueC1:(NSString*)c1 C2:(NSString*)c2
{
    int selectedC1Index = [_hourArr indexOfObject:c1];
    int selectedC2Index = [_minutesArr indexOfObject:c2];
    [_pickerView selectRow:selectedC1Index inComponent:0 animated:NO];
    [_pickerView selectRow:selectedC2Index inComponent:1 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [_hourArr count];
    }
    
    return [_minutesArr count];
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [NSString stringWithFormat:@"%@", [_hourArr objectAtIndex:row]];
    }
    
    return [NSString stringWithFormat:@"%@", [_minutesArr objectAtIndex:row]];
}


-(void)done
{
    [self.delegate removePicker];
    
    NSString *hourSelectedValue = [_hourArr objectAtIndex:[_pickerView selectedRowInComponent:0]];
    
    
    NSLog(@"select row is %d, hourSelectedValue is %@", [_pickerView selectedRowInComponent:0], hourSelectedValue);
    
    NSString *minuteSelectedValue = [_minutesArr objectAtIndex:[_pickerView selectedRowInComponent:1]];
    
    
    NSLog(@"select row is %d, strSelectedValue is %@", [_pickerView selectedRowInComponent:1], minuteSelectedValue);

    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedV1:V2:)])
    {
        [self.delegate selectedV1:hourSelectedValue V2:minuteSelectedValue];
    }
}

- (void)docancle
{
    [self.delegate removePicker];
}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    NSLog(@"didSelectRow ---- row is %d, component is %d", row, component);
//    NSString *strSelectedValue = [dataArr objectAtIndex:[pickerView selectedRowInComponent:0]];
//    int selectedIndex = [dataArr indexOfObject:strSelectedValue];
//    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedRow:withString:)]) {
//        [self.delegate selectedRow:selectedIndex withString:strSelectedValue];
//    }
//
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
