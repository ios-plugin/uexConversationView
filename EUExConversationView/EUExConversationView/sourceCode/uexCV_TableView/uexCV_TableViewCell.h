//
//  uexCV_TableViewCell.h
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uexCV_UserInfo.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "uexCV_TableViewCellData.h"




#define uexCV_default_margin 2
#define uexCV_inner_padding UIEdgeInsetsMake(10,10,10,8)
#define uexCV_inner_max_width_multipier 0.5
#define uexCV_default_label_color [UIColor uexCV_colorFromHtmlString:@"#ff4800"]
#define uexCV_default_label_size 10
#define uexCV_from_you (self.data.attribution == uexCV_MessageAttributionReceivedMessage)

#define uexCV_cell_container self.containerView


@class uexCV_TableView;
@interface uexCV_TableViewCell : UITableViewCell
@property (nonatomic,weak)uexCV_TableView *tableView;

@property (nonatomic,strong) UIImageView             *photo;
@property (nonatomic,strong) UIView                  *messageView;
@property (nonatomic,strong) UILabel                 *timeLabel;
@property (nonatomic,strong) UILabel                 *nameLabel;
@property (nonatomic,strong) UIView                  *containerView;
@property (nonatomic,strong) UILabel                 *errorLabel;
@property (nonatomic,strong) uexCV_TableViewCellData *data;



//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageData:(NSDictionary*)data userInfo:(uexCV_UserInfo *)info;
-(void)modifiedCellWithMessageData:(uexCV_TableViewCellData*)data;

@end
