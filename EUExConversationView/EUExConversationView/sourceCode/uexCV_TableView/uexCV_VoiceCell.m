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

#import <YYImage/YYImage.h>

@interface uexCV_VoiceCell()
@property (nonatomic,strong)YYAnimatedImageView *animateHornView;
@property (nonatomic,strong)UIImageView *staticHornView;
@property (nonatomic,strong)UITapGestureRecognizer *tgr;
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

       
    //horn
    NSMutableArray *imagePaths=[NSMutableArray array];
    for (int i = 0;i<4;i++) {
        [imagePaths addObject:[[EUtility bundleForPlugin:@"uexConversationView"] pathForResource:[NSString stringWithFormat:@"voice%d",(i+1)] ofType:@"png"]];
    }
    
    
    
    
    
    YYFrameImage *animateHornImage =[[YYFrameImage alloc]initWithImagePaths:imagePaths oneFrameDuration:0.3 loopCount:0];
    YYAnimatedImageView *animateHornView = [[YYAnimatedImageView alloc]initWithImage:animateHornImage];
    [animateHornView setFrame:CGRectMake(0, 0, uexCV_horn_height, uexCV_horn_height)];
    [animateHornView setContentMode:UIViewContentModeScaleToFill];
    self.animateHornView=animateHornView;
    
    UIImage *staticHornImage = [[UIImage alloc] initWithContentsOfFile:[[EUtility bundleForPlugin:@"uexConversationView"] pathForResource:@"voice4" ofType:@"png"]];
    
    UIImageView *staticHornView =[[UIImageView alloc]initWithImage:staticHornImage];
    [staticHornView setFrame:CGRectMake(0, 0, uexCV_horn_height, uexCV_horn_height)];
    [staticHornView setContentMode:UIViewContentModeScaleToFill];
    self.staticHornView=staticHornView;
    
    self.horn=[[UIImageView alloc]init];
    [self.horn setContentMode:UIViewContentModeLeft];
    self.horn.userInteractionEnabled=YES;
    [self.horn addSubview:self.animateHornView];
    [self.horn addSubview:self.staticHornView];

    UITapGestureRecognizer *tgr=[[UITapGestureRecognizer alloc] init];
    self.tgr=tgr;
    [[tgr.rac_gestureSignal takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        self.data.isPlaying=!self.data.isPlaying;
        if(self.data.isPlaying){
            BOOL tryToPlay= self.data.onClickAction();
            if(tryToPlay){
                [self startPlayingWork];
                
            }else{
                self.data.isPlaying=NO;
            }
        }
    }];
    [self.horn addGestureRecognizer:tgr];
    @weakify(self);
    [[RACObserve(self.data, isPlaying) distinctUntilChanged]
     subscribeNext:^(id x) {
        @strongify(self);
        BOOL isPlaying = [x boolValue];
        if(!isPlaying){
            [self stopPlayingWork];
        }

    }];
    
    

    


    [self.horn setContentMode:UIViewContentModeLeft];
    [self.messageView addSubview:self.horn];
    [_horn mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.equalTo(@(uexCV_horn_height));
        make.edges.equalTo(self.messageView).with.insets(uexCV_inner_padding);
        make.width.equalTo(uexCV_cell_container.mas_width).multipliedBy([self widthMultipier:self.data.duration]);
    }];
    
    
    //durationView
    self.durationView=[[UILabel alloc] init];
    _durationView.layer.masksToBounds=YES;
    _durationView.layer.cornerRadius=uexCV_duration_view_radius;
    _durationView.backgroundColor=uexCV_duration_view_bgColor;
    _durationView.textAlignment=NSTextAlignmentCenter;
    [_durationView setText:[NSString stringWithFormat:@"%ld\"",(long)self.data.duration]];
    
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
    //[self setNeedsLayout];
    //[self layoutIfNeeded];
}



-(void)startPlayingWork{
    for (uexCV_TableViewCellData *aCellData in self.tableView.superViewController.cellData) {
        if(aCellData.timestamp != self.data.timestamp && aCellData.isPlaying){
            aCellData.isPlaying = NO;
        }
    }
    self.animateHornView.hidden=NO;
    self.staticHornView.hidden=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.data.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.data.isPlaying=NO;
    });
}



-(void)stopPlayingWork{


    self.animateHornView.hidden=YES;
    self.staticHornView.hidden=NO;
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




@end
