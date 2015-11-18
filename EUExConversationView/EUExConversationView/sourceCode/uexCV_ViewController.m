 //
//  uexCV_ViewController.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_ViewController.h"
#import "uexCV_TableView.h"

#import <AudioToolbox/AudioToolbox.h>

#import "EUExConversationView.h"
#import "amrFileCodec.h"
#import "uexCV_TableViewCellData.h"
#import <FDTemplateLayoutCell/FDTemplateLayoutCell.h>

NSString  * const uexCV_text_cell_identifier = @"uexCV_text_cell";
NSString  * const uexCV_voice_cell_identifier = @"uexCV_voice_cell";

@interface uexCV_ViewController ()<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>



@property (nonatomic,strong) UIImage * bgImage;
@property (nonatomic,assign) BOOL isRefreshing;
@property (nonatomic,strong)RACDisposable *endRefreshDisposable;


@end

@implementation uexCV_ViewController


-(void)deleteMessageByTimestamp:(long long)ts{
    NSMutableArray *tmp=[NSMutableArray array];
    for(uexCV_TableViewCellData *aCellData in self.cellData){
        if(aCellData.timestamp==ts){
            [tmp addObject:aCellData];
        }
    }
    for(uexCV_TableViewCellData *aCellData in tmp){
        [self.cellData removeObject:aCellData];
    }
    [self reloadTableView];
}

-(instancetype)initWithFrame:(CGRect)frame
                       bgImg:(UIImage *)bgImg
                      meInfo:(uexCV_UserInfo *)me
                     youInfo:(uexCV_UserInfo *)you
                      extras:(NSDictionary *)extras
                     euexObj:(EUExConversationView *)euexObj{
    self=[super init];
    if(self){
        self.cellData=[NSMutableArray array];
        self.frame=frame;
        self.bgImage=bgImg;
        self.meInfo=me;
        self.youInfo=you;
        self.extras=extras;
        self.euexObj=euexObj;
        self.keyboardOffsetY=0;
        [self setupPlayerConfig];
        
    }
    return self;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerKeyboardActions];
    self.view.frame=self.frame;
    self.tableView=[[uexCV_TableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.superViewController=self;
    self.tableView.backgroundView=[[UIImageView alloc]initWithImage:self.bgImage];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection=NO;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[uexCV_TextCell class] forCellReuseIdentifier:uexCV_text_cell_identifier];
    [self.tableView registerClass:[uexCV_VoiceCell class] forCellReuseIdentifier:uexCV_voice_cell_identifier];
    
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.isRefreshing=YES;

        RACSubject *delayedEndRefreshingSubject=[RACSubject subject];
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [delayedEndRefreshingSubject sendCompleted];
        }];
        @weakify(self);
        self.endRefreshDisposable =[delayedEndRefreshingSubject subscribeCompleted:^{
            @strongify(self);
            [self endRefreshing];
        }];
    }];
    @weakify(self);
    [RACObserve(self.tableView.mj_header, state) subscribeNext:^(id x) {
        @strongify(self);
        MJRefreshState state =(MJRefreshState)[x integerValue];
        switch (state) {
            case MJRefreshStateIdle:{
                [self headerRefreshStatusDidChange:@0];
                break;
            }
            case MJRefreshStatePulling:{
                [self headerRefreshStatusDidChange:@1];
                break;
            }
            case MJRefreshStateNoMoreData:{
                NSLog(@"no more data");
                break;
            }
            case MJRefreshStateRefreshing:{

                [self headerRefreshStatusDidChange:@2];
                break;
            }
            case MJRefreshStateWillRefresh:{
                NSLog(@"willrefresh");
                break;
            }

        }
    }];
    [self.view addSubview:self.tableView];
}

