//
//  uexCV_VoiceCell.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_VoiceCell.h"

#define uexCV_horn_height @20

#define uexCV_duration_view_radius 10
#define uexCV_duration_view_bgColor [UIColor whiteColor]
@implementation uexCV_VoiceCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)modifiedCellWithMessageData:(NSDictionary*)data userInfo:(uexCV_UserInfo *)info{
    [super modifiedCellWithMessageData:data userInfo:info];
    WS(ws);
    NSInteger duration=[data[@"duration"] integerValue];
    
    //horn
    UIImageView *hornView=[[UIImageView alloc]initWithImage:data[@"hornImage"]];
    [hornView setContentMode:UIViewContentModeScaleToFill];
    self.horn=[[UIImageView alloc]init];
    self.horn.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClick:)];
    [self.horn addGestureRecognizer:tapGes];
    
    
    [_horn addSubview:hornView];
    [hornView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(uexCV_horn_height);
        make.width.equalTo(uexCV_horn_height);
        make.left.equalTo(ws.horn.mas_left);
        make.top.equalTo(ws.horn.mas_top);
    }];
    [self.messageView addSubview:self.horn];
    [_horn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(uexCV_horn_height);
        make.edges.equalTo(ws.messageView).with.insets(uexCV_inner_padding);
        make.width.equalTo(uexCV_cell_container.mas_width).multipliedBy([ws widthMultipier:duration]);
    }];
    
    
    //durationView
    self.durationView=[[UILabel alloc] init];
    _durationView.layer.masksToBounds=YES;
    _durationView.layer.cornerRadius=uexCV_duration_view_radius;
    _durationView.backgroundColor=uexCV_duration_view_bgColor;
    _durationView.textAlignment=NSTextAlignmentCenter;
    [_durationView setText:[NSString stringWithFormat:@"%ld\"",(long)duration]];
    
    [_durationView setTextColor:uexCV_default_label_color];
    [_durationView setFont:[UIFont systemFontOfSize:uexCV_default_label_size]];
    [_durationView setNumberOfLines:1];
    [uexCV_cell_container addSubview:self.durationView];
    [_durationView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@(2*uexCV_duration_view_radius));
        make.height.mas_equalTo(@(2*uexCV_duration_view_radius));
        make.top.equalTo(uexCV_cell_container.mas_top).with.offset(uexCV_default_margin);
        if(!uexCV_from_you){
            make.right.mas_equalTo(ws.messageView.mas_left).with.offset(-2*uexCV_default_margin);
        }else{
            make.left.mas_equalTo(ws.messageView.mas_right).with.offset(2*uexCV_default_margin);
            
        }
    }];
    
    self.onClick=data[@"onClick"];
    
}


-(void)onClick:(id)sender{
    if(self.onClick){
        self.onClick();
    }
}


-(CGFloat)widthMultipier:(NSInteger)dur{
    CGFloat result=0.02;
    result=result+0.05*dur;
    if(result>uexCV_inner_max_width_multipier){
        result=uexCV_inner_max_width_multipier;
    }
    return result;
}
@end
