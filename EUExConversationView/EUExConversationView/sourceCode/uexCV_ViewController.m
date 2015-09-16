 //
//  uexCV_ViewController.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_ViewController.h"
#import "uexCV_TableView.h"
#import "MJRefresh.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "EUExConversationView.h"
#import "amrFileCodec.h"



NSString  * const uexCV_text_cell_identifier = @"uexCV_text_cell";
NSString  * const uexCV_voice_cell_identifier = @"uexCV_voice_cell";

@interface uexCV_ViewController ()<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>

@property(nonatomic,strong) uexCV_TableView * tableView;
@property(nonatomic,strong) NSMutableArray * cells;
@property(nonatomic,strong) UIImage * bgImage;
@property(nonatomic,assign) BOOL isRefreshing;
@property(nonatomic,strong) AVAudioPlayer * player;
@end

@implementation uexCV_ViewController




-(instancetype)initWithFrame:(CGRect)frame
                       bgImg:(UIImage *)bgImg
                      meInfo:(uexCV_UserInfo *)me
                     youInfo:(uexCV_UserInfo *)you
                      extras:(NSDictionary *)extras
                     euexObj:(EUExConversationView *)euexObj{
    self=[super init];
    if(self){
        self.cells=[NSMutableArray array];
        self.frame=frame;
        self.bgImage=bgImg;
        self.meInfo=me;
        self.youInfo=you;
        self.extras=extras;
        self.euexObj=euexObj;
        [self initPlayer];
        
    }
    return self;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerKeyboardActions];
    self.view.frame=self.frame;
    self.tableView=[[uexCV_TableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.backgroundView=[[UIImageView alloc]initWithImage:self.bgImage];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection=NO;
    //self.tableView.estimatedRowHeight = 40;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.isRefreshing=YES;
        if(self.loadHistoryBlock){
            self.loadHistoryBlock();
        }

        [self delayedEndRefreshing:3000];

    }];
    
    
    
    [self.view addSubview:self.tableView];

}

-(void)viewDidDisappear:(BOOL)animated{
    [self deregisterKeyboardActions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addData:(NSArray*)data type:(uexConversationViewAddDataType)type{
    __block CGPoint oldOffset = self.tableView.contentOffset;
    CGFloat oldHeight = self.tableView.contentSize.height;
    BOOL isScrollToButtom = NO;

    
    switch (type) {
        case uexConversationViewAddDataNewMessage: {
            for(int i=0;i<data.count;i++){
                [self.cells addObject:[self cellForMessageData:data[i]]];
            }
            CGFloat distanceToBottom=oldHeight-self.frame.size.height-oldOffset.y;
            NSLog(@"dis:%f",distanceToBottom);
            if(distanceToBottom<200){
                
                isScrollToButtom=YES;
            }
            [self.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                NSLog(@"O:%f,N:%f",oldHeight,self.tableView.contentSize.height);
                if(isScrollToButtom){
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.cells.count-1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }else{
                    //oldOffset.y =self.tableView.contentSize.height-oldHeight;
                    [_tableView setContentOffset:oldOffset];
                }
            });

            
            break;
        }
        case uexConversationViewAddDataMessageHistory: {
            for(int i=0;i<data.count;i++){
                NSInteger j=data.count-1-i;
                [self.cells insertObject:[self cellForMessageData:data[j]] atIndex:0];
                
            }
            [self endRefreshing];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                oldOffset.y +=self.tableView.contentSize.height-oldHeight;
                [_tableView setContentOffset:oldOffset];
            });
            break;
        }
            
    }
    



}

/*
 
 data={
 from://
 timestamp
 bgImage://
 duration
 data://
 hornImage://
 onClick:
 */



-(void)delayedEndRefreshing:(NSInteger)msec{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(msec * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        if(self.isRefreshing){
            [self endRefreshing];
            
        }
    });
}

-(void)endRefreshing{
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    self.isRefreshing=NO;
}


-(uexCV_TableViewCell*)cellForMessageData:(NSDictionary *)data{
    


    NSInteger type=[data[@"type"] integerValue];
    NSMutableDictionary *msgData=[NSMutableDictionary dictionary];
    
    
    [msgData setValue:[UIImage imageWithContentsOfFile:[[_euexObj pluginBundle] pathForResource:@"qipao" ofType:@"png"]] forKey:@"bgImage"];
    NSInteger from =[data[@"from"] integerValue];
    [msgData setValue:@(from) forKey:@"from"];
    [msgData setValue:data[@"timestamp"] forKey:@"timestamp"];
    
    uexCV_TableViewCell *cell=nil;
    [msgData setValue:@(self.frame.size.width) forKey:@"maxWidth"];
    if(type == 1){
        [msgData setValue:data[@"data"] forKey:@"data"];
        cell=[[uexCV_TextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uexCV_text_cell_identifier];
    }
    if(type == 2){
        NSString * path=[_euexObj absPath:data[@"data"]];
        NSURL *url=[NSURL URLWithString:path];
        NSError *error =nil;
        [msgData setObject:[UIImage imageWithContentsOfFile:[_euexObj.pluginBundle pathForResource:@"audio" ofType:@"png"]] forKey:@"hornImage"];
        _player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        if(!error){
            [_player prepareToPlay];
            [msgData setValue:@([_player duration]) forKey:@"duration"];
            
        }
        _player=nil;
        error=nil;
        WS(ws);
        clickBlock block =^(){
            if(ws.player){
                if([ws.player isPlaying]){
                    [ws.player stop];
                }
                ws.player=nil;
            }
            NSError * anoError=nil;
            NSData *amrData=[NSData dataWithContentsOfFile:path];
            
            ws.player=[[AVAudioPlayer alloc]initWithData:DecodeAMRToWAVE(amrData) error:&anoError];
            [ws.player setDelegate:ws];
            
            [ws initPlayer];
            BOOL isReady=[ws.player prepareToPlay];
            if(!error && isReady){
               [ws.player play];
            }

        };
        [msgData setValue:block forKey:@"onClick"];
        cell=[[uexCV_VoiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uexCV_voice_cell_identifier];
        
    }
    
    [cell modifiedCellWithMessageData:msgData userInfo:(from==1)?_meInfo:_youInfo];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.cells.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    return (uexCV_TableViewCell*)self.cells[indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    uexCV_TableViewCell * cell=(uexCV_TableViewCell*)self.cells[indexPath.row];
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGFloat height = cell.containerView.frame.size.height+3;
    return height;

}


              

              
#pragma mark - AVAudioPlayer 


-(void)initPlayer{
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    audioSession = nil;
}


/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.player stop];
    self.player=nil;
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    [self.player stop];
    self.player=nil;
}
#pragma mark - Keyboard Action

-(void)registerKeyboardActions{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)deregisterKeyboardActions{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void)keyboardShow:(NSNotification *)notif
{
    CGRect keyBoardRect=[notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY=keyBoardRect.size.height;
    
    [UIView animateWithDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        self.view.transform=CGAffineTransformMakeTranslation(0, -deltaY);
    }];
}
-(void)keyboardHide:(NSNotification *)notif
{
    [UIView animateWithDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}


@end