-(void)headerRefreshStatusDidChange:(NSNumber *)status{
    [self.euexObj callbackJsonWithName:@"onRefreshStatusChange" Object:@{@"type":@1,@"status":status}];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addData:(NSArray*)data{

    
    for(int i=0;i<data.count;i++){
        uexCV_TableViewCellData *aCellData=[self cellDataFromMessageData:data[i]];
        if(aCellData){
            [self.cellData addObject:aCellData];
        }
        
    }
    [self.cellData sortUsingComparator:^NSComparisonResult(uexCV_TableViewCellData *  _Nonnull obj1, uexCV_TableViewCellData *  _Nonnull obj2) {
        return obj1.timestamp>obj2.timestamp;
    }];
    
    [self reloadTableView];
    /*
    switch (type) {
        case uexConversationViewAddDataNewMessage: {
            for(int i=0;i<data.count;i++){
                //[self.cells addObject:[self cellForMessageData:data[i]]];
            }
            CGFloat distanceToBottom=oldHeight-self.frame.size.height-oldOffset.y;
            if(distanceToBottom<200){
                
                isScrollToButtom=YES;
            }
            [self.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                //NSLog(@"O:%f,N:%f",oldHeight,self.tableView.contentSize.height);
                if(isScrollToButtom){
                    NSInteger targetRow=self.cells.count-1;
                    if(targetRow>0){
                        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:targetRow inSection:0];
                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }

                }else{
                    //oldOffset.y =self.tableView.contentSize.height-oldHeight;
                    [_tableView setContentOffset:oldOffset];
                }
                [self.tableView reloadData];
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
                [self endRefreshing];
            });
            break;
        }
            
    }
    
     */


}



-(void)reloadTableView{
    CGPoint currentOffset = self.tableView.contentOffset;
    CGFloat currentHeight = self.tableView.contentSize.height;
    CGFloat distanceToBottom=currentHeight-self.tableView.frame.size.height-currentOffset.y;
    BOOL isScrollToButtom=(distanceToBottom<200);
    [self.tableView reloadData];
    if(isScrollToButtom){
        NSInteger targetRow=self.cellData.count-1;
        if(targetRow>0){
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:targetRow inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }else{
        //oldOffset.y =self.tableView.contentSize.height-oldHeight;
        [self.tableView setContentOffset:currentOffset];
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





-(void)endRefreshing{
    if(!self.isRefreshing){
        return;
    }
    [self reloadTableView];
    [self.tableView.mj_header endRefreshing];
    self.isRefreshing=NO;
    if(self.endRefreshDisposable){
        [self.endRefreshDisposable dispose];
        self.endRefreshDisposable=nil;
    }
    
}




-(uexCV_TableViewCellData *)cellDataFromMessageData:(NSDictionary *)dataDict{
    if(!dataDict || ![dataDict isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    uexCV_TableViewCellData *cellData = [[uexCV_TableViewCellData alloc]initWithDataDictionary:dataDict viewController:self];
    if(!cellData){
        return nil;
    }
    switch (cellData.attribution) {
        case uexCV_MessageAttributionSentMessage: {
            cellData.info=self.meInfo;
            break;
        }
        case uexCV_MessageAttributionReceivedMessage: {
            cellData.info=self.youInfo;
            break;
        }

    }
    if(cellData.type == uexCV_MessageTypeVoiceMessage){
        @weakify(self,cellData);
        cellData.onClickAction=^(){
            @strongify(self,cellData);
            [self stopPlaying];
            NSError *error = nil;
            NSData *amrData=[NSData dataWithContentsOfFile:cellData.data];
            AVAudioPlayer *player=[[AVAudioPlayer alloc]initWithData:DecodeAMRToWAVE(amrData) error:&error];
            player.delegate=self;
            self.player=player;
            BOOL prepareToPlay =[self.player prepareToPlay];
            if(!error && prepareToPlay){

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    [self.player play];
                });
                return YES;
            }else{

                return NO;
            }
        };
        
    }
    return cellData;
}
-(void)stopPlaying{
    
    if(self.player){
        if (self.player.isPlaying) {
            [self.player stop];
        }
        self.player=nil;
    }

}
/*
-(uexCV_TableViewCell*)cellForMessageData:(NSDictionary *)data{
    


    NSInteger type=[data[@"type"] integerValue];
    NSMutableDictionary *msgData=[NSMutableDictionary dictionary];
    
    NSInteger from =[data[@"from"] integerValue];
    [msgData setValue:@(from) forKey:@"from"];
    [msgData setValue:data[@"timestamp"] forKey:@"timestamp"];
    [msgData setValue:data[@"status"] forKey:@"status"];
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
        _player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        if(!error){
            [_player prepareToPlay];
            [msgData setValue:@([_player duration]) forKey:@"duration"];
            
        }
        _player=nil;
        error=nil;
        
        WS(ws);
        clickBlock block =^(){


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
    cell.tableView=self.tableView;
    [cell modifiedCellWithMessageData:msgData userInfo:(from==1)?_meInfo:_youInfo];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;

}
*/



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

    return self.cellData.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    uexCV_TableViewCell* cell=(uexCV_TableViewCell*)self.cells[indexPath.row];
    cell.inCellIndex=indexPath;
    return cell;
     */
    uexCV_TableViewCellData *aCellData =self.cellData[indexPath.row];
    switch (aCellData.type) {
        case uexCV_MessageTypeTextMessage: {
            uexCV_TextCell *cell =[self.tableView dequeueReusableCellWithIdentifier:uexCV_text_cell_identifier];
            if(!cell){
                cell=[[uexCV_TextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uexCV_text_cell_identifier];
            }
            cell.tableView=self.tableView;
            [cell modifiedCellWithMessageData:aCellData];
            return cell;
            break;
        }
        case uexCV_MessageTypeVoiceMessage: {
            uexCV_VoiceCell *cell =[self.tableView dequeueReusableCellWithIdentifier:uexCV_voice_cell_identifier];
            if(!cell){
                cell=[[uexCV_VoiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uexCV_voice_cell_identifier];
            }
            cell.tableView=self.tableView;
            [cell modifiedCellWithMessageData:aCellData];
            return cell;
            break;
        }

    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    uexCV_TableViewCellData *aCellData =self.cellData[indexPath.row];
    CGFloat height;
    switch (aCellData.type) {
        case uexCV_MessageTypeTextMessage: {
            height=[self.tableView fd_heightForCellWithIdentifier:uexCV_text_cell_identifier cacheByIndexPath:indexPath configuration:^(uexCV_TextCell *cell) {
                cell.tableView=self.tableView;
                [cell modifiedCellWithMessageData:aCellData];
            }];
            break;
        }
        case uexCV_MessageTypeVoiceMessage: {
            height =[self.tableView fd_heightForCellWithIdentifier:uexCV_voice_cell_identifier cacheByIndexPath:indexPath configuration:^(uexCV_VoiceCell *cell) {
                cell.tableView=self.tableView;
                [cell modifiedCellWithMessageData:aCellData];
            }];
            break;
        }

    }
    //height =height+3;
    return height;

}


              

              
#pragma mark - AVAudioPlayer 


-(void)setupPlayerConfig{
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
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification *notif) {
        CGRect keyBoardRect=[notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat deltaY=keyBoardRect.size.height;

        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
                CGFloat screenHeight=[EUtility screenHeight];
                CGRect tmpFrame=self.frame;
                tmpFrame.size.height=screenHeight-tmpFrame.origin.y-self.keyboardOffsetY-deltaY;
                
                self.view.frame=tmpFrame;
                self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
                [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height-1, 1, 1) animated:YES];
            }];


        });
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification *notif) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{

                self.view.frame=self.frame;
                self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
                [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height-1, 1, 1) animated:YES];
               
            }];

        });
    }];
    
}



@end
