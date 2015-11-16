//
//  uexCV_VoiceCell.h
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_TableViewCell.h"


typedef NS_ENUM(NSInteger,uexCV_hornView_status){
    uexCV_hornView_status_1 = 0,
    uexCV_hornView_status_2 = 1,
    uexCV_hornView_status_3 = 2,
    uexCV_hornView_status_4 = 3
};


@interface uexCV_VoiceCell : uexCV_TableViewCell
@property (nonatomic,strong)UILabel * durationView;
@property (nonatomic,strong)UIImageView * horn;

@property (nonatomic,strong)NSMutableArray * hornViews;
@property (nonatomic,assign)uexCV_hornView_status hornStatus;
@property (nonatomic,assign)BOOL isPlaying;
@property (nonatomic,assign)double duration;


-(void)stopPlaying;
@end
