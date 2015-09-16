//
//  uexCV_ViewController.h
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>





@class uexCV_UserInfo;
@class EUExConversationView;

typedef NS_ENUM(NSInteger, uexConversationViewAddDataType) {
    uexConversationViewAddDataNewMessage,
    uexConversationViewAddDataMessageHistory
};


typedef void (^pullRefreshBlock)();

@interface uexCV_ViewController : UIViewController
@property(nonatomic,weak) EUExConversationView *euexObj;
@property(nonatomic,assign)CGRect frame;
@property(nonatomic,strong)pullRefreshBlock loadHistoryBlock;
@property(nonatomic,strong)uexCV_UserInfo * meInfo;
@property(nonatomic,strong)uexCV_UserInfo * youInfo;
@property(nonatomic,strong)NSDictionary * extras;

-(instancetype)initWithFrame:(CGRect)frame
                       bgImg:(UIImage *)bgImg
                      meInfo:(uexCV_UserInfo *)me
                     youInfo:(uexCV_UserInfo *)you
                      extras:(NSDictionary *)extras
                     euexObj:(EUExConversationView *)euexObj;


-(void)addData:(NSArray*)data type:(uexConversationViewAddDataType)type;
@end
