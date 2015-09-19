//
//  uexCV_UserInfo.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_UserInfo.h"






@implementation uexCV_UserInfo

-(instancetype)initWithPhoto:(UIImage *)photo
                    fontSize:(CGFloat)size
                   fontColor:(UIColor*)color
                    nickname:(NSString *)nick{
    self=[super init];
    if(self){
        
        if(size <1){
            size=14;
        }
        self.fontSize=size;
        if(color == [UIColor clearColor]){
            color=[UIColor blackColor];
        }
        self.fontColor=color;
        
        self.photo=photo;
        self.nickname=nick;
    }
    return self;
}

        
@end
