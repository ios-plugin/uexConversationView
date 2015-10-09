//
//  uexCV_TableView.h
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uexCV_VoiceCell.h"
#import "uexCV_TextCell.h"
@class uexCV_ViewController;
@interface uexCV_TableView : UITableView
@property (nonatomic,weak)uexCV_ViewController *superViewController;
@end
