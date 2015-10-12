//
//  uexCV_TableViewCell.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_TableViewCell.h"
#import "uexCV_Bubble.h"
#import "uexCV_TableView.h"
#import "uexCV_ViewController.h"
#import "EUExConversationView.h"

#define uexCV_nickname_label_color [UIColor uexCV_colorFromHtmlString:@"#696969"]
#define uexCV_nickname_label_size 14
#define uexCV_photo_size @50
#define uexCV_photo_cornor_radius 3
#define uexCV_message_shadow_radius 1
#define uexCV_error_label_size 30
@implementation uexCV_TableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



/*

 data={
    from://
    timestamp
    bgImage://
    duration
    data://
    hornImage://
    durationImage://
    onClick://
 */



-(void)modifiedCellWithMessageData:(NSDictionary*)data userInfo:(uexCV_UserInfo *)info{
    self.status=(uexCV_TableViewCellStatus)[data[@"from"] integerValue];
    self.containerView =[[UIView alloc]init];
    self.containerView.userInteractionEnabled=YES;
    [self.contentView addSubview:self.containerView];
    self.containerView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
    }];
    WS(ws)
    
    
    
   
    self.timestamp=[data[@"timestamp"] longLongValue];
    self.containerView.userInteractionEnabled=YES;
    
    //timeLabel
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd   HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[@(self.timestamp) doubleValue]/1000];
    NSString *time = [formatter stringFromDate:date];
    self.timeLabel=[[UILabel alloc]init];
    [_timeLabel setText:time];
    [_timeLabel setFont:[UIFont systemFontOfSize:uexCV_default_label_size]];
    [_timeLabel setTextColor:uexCV_default_label_color];
    [uexCV_cell_container addSubview:_timeLabel];
    
    [_timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(uexCV_cell_container.mas_bottom).with.offset(-2*uexCV_default_margin);
        make.top.greaterThanOrEqualTo(uexCV_cell_container.mas_top);
        make.centerX.equalTo(uexCV_cell_container.mas_centerX);
    }];
    
    //photo
    self.photo=[[UIImageView alloc]initWithImage:info.photo];
    [_photo setContentMode:UIViewContentModeScaleToFill];
    _photo.layer.masksToBounds=YES;
    _photo.layer.cornerRadius=uexCV_photo_cornor_radius;
    [uexCV_cell_container addSubview:_photo];
    [_photo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(uexCV_photo_size);
        make.height.equalTo(uexCV_photo_size);
        make.top.equalTo(uexCV_cell_container.mas_top).with.offset(uexCV_default_margin);
        if(!uexCV_from_you){
            make.right.equalTo(uexCV_cell_container.mas_right).with.offset(-3*uexCV_default_margin);
        }else{
            make.left.equalTo(uexCV_cell_container.mas_left).with.offset(3*uexCV_default_margin);
        }
    }];
    
    //name
    self.nameLabel=[[UILabel alloc]init];
    [_nameLabel setText:info.nickname];
    [_nameLabel setFont:[UIFont systemFontOfSize:uexCV_nickname_label_size]];
    [_nameLabel setTextColor:uexCV_nickname_label_color];
    [uexCV_cell_container addSubview:_nameLabel];
    [_nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.photo.mas_bottom).with.offset(2*uexCV_default_margin);
        make.bottom.lessThanOrEqualTo(uexCV_cell_container.mas_bottom).with.offset(-uexCV_default_margin);
        
        make.centerX.equalTo(ws.photo.mas_centerX).priorityLow();
        if(!uexCV_from_you){
            make.right.lessThanOrEqualTo(uexCV_cell_container.mas_right).with.offset(-uexCV_default_margin);
        }else{
            make.left.greaterThanOrEqualTo(uexCV_cell_container.mas_left).with.offset(uexCV_default_margin);
        }
    }];
    
    //message
    //self.messageView=[[UIImageView alloc]init];
    self.messageView=[[uexCV_Bubble alloc]init];
    self.messageView.backgroundColor=[UIColor clearColor];
    self.messageView.userInteractionEnabled =YES;

    _messageView.layer.masksToBounds=YES;

    if(!uexCV_from_you){
        _messageView.transform=CGAffineTransformMakeScale(-1, 1);
        _messageView.layer.shadowOffset=CGSizeMake(-1, 1);
    }else{
        _messageView.layer.shadowOffset=CGSizeMake(1, 1);
    }
    [uexCV_cell_container addSubview:_messageView];
    [_messageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(uexCV_cell_container.mas_top).with.offset(4*uexCV_default_margin);
        make.bottom.lessThanOrEqualTo(ws.timeLabel.mas_top).with.offset(-uexCV_default_margin);
        
        if(!uexCV_from_you){
            make.right.equalTo(ws.photo.mas_left).with.offset(-2*uexCV_default_margin);
        }else{
            make.left.equalTo(ws.photo.mas_right).with.offset(2*uexCV_default_margin);
        }
    }];
    
    //errorLabel
    self.errorLabel = [[UILabel alloc]init];
    _errorLabel.userInteractionEnabled=YES;
    [_errorLabel setText:@"!"];

    [_errorLabel setFont:[UIFont systemFontOfSize:15]];
    //[_errorLabel setBackgroundColor:[UIColor blueColor]];
    [_errorLabel setTextColor:[UIColor redColor]];
    UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onErrorLabelClick:)];
    [_errorLabel addGestureRecognizer:tapGes];

    [uexCV_cell_container addSubview:_errorLabel];
    [_errorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ws.messageView.mas_centerY);
        make.width.equalTo(@(uexCV_error_label_size));
        make.height.equalTo(@(uexCV_error_label_size));
        if(!uexCV_from_you){
            make.right.lessThanOrEqualTo(ws.messageView.mas_left).with.offset(-2*uexCV_default_margin);
            [ws.errorLabel setTextAlignment:NSTextAlignmentRight];
        }else{
            make.left.greaterThanOrEqualTo(ws.messageView.mas_right).with.offset(2*uexCV_default_margin);
        }
    }];
    NSInteger status=[data[@"status"] integerValue];
    if(status == 2){
        _errorLabel.hidden=NO;
    }else{
       _errorLabel.hidden=YES;
    }
    

}

-(void)onErrorLabelClick:(id)sender{
    
    [self.tableView.superViewController.euexObj callbackJsonWithName:@"onErrorLabelClicked" Object:@{@"timestamp":@(_timestamp)}];
}




@end
