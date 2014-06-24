//
//  BBAboutUsViewController.m
//  BBClock
//
//  Created by FengZi on 14-1-4.
//  Copyright (c) 2014年 FengZi. All rights reserved.
//

#import "BBAboutUsViewController.h"

@interface BBAboutUsViewController ()

@end

@implementation BBAboutUsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    UIScrollView *baseView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    baseView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    baseView.delegate = self;
    self.view = baseView;
    
    NSString *contentStr = @"    2013年10月14日陪老婆去医院打算做孕检，不料宝宝早已经在老婆肚子里安营扎寨了，兴奋的我恨不得马上向全世界宣布我要当爸爸了，但调皮的宝宝用Ta的种种行为告诉我：“爸比，要低调”，先是可能宫外孕再是黄体酮过低······，小心翼翼的熬过了三个月危险期终于顺利的在医院建了大卡，第一次听到宝宝健康的消息我真是激动的不行，好吧，我承认宝宝太调皮了，这下总可以向全世界宣布了吧，就这样我终于如愿成为了众多小爸爸中的一员。\n    老婆第一次去孕妇学校上课，才知道原来现在就已经可以进行胎教了，其关键点在于早晚两次的声音刺激，早上播放音乐给宝宝听，是为了让Ta养成准时起床的生物钟，同理晚上则是让宝宝能够安稳的睡上一夜。胎教音乐主要是培养宝宝的好性格、提高智商和情商、提高艺术欣赏能力。最好听固定几首曲子，而且一定要舒缓、柔和，这样对宝宝听力有保护，还能加深宝宝的记忆。宝宝出生后，如果哭闹了，听到熟悉的音乐也会安静下来。其好处多多，也没多想，回家后马上实施，因为老师点名晚上就听《致爱丽丝》，所以我们也就默认了这首曲子，早上呢，就选择了一首比较安静的音乐《晨光》，可是每次都要打开音乐APP，然后选定音乐，然后自己计时15分钟，感觉好烦啊，这么懒惰的我怎么能容忍这种冗余重复的劳动呢，于是马上投入到了开发中，终于历时两周《胎教小闹钟》面世了，在此愿与各位准爸爸准妈妈分享。\n\n\n\n意见反馈\n\n微信:2263144619\n\n邮箱:2263144619@qq.com\n\n微博:http://weibo.com/3969065992";
    
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    content.textColor = [UIColor blackColor];
    content.backgroundColor = [UIColor clearColor];
    content.text = contentStr;
    content.lineBreakMode = NSLineBreakByWordWrapping;
    content.numberOfLines = 0;
    content.font = [UIFont systemFontOfSize:15];
    content.adjustsFontSizeToFitWidth = YES;
    //设置一个行高上限
    CGSize size = CGSizeMake(kDeviceWidth, 2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelSize = [contentStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    [content setFrame:CGRectMake(20, 20, kDeviceWidth - 40, labelSize.height + 20)];
//    [content setFrame:CGRectMake(20, 0, kDeviceWidth - 40, 600)];
    [self.view addSubview:content];
    
    baseView.contentSize = CGSizeMake(kDeviceWidth, content.height + 60);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
