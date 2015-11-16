//
//  uexCV_VoiceCell.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_VoiceCell.h"
#import "uexCV_TableView.h"
#import "uexCV_ViewController.h"
#define uexCV_horn_height 20

#define uexCV_duration_view_radius 10
#define uexCV_duration_view_bgColor [UIColor whiteColor]



@interface uexCV_VoiceCell()

@end

@implementation uexCV_VoiceCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)modifiedCellWithMessageData:(uexCV_TableViewCellData *)data{
    [super modifiedCellWithMessageData:data];
    @weakify(self);
       
    //horn

    self.hornViews =[NSMutableArray array];
    self.horn=[[UIImageView alloc]init];
    [self.horn setContentMode:UIViewContentModeLeft];
    self.horn.userInteractionEnabled=YES;
    //UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClick:)];
    
    UITapGestureRecognizer *tgr=[[UITapGestureRecognizer alloc] init];
    [[tgr.rac_gestureSignal takeUntil:self.rac_prepareForReuseSignal]subscribeNext:^(id x) {
#warning TODO
    }];
    [self.horn addGestureRecognizer:tapGes];
    for(int i = 0;i<4;i++){
        UIImage *hornImg=[UIImage imageWithContentsOfFile:[[EUtility bundleForPlugin:@"uexConversationView"] pathForResource:[NSString stringWithFormat:@"voice%d",(i+1)] ofType:@"png"]];
        UIImageView * hornView =[[UIImageView alloc]initWithImage:hornImg];
        [hornView setFrame:CGRectMake(0, 0, uexCV_horn_height, uexCV_horn_height)];
        [hornView setContentMode:UIViewContentModeScaleToFill];

        [self.hornViews addObject:hornView];

    }
    
    self.isPlaying=NO;
    [self showHorn:uexCV_hornView_status_4];
    [self.horn setContentMode:UIViewContentModeLeft];
    [self.messageView addSubview:self.horn];
    [_horn mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.equalTo(@(uexCV_horn_height));
        make.edges.equalTo(self.messageView).with.insets(uexCV_inner_padding);
        make.width.equalTo(uexCV_cell_container.mas_width).multipliedBy([self widthMultipier:self.duration]);
    }];
    
    
    //durationView
    self.durationView=[[UILabel alloc] init];
    _durationView.layer.masksToBounds=YES;
    _durationView.layer.cornerRadius=uexCV_duration_view_radius;
    _durationView.backgroundColor=uexCV_duration_view_bgColor;
    _durationView.textAlignment=NSTextAlignmentCenter;
    [_durationView setText:[NSString stringWithFormat:@"%ld\"",(long)self.duration]];
    
    [_durationView setTextColor:uexCV_default_label_color];
    [_durationView setFont:[UIFont systemFontOfSize:uexCV_default_label_size]];
    [_durationView setNumberOfLines:1];
    [uexCV_cell_container addSubview:self.durationView];
    [_durationView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.width.mas_equalTo(@(2*uexCV_duration_view_radius));
        make.height.mas_equalTo(@(2*uexCV_duration_view_radius));
        make.top.equalTo(uexCV_cell_container.mas_top).with.offset(uexCV_default_margin);
        if(!uexCV_from_you){
            make.right.mas_equalTo(self.messageView.mas_left).with.offset(-2*uexCV_default_margin);
        }else{
            make.left.mas_equalTo(self.messageView.mas_right).with.offset(2*uexCV_default_margin);
            
        }
    }];
    

    [self.errorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        if(!uexCV_from_you){
            make.right.lessThanOrEqualTo(self.durationView.mas_left).with.offset(-2*uexCV_default_margin);
        }else{
            make.left.greaterThanOrEqualTo(self.durationView.mas_right).with.offset(2*uexCV_default_margin);
        }
    }];
    
}

-(void)stopPlaying{
    if(self.isPlaying){

        self.isPlaying=NO;
    }
    




    
    
}

-(void)onClick:(id)sender{
    if(self.data.onClick){

        [self.tableView.superViewController stopPlaying:YES];

        if(self.tableView.superViewController.currentPlayingIndex ==self.inCellIndex){
            self.tableView.superViewController.currentPlayingIndex=nil;
            
            return;
        }
        self.data.onClick();
        self.tableView.superViewController.currentPlayingIndex=self.inCellIndex;

        self.isPlaying=YES;
        
        [self cyc];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.duration*1000 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            self.isPlaying=NO;
            
        });


        
    }
}


-(CGFloat)widthMultipier:(CGFloat)dur{
    CGFloat result=0.02;
    result=result+0.05*dur;
    if(result>uexCV_inner_max_width_multipier){
        result=uexCV_inner_max_width_multipier;
    }
    if(result<0.05){
        result=0.1;
    }
    return result;
}



#pragma mark - horn animation

-(void)cyc{
    
    if(self.isPlaying){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self next];
            
            [self.tableView reloadRoselfAtIndexPaths:@[self.inCellIndex] withRowAnimation:UITableViewRowAnimationNone];
            [self cyc];
            
            
            
        });
    }else{
        [self showHorn:uexCV_hornView_status_4];
    }
}

-(void)next{
    switch (self.hornStatus) {
        case uexCV_hornView_status_1: {
            [self hideHorn:uexCV_hornView_status_1];
            [self showHorn:uexCV_hornView_status_2];
            break;
        }
        case uexCV_hornView_status_2: {
            [self hideHorn:uexCV_hornView_status_2];
            [self showHorn:uexCV_hornView_status_3];
            break;
        }
        case uexCV_hornView_status_3: {
            [self hideHorn:uexCV_hornView_status_3];
            [self showHorn:uexCV_hornView_status_4];
            break;
        }
        case uexCV_hornView_status_4: {
            [self hideHorn:uexCV_hornView_status_4];
            [self showHorn:uexCV_hornView_status_1];
            break;
        }
        default: {
            break;
        }
    }
}


-(void)hideHorn:(uexCV_hornView_status)status{
    UIImageView * hornView = ((UIImageView *)self.hornVieself[status]);
    [hornView removeFromSuperview];
}
-(void)showHorn:(uexCV_hornView_status)status{

    UIImageView * hornView = ((UIImageView *)self.hornVieself[status]);
    [_horn addSubview:hornView];

    self.hornStatus=status;
    //NSLog(@"%ld",self.hornStatus);
}

@end
