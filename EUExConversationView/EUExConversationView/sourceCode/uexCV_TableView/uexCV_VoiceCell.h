//
//  uexCV_VoiceCell.h
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_TableViewCell.h"

typedef void (^clickBlock)();

@interface uexCV_VoiceCell : uexCV_TableViewCell
@property (nonatomic,strong)UILabel * durationView;
@property (nonatomic,strong)UIImageView * horn;
@property (nonatomic,strong)clickBlock onClick;
@end
