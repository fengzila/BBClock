//
//  BBNetSongView.h
//  BBClock
//
//  Created by FengZi on 14-1-9.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGdownloader.h"
#import <StoreKit/StoreKit.h>

@protocol BBNetSongViewDelegate <NSObject>

@optional
- (void)refreshView;
- (void)pushDescVC:(NSDictionary*)data;

@end

@interface BBNetSongView : UIView<UITableViewDelegate, UITableViewDataSource, SGdownloaderDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
@private
    UIView                  *_btnBgView;
    UIView                  *_percentBgView;
    UITableView             *_tableView;
    UIButton                *_downLoadBtn;
    UILabel                 *_downLoadLabel;
    UILabel                 *_percentLabel;
    
    UIActivityIndicatorView *_indicator;
    
    NSString                *_selectSongName;
    NSIndexPath             *_indexPath;
    
    CGRect                  _frame;
    
    BOOL                    _hasSelect;
    
    SGdownloader            *_downloader;
    NSString                *_waitToDeleteNetSongConfigName;
    NSString                *_newNetConfigVersion;
    
    id <BBNetSongViewDelegate> _delegate;
}

@property (nonatomic) id <BBNetSongViewDelegate> delegate;
@property (nonatomic) NSMutableArray* data;

- (id)initWithFrame:(CGRect)frame Data:(NSMutableArray*)data;
- (void)refresh:(NSMutableArray*)data;
- (void)viewDidDisappear;
@end
